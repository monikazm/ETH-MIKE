import multiprocessing
import os
import shutil
import sqlite3
from contextlib import nullcontext
from typing import Dict, Tuple, List, Any
from zipfile import ZipFile

from mike_analysis.cfg import config as cfg
from mike_analysis.core.file_processor import process_tdms
from mike_analysis.core.meta import Tables, AssessmentState, Modes, ModeDescs, time_measured
from mike_analysis.core.table_migrator import TableMigrator
from mike_analysis.evaluators import metric_evaluator_for_mode


class DataProcessor:
    def __init__(self, in_conn, out_conn, migrator: TableMigrator):
        self.in_conn = in_conn
        self.out_conn = out_conn
        self.migrator = migrator
        self.metric_col_names_for_mode = {}
        self.result_cols = {}

        for mode, evaluator in metric_evaluator_for_mode.items():
            if mode.name not in cfg.IMPORT_ASSESSMENTS:
                continue
            name_types = evaluator.get_result_column_names_and_types()
            self.metric_col_names_for_mode[mode] = [name for name, _ in name_types]
            self.result_cols[mode] = f',\n'.join([f'"{name}" {type_name}' for name, type_name in name_types])

    def create_result_tables(self):
        # Create result tables which store result results for each session/hand combination for a particular assessment
        combined_session_result_stmt_joins = ''
        for mode, evaluator in metric_evaluator_for_mode.items():
            if mode.name not in cfg.IMPORT_ASSESSMENTS:
                continue

            create_result_table_query = f'''
                        CREATE TABLE "{Tables.Results[mode]}" (
                            "Id" integer primary key not null,
                            "SessionId" integer not null,
                            "IthSession" integer not null,
                            "LeftHand" integer not null,
                            "AssessmentId" integer,
                            {self.result_cols[mode]},
                            UNIQUE("SessionId", "LeftHand")
                        )'''
            self.migrator.create_or_replace_table_index_or_view_from_stmt(Tables.Results[mode], create_result_table_query)
            self.migrator.create_or_replace_table_index_or_view_from_stmt(f'{Tables.Results[mode]}_IthSession',
                                                                          f'CREATE INDEX {Tables.Results[mode]}_IthSession '
                                                                          f'ON {Tables.Results[mode]} (IthSession)')

            create_result_table_view_stmt = f'''
                        CREATE VIEW "{Tables.Results[mode]}Full" AS
                            SELECT P.PatientId, R.LeftHand, R.IthSession, MIN(S.SessionStartTime) AS FirstSessionStartTime, {f", ".join(self.metric_col_names_for_mode[mode])}
                            FROM {Tables.Results[mode]} AS R
                            JOIN Session AS S USING(SessionId)
                            JOIN Patient AS P USING(PatientId)
                            GROUP BY P.PatientId, R.LeftHand, R.IthSession
                            ORDER BY P.PatientId, R.LeftHand, R.IthSession'''
            self.migrator.create_or_replace_table_index_or_view_from_stmt(f'{Tables.Results[mode]}Full', create_result_table_view_stmt)
            combined_session_result_stmt_joins += f'LEFT JOIN {Tables.Results[mode]}Full USING(PatientId, LeftHand, IthSession)\n'
        return combined_session_result_stmt_joins

    def create_result_view(self, combined_session_result_stmt_joins: str):
        all_metric_col_names = [name for metric_col_names in self.metric_col_names_for_mode.values() for name in metric_col_names]
        metric_names = f', '.join(all_metric_col_names)
        null_checks = f' OR\n'.join(f'{name} IS NOT NULL' for name in all_metric_col_names)
        patient_columns = self._get_all_columns_except(self.out_conn, Tables.Patient, ('SubjectNr', 'PatientId'))
        create_combined_session_result_stmt = f'''
                        CREATE VIEW SessionResult AS
                            SELECT P.SubjectNr, P.PatientId, LeftHand, IthSession,
                                {f", ".join([f"P.{patient_column}" for patient_column in patient_columns])},
                                {metric_names}
                            FROM Patient AS P
                            JOIN (SELECT 0 AS LeftHand UNION ALL SELECT 1)
                            JOIN (SELECT 1 AS IthSession {f" ".join([f"UNION ALL SELECT {i}" for i in range(2, 11)])})
                            {combined_session_result_stmt_joins}
                            WHERE {null_checks}
                            ORDER BY P.SubjectNr, LeftHand, IthSession
                '''
        self.migrator.create_or_replace_table_index_or_view_from_stmt('SessionResult', create_combined_session_result_stmt)

    def compute_and_store_metrics(self, data_dir: str, polybox_upload_dir: str):
        # Retrieve all completed assessments which are currently marked as a result of a session
        old_row_factory = self.in_conn.row_factory
        self.in_conn.row_factory = sqlite3.Row
        data_query = f'''
                SELECT S.*, P.SubjectNr, A.AssessmentId, A.TaskType, A.LeftHand, strftime('%Y%m%d_%H%M%S', A.StartTime) AS FmtStartTime 
                FROM {Tables.Session} AS S
                JOIN {Tables.Patient} AS P USING(PatientId)
                JOIN {Tables.Assessment} AS A USING(SessionId)
                WHERE State == {AssessmentState.Finished} AND IsTrialRun IS NOT TRUE AND A.TaskType IN ({f", ".join([str(Modes[mode].value) for mode in cfg.IMPORT_ASSESSMENTS])})
                ORDER BY AssessmentId ASC
            '''
        data = self.in_conn.execute(data_query).fetchall()

        # Retrieve tdms file paths, check for existence and retrieve required result data from input database
        assessments_for_userhandmode: Dict[Tuple[str, bool, int], List[int]] = {}
        self.in_conn.row_factory = self._dict_factory
        todo_assessments = {}
        for assessment in data:
            assessment_id = assessment['AssessmentId']
            task_type = assessment['TaskType']
            left_hand = assessment['LeftHand']
            subject_nr = assessment['SubjectNr']
            mode = Modes(task_type)

            path = os.path.join(data_dir,
                                subject_nr,
                                ModeDescs[task_type],
                                f"{'Right' if left_hand == 0 else 'Left'} Hand",
                                f"{assessment['FmtStartTime']}.tdms")

            prior_assessments = assessments_for_userhandmode.setdefault((subject_nr, left_hand, mode.value), [])
            prior_assessments.append(assessment['AssessmentId'])
            ith_session_for_assessment = len(prior_assessments)

            if not os.path.exists(path):
                user_backup_dir = os.path.join(polybox_upload_dir, 'Session Results', subject_nr)
                not_found = True
                if os.path.exists(user_backup_dir):
                    files = [os.path.join(user_backup_dir, file) for file in os.listdir(user_backup_dir) if
                             file.startswith(f'sid_{assessment["SessionId"]}')]
                    rel_path = '/'.join(
                        [ModeDescs[task_type], f"{'Right' if left_hand == 0 else 'Left'} Hand", f"{assessment['FmtStartTime']}.tdms"])
                    for file in sorted(files, reverse=True):
                        try:
                            with ZipFile(file, 'r') as f:
                                if rel_path in f.namelist():
                                    os.makedirs(os.path.dirname(path), exist_ok=True)
                                    with f.open(rel_path) as i, open(path, 'wb') as o:
                                        shutil.copyfileobj(i, o)
                                    try:
                                        with f.open(f'{rel_path}_index') as i, open(f'{path}_index', 'wb') as o:
                                            shutil.copyfileobj(i, o)
                                    except FileNotFoundError as e:
                                        print(f'WARN: tdms_index file missing from archive\n{e}')
                                    not_found = False
                                    break
                        except Exception as e:
                            print(f'Error while reading zip file {file}\n{e}')
                if not_found:
                    continue

            result_table = Tables.Results[mode]
            result_evaluator = metric_evaluator_for_mode[mode]
            db_trial_results = self.in_conn.execute(f'''
                            SELECT {f", ".join(result_evaluator.db_result_columns_to_select)} 
                            FROM {result_table} AS R
                            JOIN {Tables.Assessment} AS A USING(AssessmentId)
                            WHERE AssessmentId == ?
                            ORDER BY ResultId ASC
                        ''', (assessment_id,)).fetchall()
            # Workaround for missing automatic passive results in rom task
            if mode == Modes.RangeOfMotion:
                db_trial_results += [{'RomMode': 2} for _ in range(len(db_trial_results) // 2)]
            todo_assessments.setdefault(mode, []).append(
                (path, db_trial_results, assessment['SessionId'], ith_session_for_assessment, assessment_id, task_type, left_hand))
        del assessments_for_userhandmode
        self.in_conn.row_factory = old_row_factory

        # Compute metrics in parallel
        with multiprocessing.Pool() if cfg.ENABLE_MULTICORE else nullcontext() as p:
            for mode, assessments in todo_assessments.items():
                with time_measured(mode.name):
                    if cfg.ENABLE_MULTICORE:
                        results = p.map(self._process, assessments)
                    else:
                        results = list(map(self._process, assessments))

                    # Store metrics in output database
                    insert_placeholder = f"(:SessionId, :IthSession, :LeftHand, :AssessmentId, {f', '.join([f':{name}' for name in self.metric_col_names_for_mode[mode]])})"
                    metric_column_names = f', '.join(self.metric_col_names_for_mode[mode])
                    insert_stmt = f'INSERT OR REPLACE INTO "{Tables.Results[mode]}" (SessionId, IthSession, LeftHand, AssessmentId, {metric_column_names}) VALUES {insert_placeholder}'
                    self.out_conn.executemany(insert_stmt, results)
        # Commit transaction (write everything to db file)
        self.out_conn.commit()

    @staticmethod
    def _process(args: Tuple[str, List[Dict[str, Any]], int, int, int, int, bool]):
        """Compute metric values for an assessment and return as dict"""

        path, trial_results_from_db, session_id, ith_assessment, assessment_id, task_type, left_hand = args
        assessment_results = process_tdms(path, left_hand, task_type, trial_results_from_db)

        entry = {
            'SessionId': session_id,
            'IthSession': ith_assessment,
            'LeftHand': left_hand,
            'AssessmentId': assessment_id
        }
        entry.update(assessment_results)

        return entry

    @staticmethod
    def _get_all_columns_except(conn, table, ignore_list):
        return [elem[1] for elem in conn.execute(f'PRAGMA table_info({table});').fetchall() if elem[1] not in ignore_list]

    @staticmethod
    def _dict_factory(cursor, row):
        d = {}
        for idx, col in enumerate(cursor.description):
            d[col[0]] = row[idx]
        return d
