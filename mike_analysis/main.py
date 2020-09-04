import multiprocessing
import os
import sqlite3
from contextlib import nullcontext
from timeit import default_timer as timer
from typing import Tuple, List, Dict, Any

#from pyinstrument import Profiler

from mike_analysis.evaluators import metric_evaluator_for_mode
from mike_analysis.core.file_processor import process_tdms
from mike_analysis.core.meta import Tables, AssessmentState, ModeDescs, Modes
from mike_analysis.core.table_migrator import TableMigrator

ENABLE_MULTICORE = True


def dict_factory(cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d


def get_all_columns_except(conn, table, ignore_list):
    return [elem[1] for elem in conn.execute(f'PRAGMA table_info({table});').fetchall() if elem[1] not in ignore_list]


def main(db_path, data_dir):
    in_conn = sqlite3.connect(db_path)
    out_conn = sqlite3.connect('analysis_db.db')

    migrator = TableMigrator(in_conn, out_conn)

    # Copy patient and session data from input database
    migrator.migrate_table_index_or_view(Tables.Patient)
    migrator.migrate_table_index_or_view(f'{Tables.Patient}_SubjectNr')
    migrator.migrate_table_data(Tables.Patient)
    migrator.migrate_table_index_or_view(Tables.Session)
    migrator.migrate_table_index_or_view(f'{Tables.Session}_PatientId')
    migrator.migrate_table_data(Tables.Session)

    # Create result tables which store result results for each session/hand combination for a particular assessment
    metric_col_names_for_mode = {}
    create_combined_session_result_stmt = ''
    for mode, evaluator in metric_evaluator_for_mode.items():
        name_types = evaluator.get_result_column_names_and_types()
        metric_col_names_for_mode[mode] = [name for name, _ in name_types]
        result_cols = f',\n'.join([f'"{name}" {type_name}' for name, type_name in name_types])
        create_result_table_query = f'''
            CREATE TABLE "{Tables.Results[mode]}" (
                "Id" integer primary key not null,
                "SessionId" integer not null,
                "LeftHand" integer not null,
                "AssessmentId" integer,
                {result_cols},
                UNIQUE("SessionId", "LeftHand")
            )'''
        migrator.create_or_replace_table_index_or_view_from_stmt(Tables.Results[mode], create_result_table_query)
        create_combined_session_result_stmt += f'LEFT JOIN {Tables.Results[mode]} USING(SessionId, LeftHand)\n'

    # Create combined result view which contains all patient metadata and session results
    all_metric_col_names = [name for metric_col_names in metric_col_names_for_mode.values() for name in metric_col_names]
    metric_names = f', '.join(all_metric_col_names)
    null_checks = f' OR\n'.join(f'{name} IS NOT NULL' for name in all_metric_col_names)
    session_columns = get_all_columns_except(out_conn, Tables.Session, ('SessionId', 'PatientId'))
    patient_columns = get_all_columns_except(out_conn, Tables.Patient, ('SubjectNr', 'PatientId'))
    create_combined_session_result_stmt = f'''
            CREATE VIEW SessionResult AS
                SELECT P.SubjectNr, S.SessionId, LeftHand, 
                    {f", ".join([f"S.{session_column}" for session_column in session_columns])},
                    {f", ".join([f"P.{patient_column}" for patient_column in patient_columns])}, 
                    {metric_names} 
                FROM Session AS S
                JOIN (SELECT 0 AS LeftHand UNION ALL SELECT 1)
                LEFT JOIN Patient AS P USING(PatientId)
                {create_combined_session_result_stmt}
                WHERE {null_checks}
                ORDER BY P.SubjectNr, S.SessionId, LeftHand
    '''
    migrator.create_or_replace_table_index_or_view_from_stmt('SessionResult', create_combined_session_result_stmt)

    # Retrieve all completed assessments which are currently marked as a result of a session
    in_conn.row_factory = sqlite3.Row
    data = in_conn.execute(f'''
        SELECT S.*, P.SubjectNr, A.AssessmentId, A.TaskType, A.LeftHand, strftime('%Y%m%d_%H%M%S', A.StartTime) AS FmtStartTime 
        FROM {Tables.Session} AS S
        JOIN {Tables.Patient} AS P USING(PatientId)
        JOIN {Tables.Assessment} AS A USING(SessionId)
        WHERE State == {AssessmentState.Finished} AND IsTrialRun IS NOT TRUE
    ''').fetchall()

    # Retrieve tdms file paths, check for existence and retrieve required result data from input database
    in_conn.row_factory = dict_factory
    todo_assessments = {}
    for assessment in data:
        task_type = assessment['TaskType']
        left_hand = assessment['LeftHand']
        path = os.path.join(data_dir,
                            assessment['SubjectNr'],
                            ModeDescs[task_type],
                            f"{'Right' if left_hand == 0 else 'Left'} Hand",
                            f"{assessment['FmtStartTime']}.tdms")
        if not os.path.exists(path):
            continue

        mode = Modes(task_type)
        assessment_id = assessment['AssessmentId']
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
        todo_assessments.setdefault(mode, []).append((path, db_trial_results, assessment['SessionId'], assessment_id, task_type, left_hand))

    # Compute metrics in parallel
    with multiprocessing.Pool() if ENABLE_MULTICORE else nullcontext() as p:
        for mode, assessments in todo_assessments.items():
            start = timer()
            if ENABLE_MULTICORE:
                results = p.map(process, assessments)
            else:
                results = list(map(process, assessments))

            # Store metrics in output database
            insert_placeholder = f"(:SessionId, :LeftHand, :AssessmentId, {f', '.join([f':{name}' for name in metric_col_names_for_mode[mode]])})"
            metric_column_names = f', '.join(metric_col_names_for_mode[mode])
            insert_stmt = f'INSERT OR REPLACE INTO "{Tables.Results[mode]}" (SessionId, LeftHand, AssessmentId, {metric_column_names}) VALUES {insert_placeholder}'
            out_conn.executemany(insert_stmt, results)
            end = timer()
            print(f'Done with {mode.name}, elapsed: {end - start}s')

    # Commit transaction (write everything to db file)
    out_conn.commit()


def process(args: Tuple[str, List[Dict[str, Any]], int, int, int, bool]):
    """Compute metric values for an assessment and return as dict"""

    path, trial_results_from_db, session_id, assessment_id, task_type, left_hand = args
    assessment_results = process_tdms(path, left_hand, task_type, trial_results_from_db)

    entry = {
        'SessionId': session_id,
        'LeftHand': left_hand,
        'AssessmentId': assessment_id
    }
    entry.update(assessment_results)

    return entry


if __name__ == '__main__':
    #profiler = Profiler()
    #profiler.start()
    main(r'G:\RelabZivi\DataAnalysis\Pilot Longitudinal Study Data\db.db', r'G:\RelabZivi\DataAnalysis\Pilot Longitudinal Study Data\Raw')
    #profiler.stop()
    #print(profiler.output_text(unicode=True, color=True))
