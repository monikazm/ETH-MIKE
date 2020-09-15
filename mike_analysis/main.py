import multiprocessing
import os
import shutil
import sqlite3
import sys
import pathlib
from contextlib import nullcontext
from timeit import default_timer as timer
from typing import Tuple, List, Dict, Any
from zipfile import ZipFile

import pandas as pd
# from pyinstrument import Profiler

from mike_analysis.cfg import config as cfg
from mike_analysis.core.file_processor import process_tdms
from mike_analysis.core.meta import Tables, AssessmentState, ModeDescs, Modes, SqlTypes
from mike_analysis.core.redcap_api import RedCap
from mike_analysis.core.table_migrator import TableMigrator
from mike_analysis.evaluators import metric_evaluator_for_mode


def dict_factory(cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d


def get_all_columns_except(conn, table, ignore_list):
    return [elem[1] for elem in conn.execute(f'PRAGMA table_info({table});').fetchall() if elem[1] not in ignore_list]


def create_redcap_table(migrator, columns, key_cols, table_name, table_indices):
    redcap_column_defs = f',\n'.join([f'"{name}" {type_name}' for name, type_name in columns])
    unique_constr = f'"{key_cols[0]}"'
    for col in key_cols[1:]:
        unique_constr += f', "{col}"'
    create_redcap_table_stmt = f'''
                    CREATE TABLE "{table_name}" (
                        "Id" integer primary key not null,
                        {redcap_column_defs},
                        UNIQUE({unique_constr})
                    )
                '''
    migrator.create_or_replace_table_index_or_view_from_stmt(table_name, create_redcap_table_stmt)
    for index in table_indices:
        migrator.create_or_replace_table_index_or_view_from_stmt(f'{table_name}_{index}',
                                                                 f'CREATE INDEX {table_name}_{index} ON {table_name} ({index})')


def main(db_path: str, polybox_upload_dir: str, data_dir: str):
    def ts_adapter(timestamp: pd.Timestamp) -> str:
        return pd.to_datetime(timestamp).strftime('%Y-%m-%d')
    sqlite3.register_adapter(pd.Timestamp, ts_adapter)

    try:
        in_conn = sqlite3.connect(f'{pathlib.Path(db_path).absolute().as_uri()}?mode=ro', uri=True) # Open db.db in read-only mode
        out_conn = sqlite3.connect('analysis_db.db')
    except Exception as e:
        print(f'ERROR: Failed to open db\n{e}')
        sys.exit(-1)

    migrator = TableMigrator(in_conn, out_conn)

    # Copy patient and session data from input database
    def copy_patient_and_session_data():
        migrator.migrate_table_index_or_view(Tables.Patient)
        migrator.migrate_table_index_or_view(f'{Tables.Patient}_SubjectNr')
        migrator.migrate_table_data(Tables.Patient)
        migrator.migrate_table_index_or_view(Tables.Session)
        migrator.migrate_table_index_or_view(f'{Tables.Session}_PatientId')
        migrator.migrate_table_data(Tables.Session)
    copy_patient_and_session_data()

    if cfg.REDCAP_IMPORT:
        def import_from_redcap_if_e():
            start = timer()
            rc = RedCap(api_url=cfg.REDCAP_URL, token=cfg.RECAP_API_TOKEN)

            # Request datadict over API
            redcap_columns = rc.export_columns(redcap_excluded_fields={cfg.REDCAP_RECORD_IDENTIFIER} | cfg.REDCAP_EXCLUDED_COLS)

            # Request form and event metadata
            repeating_forms_and_events = rc.export_repeating_events()
            repeating_events = repeating_forms_and_events[repeating_forms_and_events['event_name'].notna()]['event_name'].unique()
            if repeating_forms_and_events[repeating_forms_and_events['form_name'].notna()]['form_name'].unique().size > 0:
                print('WARNING, mike_analysis does not support repeating forms/instruments yet')
                sys.exit(1)
            event_map = rc.export_event_map()

            # Split forms into different categories depending on whether they are repeated or not (-> different primary keys)
            # and build corresponding tables
            redcap_all_columns = {}
            for form in redcap_columns.keys():
                events = event_map[event_map['form'] == form]
                if events.loc[:, 'unique_event_name'].isin(repeating_events).any():
                    key = [(cfg.REDCAP_RECORD_IDENTIFIER, 'integer not null'), ('redcap_event_name', 'varchar not null'), ('redcap_repeat_instance', 'integer not null')]
                elif len(events) > 1:
                    key = [(cfg.REDCAP_RECORD_IDENTIFIER, 'integer not null'), ('redcap_event_name', f'varchar not null')]
                else:
                    key = [(cfg.REDCAP_RECORD_IDENTIFIER, 'integer not null'), ]

                redcap_all_columns[form] = key + redcap_columns[form]
                create_redcap_table(migrator, redcap_all_columns[form], [name for name, _ in key], *cfg.REDCAP_NAMES_AND_INDEX_COLS[form])

            # Build tables
            date_cols = [name for cols in redcap_columns.values() for name, t in cols if t == SqlTypes.Date]
            data = rc.export_records(date_cols)
            for form, columns in redcap_all_columns.items():
                all_col_names = [name for name, _ in columns]
                col_names = [name for name, _ in redcap_columns[form]]
                form_data = data.loc[:, all_col_names].dropna(how='all', subset=col_names)
                if 'redcap_repeat_instance' in form_data.columns:
                    form_data.loc[:, 'redcap_repeat_instance'].fillna(0, inplace=True)
                form_data = form_data.replace({pd.NA: None})

                records = form_data.values.tolist()

                metric_column_names = f', '.join(all_col_names)
                insert_placeholder = f"({f', '.join(['?' for _ in all_col_names])})"
                pretty_name = cfg.REDCAP_NAMES_AND_INDEX_COLS[form][0]
                insert_stmt = f'INSERT OR REPLACE INTO "{pretty_name}" ({metric_column_names}) VALUES {insert_placeholder}'
                out_conn.executemany(insert_stmt, records)
            out_conn.commit()
            end = timer()
            print(f'Done with redcap import, elapsed: {end - start}s')
        import_from_redcap_if_e()

    # Create result tables which store result results for each session/hand combination for a particular assessment
    metric_col_names_for_mode = {}

    def create_result_tables():
        combined_session_result_stmt_joins = ''
        for mode, evaluator in metric_evaluator_for_mode.items():
            if mode.name not in cfg.IMPORT_ASSESSMENTS:
                continue

            name_types = evaluator.get_result_column_names_and_types()
            metric_col_names_for_mode[mode] = [name for name, _ in name_types]
            result_cols = f',\n'.join([f'"{name}" {type_name}' for name, type_name in name_types])
            create_result_table_query = f'''
                CREATE TABLE "{Tables.Results[mode]}" (
                    "Id" integer primary key not null,
                    "SessionId" integer not null,
                    "IthSession" integer not null,
                    "LeftHand" integer not null,
                    "AssessmentId" integer,
                    {result_cols},
                    UNIQUE("SessionId", "LeftHand")
                )'''
            migrator.create_or_replace_table_index_or_view_from_stmt(Tables.Results[mode], create_result_table_query)
            migrator.create_or_replace_table_index_or_view_from_stmt(f'{Tables.Results[mode]}_IthSession',
                                                                     f'CREATE INDEX {Tables.Results[mode]}_IthSession '
                                                                     f'ON {Tables.Results[mode]} (IthSession)')

            create_result_table_view_stmt = f'''
                CREATE VIEW "{Tables.Results[mode]}Full" AS
                    SELECT P.PatientId, R.LeftHand, R.IthSession, MIN(S.SessionStartTime) AS FirstSessionStartTime, {f", ".join(metric_col_names_for_mode[mode])}
                    FROM {Tables.Results[mode]} AS R
                    JOIN Session AS S USING(SessionId)
                    JOIN Patient AS P USING(PatientId)
                    GROUP BY P.PatientId, R.LeftHand, R.IthSession
                    ORDER BY P.PatientId, R.LeftHand, R.IthSession'''
            migrator.create_or_replace_table_index_or_view_from_stmt(f'{Tables.Results[mode]}Full', create_result_table_view_stmt)
            combined_session_result_stmt_joins += f'LEFT JOIN {Tables.Results[mode]}Full USING(PatientId, LeftHand, IthSession)\n'
        return combined_session_result_stmt_joins
    combined_session_result_stmt_joins = create_result_tables()

    # Create combined result view which contains all patient metadata and session results
    def create_combined_result_view():
        all_metric_col_names = [name for metric_col_names in metric_col_names_for_mode.values() for name in metric_col_names]
        metric_names = f', '.join(all_metric_col_names)
        null_checks = f' OR\n'.join(f'{name} IS NOT NULL' for name in all_metric_col_names)
        patient_columns = get_all_columns_except(out_conn, Tables.Patient, ('SubjectNr', 'PatientId'))
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
        migrator.create_or_replace_table_index_or_view_from_stmt('SessionResult', create_combined_session_result_stmt)
    create_combined_result_view()

    # Retrieve all completed assessments which are currently marked as a result of a session
    in_conn.row_factory = sqlite3.Row
    data_query = f'''
        SELECT S.*, P.SubjectNr, A.AssessmentId, A.TaskType, A.LeftHand, strftime('%Y%m%d_%H%M%S', A.StartTime) AS FmtStartTime 
        FROM {Tables.Session} AS S
        JOIN {Tables.Patient} AS P USING(PatientId)
        JOIN {Tables.Assessment} AS A USING(SessionId)
        WHERE State == {AssessmentState.Finished} AND IsTrialRun IS NOT TRUE AND A.TaskType IN ({f", ".join([str(Modes[mode].value) for mode in cfg.IMPORT_ASSESSMENTS])})
        ORDER BY AssessmentId ASC
    '''
    data = in_conn.execute(data_query).fetchall()

    # Retrieve tdms file paths, check for existence and retrieve required result data from input database
    assessments_for_userhandmode: Dict[Tuple[str, bool, int], List[int]] = {}
    in_conn.row_factory = dict_factory
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
                files = [os.path.join(user_backup_dir, file) for file in os.listdir(user_backup_dir) if file.startswith(f'sid_{assessment["SessionId"]}')]
                rel_path = '/'.join([ModeDescs[task_type], f"{'Right' if left_hand == 0 else 'Left'} Hand", f"{assessment['FmtStartTime']}.tdms"])
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
        db_trial_results = in_conn.execute(f'''
                    SELECT {f", ".join(result_evaluator.db_result_columns_to_select)} 
                    FROM {result_table} AS R
                    JOIN {Tables.Assessment} AS A USING(AssessmentId)
                    WHERE AssessmentId == ?
                    ORDER BY ResultId ASC
                ''', (assessment_id,)).fetchall()
        # Workaround for missing automatic passive results in rom task
        if mode == Modes.RangeOfMotion:
            db_trial_results += [{'RomMode': 2} for _ in range(len(db_trial_results) // 2)]
        todo_assessments.setdefault(mode, []).append((path, db_trial_results, assessment['SessionId'], ith_session_for_assessment, assessment_id, task_type, left_hand))
    del assessments_for_userhandmode

    # Compute metrics in parallel
    with multiprocessing.Pool() if cfg.ENABLE_MULTICORE else nullcontext() as p:
        for mode, assessments in todo_assessments.items():
            start = timer()
            if cfg.ENABLE_MULTICORE:
                results = p.map(process, assessments)
            else:
                results = list(map(process, assessments))

            # Store metrics in output database
            insert_placeholder = f"(:SessionId, :IthSession, :LeftHand, :AssessmentId, {f', '.join([f':{name}' for name in metric_col_names_for_mode[mode]])})"
            metric_column_names = f', '.join(metric_col_names_for_mode[mode])
            insert_stmt = f'INSERT OR REPLACE INTO "{Tables.Results[mode]}" (SessionId, IthSession, LeftHand, AssessmentId, {metric_column_names}) VALUES {insert_placeholder}'
            out_conn.executemany(insert_stmt, results)
            end = timer()
            print(f'Done with {mode.name}, elapsed: {end - start}s')

    # Commit transaction (write everything to db file)
    out_conn.commit()


def process(args: Tuple[str, List[Dict[str, Any]], int, int, int, int, bool]):
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


if __name__ == '__main__':
    #profiler = Profiler()
    #profiler.start()
    if len(sys.argv) > 1:
        db_path = sys.argv[1]
    elif cfg.DB_PATH:
        db_path = cfg.DB_PATH
    elif cfg.USE_DB_FROM_UPLOAD_DIR and os.path.exists(cfg.PATH_TO_POLYBOX_UPLOAD_DIR):
        db_paths = os.listdir(os.path.join(cfg.PATH_TO_POLYBOX_UPLOAD_DIR, 'Database Backups'))
        if db_paths:
            db_path = os.path.join(cfg.PATH_TO_POLYBOX_UPLOAD_DIR, 'Database Backups', max(db_paths))
        else:
            db_path = 'db.db'
    else:
        db_path = 'db.db'

    main(db_path,
         cfg.PATH_TO_POLYBOX_UPLOAD_DIR,
         cfg.PATH_TO_DATA_ROOT_DIR)
    #profiler.stop()
    #print(profiler.output_text(unicode=True, color=True))
