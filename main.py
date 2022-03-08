import os
import sqlite3
import sys
import pathlib

import pandas as pd
# from pyinstrument import Profiler

from mike_analysis.cfg import config as cfg
from mike_analysis.core.data_processor import DataProcessor
from mike_analysis.core.constants import Tables, time_measured, AssessmentState
from mike_analysis.core.redcap_importer import RedcapImporter
from mike_analysis.core.table_migrator import TableMigrator
from mike_analysis.core.redcap_view_creator import insert_therapy_day, create_therapy_view


def import_and_process_everything(db_path: str, polybox_upload_dir: str, data_dir: str):
    def ts_adapter(timestamp: pd.Timestamp) -> str:
        return pd.to_datetime(timestamp).strftime('%Y-%m-%d')
    sqlite3.register_adapter(pd.Timestamp, ts_adapter)

    print(cfg.IMPORT_ASSESSMENTS)

    # Open database files
    try:
        # Open db.db in read-only mode
        in_conn = sqlite3.connect(
            f'{pathlib.Path(db_path).absolute().as_uri()}?mode=ro', uri=True)
        out_conn = sqlite3.connect('analysis_db.db')
    except Exception as e:
        print(f'ERROR: Failed to open db\n{e}')
        sys.exit(-1)

    try:
        # Migrates data from front end db to analysis db
        migrator = TableMigrator(in_conn, out_conn)

        # Copy patient, session and completed assessment data from input database
        migrator.migrate_table_index_or_view(Tables.Patient, overwrite=True)
        migrator.migrate_table_index_or_view(f'{Tables.Patient}_SubjectNr')
        migrator.migrate_table_data(Tables.Patient)

        migrator.migrate_table_index_or_view(Tables.Session, overwrite=True)
        migrator.migrate_table_index_or_view(f'{Tables.Session}_PatientId')
        migrator.migrate_table_data(Tables.Session)

        migrator.migrate_table_index_or_view(
            f'{Tables.Assessment}', overwrite=True)
        migrator.migrate_table_index_or_view(f'{Tables.Assessment}_SessionId')
        migrator.migrate_table_data(
            Tables.Assessment, f'State == {AssessmentState.Finished} AND IsTrialRun IS FALSE')

        for therapy in cfg.IMPORT_THERAPIES:
            tableName = therapy + 'Result'
            migrator.migrate_table_index_or_view(tableName)
            migrator.migrate_table_data(tableName, [])

        # Import data from redcap if enabled
        if cfg.REDCAP_IMPORT:
            try:
                RedcapImporter(migrator, out_conn).import_all_from_redcap()

            except Exception as e:
                print(
                    f'There was a problem while importing data from redcap:\n{e}')
                sys.exit(-2)
            insert_therapy_day(migrator)

        # Import all data, compute metrics and store results in analysis database
        processor = DataProcessor(in_conn, out_conn, migrator)
        processor.create_metric_info_table()
        with time_measured('result table creation'):
            combined_session_result_stmt_joins = processor.create_result_tables()
            processor.create_result_views(combined_session_result_stmt_joins)
        processor.compute_and_store_metrics(data_dir, polybox_upload_dir)

        create_therapy_view(migrator)
    finally:
        in_conn.close()
        out_conn.close()


def main(args):
    # profiler = Profiler()
    # profiler.start()
    if len(args) > 1:
        db_path = sys.argv[1]
    elif cfg.DB_PATH:
        db_path = cfg.DB_PATH
    elif cfg.USE_DB_FROM_UPLOAD_DIR and os.path.exists(cfg.PATH_TO_POLYBOX_UPLOAD_DIR):
        db_paths = os.listdir(os.path.join(
            cfg.PATH_TO_POLYBOX_UPLOAD_DIR, 'Database Backups'))
        if db_paths:
            db_path = os.path.join(
                cfg.PATH_TO_POLYBOX_UPLOAD_DIR, 'Database Backups', max(db_paths))
        else:
            db_path = 'db.db'
    else:
        db_path = 'db.db'

    import_and_process_everything(
        db_path, cfg.PATH_TO_POLYBOX_UPLOAD_DIR, cfg.PATH_TO_DATA_ROOT_DIR)
    # profiler.stop()
    # print(profiler.output_text(unicode=True, color=True))


if __name__ == '__main__':
    main(sys.argv)
