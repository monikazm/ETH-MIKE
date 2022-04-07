import os
import sqlite3
import sys
import pathlib
import importlib

import pandas as pd
# from pyinstrument import Profiler

from mike_analysis.cfg import config as user_cfg
from mike_analysis.core.data_processor import DataProcessor
from mike_analysis.core.constants import Tables, time_measured, AssessmentState
from mike_analysis.core.redcap_importer import RedcapImporter
from mike_analysis.core.sqlite_migrator import SQLiteMigrator
from mike_analysis.core.redcap_view_creator import insert_therapy_day, create_therapy_view, create_assessment_view, create_usability_view
from mike_analysis.core.frontend_migration import migrate_specified_frontend_content


def import_and_process_everything(db_path: str, polybox_upload_dir: str, data_dir: str):
    # Load study config
    study_cfg = importlib.import_module(
        "mike_analysis.study_config." + user_cfg.STUDY_CONFIG)

    def ts_adapter(timestamp: pd.Timestamp) -> str:
        return pd.to_datetime(timestamp).strftime('%Y-%m-%d')
    sqlite3.register_adapter(pd.Timestamp, ts_adapter)

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
        # Provides interface to migratze data from the front end db to the output analysis db
        migrator = SQLiteMigrator(in_conn, out_conn)

        # Migrates elements specified in config
        migrate_specified_frontend_content(migrator, study_cfg)

        # Import data from redcap if enabled

        if user_cfg.REDCAP_IMPORT:
            RedcapImporter(migrator, out_conn,
                           study_cfg).import_all_from_redcap()

        # Import all data, compute metrics and store results in analysis database
        processor = DataProcessor(in_conn, out_conn, migrator, study_cfg)
        processor.create_metric_info_table()
        with time_measured('result table creation'):
            combined_session_result_stmt_joins = processor.create_result_tables()
            processor.create_result_views(combined_session_result_stmt_joins)
        processor.compute_and_store_metrics(data_dir, polybox_upload_dir)

        if (user_cfg.STUDY_CONFIG != 'ksa_longitudinal_study' and user_cfg.REDCAP_IMPORT):
            study_cfg.create_study_views(migrator)

    finally:
        in_conn.close()
        out_conn.close()


def main(args):
    # profiler = Profiler()
    # profiler.start()
    if len(args) > 1:
        db_path = sys.argv[1]
    elif user_cfg.DB_PATH:
        db_path = user_cfg.DB_PATH
    elif user_cfg.USE_DB_FROM_UPLOAD_DIR and os.path.exists(user_cfg.PATH_TO_POLYBOX_UPLOAD_DIR):
        db_paths = os.listdir(os.path.join(
            user_cfg.PATH_TO_POLYBOX_UPLOAD_DIR, 'Database Backups'))
        if db_paths:
            db_path = os.path.join(
                user_cfg.PATH_TO_POLYBOX_UPLOAD_DIR, 'Database Backups', max(db_paths))
        else:
            db_path = 'db.db'
    else:
        db_path = 'db.db'

    import_and_process_everything(
        db_path, user_cfg.PATH_TO_POLYBOX_UPLOAD_DIR, user_cfg.PATH_TO_DATA_ROOT_DIR)
    # profiler.stop()
    # print(profiler.output_text(unicode=True, color=True))


if __name__ == '__main__':
    main(sys.argv)
