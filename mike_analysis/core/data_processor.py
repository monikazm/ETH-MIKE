import multiprocessing
import os
import sqlite3
from collections import namedtuple
from contextlib import nullcontext

import pandas as pd

from mike_analysis.cfg import config as cfg
from mike_analysis.core.constants import Tables, Modes, ModeResults, ModeDescs, time_measured, colored_print, TColor, dict_factory
from mike_analysis.core.file_processing import process_tdms, search_and_extract_tdms_from_zips
from mike_analysis.core.sqlite_migrator import SQLiteMigrator
from mike_analysis.evaluators import metric_evaluator_for_mode

ProcessArgs = namedtuple(
    'ProcessArgs', 'tdms_path db_trial_results assessment_id task_type left_hand')


class DataProcessor:
    def __init__(self, in_conn, out_conn, sqlite_migrator: SQLiteMigrator, study_cfg):
        self.in_conn: sqlite3.Connection = in_conn
        self.out_conn: sqlite3.Connection = out_conn
        self.sqlite_migrator = sqlite_migrator
        self.study_cfg = study_cfg
        self.metric_meta = {mode: metric_evaluator_for_mode[mode].get_result_column_info()
                            for mode in metric_evaluator_for_mode if mode.name in self.study_cfg.IMPORT_ASSESSMENT_TABLES}
        self.metric_col_names_for_mode = {
            mode: [meta[0] for meta in self.metric_meta[mode]] for mode in self.metric_meta}

    def create_metric_info_table(self):
        # Create metric meta table
        additional_columns = ('HealthyAvg', 'SrdImpaired', 'SrdNonImpaired')
        create_stmt = '''
                    CREATE TABLE "MetricInfo" (
                        "Id" integer primary key not null,
                        "Name" varchar not null UNIQUE,
                        "DataType" integer not null,
                        "BiggerIsBetter" integer not null,
                        "Unit" varchar not null,
                    ''' + ',\n'.join([f'"{col}" numeric' for col in additional_columns]) + ')'
        self.sqlite_migrator.create_or_update_table_index_or_view_from_stmt(
            create_stmt)

        # Insert metric metadata
        self.out_conn.executemany('INSERT OR IGNORE INTO "MetricInfo" (Name, DataType, BiggerIsBetter, Unit) '
                                  'VALUES (?, ?, ?, ?)', [val for vals in self.metric_meta.values() for val in vals])

        # Read optional healthy avg and Srds from csv file in current working directory
        # (If not defined for a metric, it will remain NULL in the database)
        # Note: With the current implementation, if there are already SRD values or healthy avg stored in the analysis database,
        # they will not be overwritten with values from csv
        if os.path.exists('metric_metadata_defaults.csv'):
            try:
                mdata = pd.read_csv('metric_metadata_defaults.csv')
                data_dict = mdata.to_dict(orient='records')
                for meta_info in additional_columns:
                    self.out_conn.executemany(f'''
                                UPDATE "MetricInfo"
                                SET "{meta_info}" = :{meta_info}
                                WHERE Name == :MetricName AND "{meta_info}" IS NULL
                            ''', data_dict)
            except Exception as e:
                print(f'Failed to process metadata defaults file\n{e}')

        self.out_conn.commit()

    def create_result_tables(self):
        # Create result tables which store result results for each session/hand combination for a particular assessment
        combined_session_result_stmt_joins = ''
        for mode, evaluator in metric_evaluator_for_mode.items():
            if mode.name not in self.study_cfg.IMPORT_ASSESSMENT_TABLES:
                continue

            result_cols_defs = ',\n'.join(
                [f'"{name}" {type_name}' for name, type_name, _, _ in self.metric_meta[mode]])
            create_result_table_query = f'''
                CREATE TABLE "{Tables.MetricResults[mode]}" (
                    "AssessmentId" integer primary key not null,
                    {result_cols_defs}
                )
            '''
            self.sqlite_migrator.create_or_update_table_index_or_view_from_stmt(
                create_result_table_query, overwrite=True)
            combined_session_result_stmt_joins += f'LEFT JOIN {Tables.MetricResults[mode]} USING(AssessmentId)\n'
        return combined_session_result_stmt_joins

    def create_pseudo_session_view(self):
        # Create Pseudo Session View
        self.sqlite_migrator.create_or_update_table_index_or_view_from_stmt('''
            CREATE VIEW "PseudoSession" AS
            SELECT PatientId, SessionId, LeftHand, IthSession, SessionStartDate, AssessmentId
            FROM (
                SELECT PatientId, SessionId, LeftHand, IthSession, DATE(MIN(StartTime)) AS SessionStartDate
                FROM (
                    SELECT S.PatientId, A.SessionId, A.LeftHand,
                           ROW_NUMBER() OVER (PARTITION BY S.PatientId, A.LeftHand, A.TaskType ORDER BY AssessmentId ASC) AS IthSession,
                           A.StartTime
                    FROM Assessment AS A
                    JOIN Session AS S USING(SessionId)
                )
                GROUP BY PatientId, LeftHand, IthSession
            )
            JOIN (
                SELECT PatientId, SessionId, LeftHand, AssessmentId
                FROM (
                    SELECT S.PatientId, A.SessionId, A.LeftHand, A.AssessmentId
                    FROM Assessment AS A
                    JOIN Session AS S USING(SessionId)
                )
            ) USING(PatientId, SessionId, LeftHand)
        ''')

    def create_result_views(self, combined_session_result_stmt_joins: str):

        self.create_pseudo_session_view()

        all_metric_col_names = [name for metric_col_names in self.metric_col_names_for_mode.values(
        ) for name in metric_col_names]
        metric_names = ', '.join(
            f'MAX({metric}) AS {metric}' for metric in all_metric_col_names)
        not_null_checks = ' OR\n'.join(
            f'{name} IS NOT NULL' for name in all_metric_col_names)
        patient_columns = self.sqlite_migrator.out_get_all_columns_except(
            Tables.Patient, ('SubjectNr', 'PatientId'))

        session_result_view_name = 'AssessmentMetrics'
        create_combined_session_result_stmt = f'''
            CREATE VIEW "{session_result_view_name}" AS
                SELECT P.SubjectNr, PS.LeftHand, PS.IthSession, PS.SessionStartDate,
                    ((PS.LeftHand AND P.LeftImpaired) OR (NOT PS.LeftHand AND P.RightImpaired)) AS impaired,
                    {", ".join([f"P.{patient_column}" for patient_column in patient_columns])},
                    {metric_names}
                FROM PseudoSession AS PS
                JOIN Patient AS P USING(PatientId)
                {combined_session_result_stmt_joins}
                WHERE {not_null_checks}
                GROUP BY P.PatientId, PS.LeftHand, PS.IthSession
                ORDER BY P.SubjectNr, PS.LeftHand, PS.IthSession
        '''
        print(create_combined_session_result_stmt)
        self.sqlite_migrator.create_or_update_table_index_or_view_from_stmt(
            create_combined_session_result_stmt)
        if (cfg.STUDY_CONFIG == 'ksa_longitudinal_study' and cfg.REDCAP_IMPORT):
            self.study_cfg.create_additional_views(
                self.sqlite_migrator, f', '.join(all_metric_col_names))

    def compute_and_store_metrics(self, data_dir: str, polybox_upload_dir: str):
        result_modes_list = [
            s + "Result" for s in self.study_cfg.IMPORT_ASSESSMENT_TABLES]
        enabled_modes = [
            mode for mode in ModeResults if mode.name in result_modes_list]
        self.out_conn.row_factory = sqlite3.Row

        # Check for missing data
        incomplete_sessions = self.out_conn.execute('''
            SELECT * FROM (
                SELECT P.SubjectNr, S.*, COUNT(S.AssessmentId) AS NumAssessments, GROUP_CONCAT(A.TaskType) AS CompletedTasks
                FROM PseudoSession AS S
                JOIN Assessment AS A USING(AssessmentId)
                JOIN Patient AS P USING(PatientId)
                GROUP BY S.PatientId, S.LeftHand, S.IthSession
            )
            WHERE NumAssessments != ?
        ''', (len(enabled_modes),)).fetchall()
        if incomplete_sessions:
            missing_assess_for_user_hand = {(sess['SubjectNr'], sess['LeftHand']): {mode: 0 for mode in enabled_modes} for sess in
                                            incomplete_sessions}
            for sess in incomplete_sessions:
                completed = [Modes(int(t, 10))
                             for t in sess['CompletedTasks'].split(',')]
                for mode in enabled_modes:
                    if mode not in completed:
                        missing_assess_for_user_hand[(
                            sess['SubjectNr'], sess['LeftHand'])][mode] += 1

            with colored_print(TColor.WARNING):
                for (patient, leftHand), missing_for_Mode in missing_assess_for_user_hand.items():
                    for mode, count in missing_for_Mode.items():
                        if count > 0:
                            print(f'WARNING: Patient {patient}, {"left" if leftHand else "right"} hand is missing '
                                  f'{count} {mode.name} assessment{"s" if count > 1 else ""}')

        # Retrieve all completed assessments which are currently marked as a result of a session
        assessment_query = f'''
            SELECT S.SessionId, P.SubjectNr, A.AssessmentId, A.TaskType, A.LeftHand, strftime('%Y%m%d_%H%M%S', A.StartTime) AS FmtStartTime
            FROM {Tables.Session} AS S
            JOIN {Tables.Patient} AS P USING(PatientId)
            JOIN {Tables.Assessment} AS A USING(SessionId)
            WHERE A.TaskType IN ({", ".join([str(mode.value) for mode in enabled_modes])})
            ORDER BY AssessmentId ASC
        '''
        data = self.out_conn.execute(assessment_query).fetchall()

        # Prepare sql query string to retrieve data from result table for each mode
        result_table_query_for_mode = {
            mode: f'''
                SELECT {", ".join(metric_evaluator_for_mode[mode].get_db_result_columns_to_select())}
                FROM {Tables.Results[mode]} AS R
                JOIN {Tables.Assessment} AS A USING(AssessmentId)
                WHERE AssessmentId == ?
                ORDER BY ResultId ASC
            '''
            for mode in enabled_modes
        }

        # Prepare list of assessments for which metrics need to be computed
        self.in_conn.row_factory = dict_factory
        todo_assessments = {mode: [] for mode in enabled_modes}
        for assessment in data:
            assessment_id = assessment['AssessmentId']
            task_type = assessment['TaskType']
            left_hand = assessment['LeftHand']
            subject_nr = assessment['SubjectNr']
            mode = Modes(task_type)

            rel_path = os.path.join(ModeDescs[task_type],
                                    f"{'Right' if left_hand == 0 else 'Left'} Hand",
                                    f"{assessment['FmtStartTime']}.tdms")
            full_tdms_path = os.path.join(data_dir, subject_nr, rel_path)

            if not os.path.exists(full_tdms_path):
                # If tdms not found, look for it in the zip files in the polybox upload dir and extract it if found
                user_backup_dir = os.path.join(
                    polybox_upload_dir, 'Session Results', subject_nr)
                found = search_and_extract_tdms_from_zips(
                    user_backup_dir, assessment['SessionId'], rel_path, full_tdms_path)
                if not found:
                    with colored_print(TColor.WARNING):
                        print(
                            f'WARNING: Raw data for assessment {assessment["AssessmentId"]} appears to be missing ("{full_tdms_path}").')
                    continue

            db_trial_results = self.in_conn.execute(
                result_table_query_for_mode[mode], (assessment_id,)).fetchall()
            if mode == Modes.RangeOfMotion:
                # Workaround for missing automatic results in rom task (add dummy entries assuming same number of trials as active/passive)
                db_trial_results += [{'RomMode': 2}
                                     for _ in range(len(db_trial_results) // 2)]
            todo_assessments[mode].append(ProcessArgs(
                full_tdms_path, db_trial_results, assessment_id, task_type, left_hand))
        # Compute metrics in parallel
        with multiprocessing.Pool() if cfg.ENABLE_MULTICORE else nullcontext() as p:
            map_ = p.map if cfg.ENABLE_MULTICORE else map
            for mode, assessments in todo_assessments.items():
                with time_measured(mode.name):
                    # Compute metrics for all assessments of this mode
                    results = map_(
                        self._process_single_assessment, assessments)

                    # Store metrics in output database
                    metric_column_placeholders = ', '.join(
                        [f':{name}' for name in self.metric_col_names_for_mode[mode]])
                    metric_column_names = ', '.join(
                        self.metric_col_names_for_mode[mode])
                    insert_stmt = f'INSERT OR REPLACE INTO "{Tables.MetricResults[mode]}" (AssessmentId, {metric_column_names}) ' \
                                  f'VALUES (:AssessmentId, {metric_column_placeholders})'
                    self.out_conn.executemany(insert_stmt, results)
        # Commit transaction (write everything to db file)
        self.out_conn.commit()

    @staticmethod
    def _process_single_assessment(args: ProcessArgs):
        """Compute metric values for an assessment and return as dict"""
        result_dict = process_tdms(
            args.tdms_path, args.left_hand, args.task_type, args.db_trial_results)
        result_dict['AssessmentId'] = args.assessment_id
        return result_dict
