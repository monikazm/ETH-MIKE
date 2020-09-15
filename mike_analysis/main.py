import os
import sqlite3
import sys
import pathlib

import pandas as pd
# from pyinstrument import Profiler

from mike_analysis.cfg import config as cfg
from mike_analysis.core.data_processor import DataProcessor
from mike_analysis.core.meta import Tables, time_measured
from mike_analysis.core.redcap_importer import RedcapImporter
from mike_analysis.core.table_migrator import TableMigrator


def import_and_process_everything(db_path: str, polybox_upload_dir: str, data_dir: str):
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
    migrator.migrate_table_index_or_view(Tables.Patient)
    migrator.migrate_table_index_or_view(f'{Tables.Patient}_SubjectNr')
    migrator.migrate_table_data(Tables.Patient)
    migrator.migrate_table_index_or_view(Tables.Session)
    migrator.migrate_table_index_or_view(f'{Tables.Session}_PatientId')
    migrator.migrate_table_data(Tables.Session)

    if cfg.REDCAP_IMPORT:
        RedcapImporter(migrator, out_conn).import_all_from_redcap()

    processor = DataProcessor(in_conn, out_conn, migrator)
    with time_measured('result table creation'):
        combined_session_result_stmt_joins = processor.create_result_tables()
        processor.create_result_view(combined_session_result_stmt_joins)
    processor.compute_and_store_metrics(data_dir, polybox_upload_dir)


def main(args):
    # profiler = Profiler()
    # profiler.start()
    if len(args) > 1:
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

    import_and_process_everything(db_path, cfg.PATH_TO_POLYBOX_UPLOAD_DIR, cfg.PATH_TO_DATA_ROOT_DIR)
    # profiler.stop()
    # print(profiler.output_text(unicode=True, color=True))


if __name__ == '__main__':
    main(sys.argv)
