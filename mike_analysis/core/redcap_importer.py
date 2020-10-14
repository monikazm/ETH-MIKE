import sqlite3
import sys
from collections import namedtuple
from typing import Dict

import pandas as pd

import mike_analysis.study_config as study_cfg
from mike_analysis.cfg import config as cfg
from mike_analysis.core.constants import SqlTypes, time_measured
from mike_analysis.core.redcap_api import RedCap
from mike_analysis.core.table_migrator import TableMigrator


class RedcapImporter:
    ColumnCollection = namedtuple('ColumnCollection', ['key_cols', 'data_cols'])

    def __init__(self, table_migrator: TableMigrator, out_conn: sqlite3.Connection):
        self.migrator = table_migrator
        self.out_conn = out_conn
        self.rc = RedCap(api_url=cfg.REDCAP_URL, token=cfg.RECAP_API_TOKEN)

    def _create_redcap_table(self, columns, key_cols, table_name, table_indices):
        redcap_column_defs = ',\n'.join([f'"{name}" {type_name}' for name, type_name in columns])
        comma_separated_key_column_names = ', '.join(f'"{col}"' for col in key_cols)
        create_redcap_table_stmt = f'''
            CREATE TABLE "{table_name}" (
                {redcap_column_defs},
                PRIMARY KEY({comma_separated_key_column_names})
            )
        '''
        self.migrator.create_or_update_table_index_or_view_from_stmt(create_redcap_table_stmt)
        for index in table_indices:
            self.migrator.create_or_update_table_index_or_view_from_stmt(f'CREATE INDEX {table_name}_{index} ON {table_name} ({index})')

    def _create_tables_from_redcap_metadata(self) -> Dict[str, ColumnCollection]:
        # Request datadict over API
        redcap_columns = self.rc.export_columns(redcap_excluded_fields={study_cfg.REDCAP_RECORD_IDENTIFIER} | study_cfg.REDCAP_EXCLUDED_COLS)

        # Request form and event metadata
        repeating_forms_and_events = self.rc.export_repeating_events()
        repeating_events = repeating_forms_and_events[repeating_forms_and_events['event_name'].notna()]['event_name'].unique()
        if repeating_forms_and_events[repeating_forms_and_events['form_name'].notna()]['form_name'].unique().size > 0:
            print('WARNING, mike_analysis does not support repeating forms/instruments yet')
            sys.exit(1)
        event_map = self.rc.export_event_map()

        # Split forms into different categories depending on whether they are repeated or not (-> different primary keys)
        # and build corresponding tables
        form_columns = {}
        for form in redcap_columns.keys():
            events = event_map[event_map['form'] == form]
            if events.loc[:, 'unique_event_name'].isin(repeating_events).any():
                key = [(study_cfg.REDCAP_RECORD_IDENTIFIER, 'integer not null'), ('redcap_event_name', 'varchar not null'),
                       ('redcap_repeat_instance', 'integer not null')]
            elif len(events) > 1:
                key = [(study_cfg.REDCAP_RECORD_IDENTIFIER, 'integer not null'), ('redcap_event_name', f'varchar not null')]
            else:
                key = [(study_cfg.REDCAP_RECORD_IDENTIFIER, 'integer not null'), ]

            form_columns[form] = self.ColumnCollection(key, redcap_columns[form])
            self._create_redcap_table(form_columns[form].key_cols + form_columns[form].data_cols, [name for name, _ in key], *study_cfg.REDCAP_NAMES_AND_INDEX_COLS[form])
        return form_columns

    def _import_data_from_redcap(self, form_columns: Dict[str, ColumnCollection]):
        # Build tables
        date_cols = [name for cols in form_columns.values() for name, t in cols.data_cols if t == SqlTypes.Date]
        data = self.rc.export_records(date_cols)
        for form, columns in form_columns.items():
            data_col_names = [name for name, _ in columns.data_cols]
            all_col_names = [name for name, _ in columns.key_cols] + data_col_names
            form_data = data.loc[:, all_col_names].dropna(how='all', subset=data_col_names)
            if 'redcap_repeat_instance' in form_data.columns:
                form_data.loc[:, 'redcap_repeat_instance'].fillna(0, inplace=True)
            form_data = form_data.replace({pd.NA: None})

            records = form_data.values.tolist()

            metric_column_names = ', '.join(all_col_names)
            insert_placeholder = f"({', '.join(['?' for _ in all_col_names])})"
            pretty_name = study_cfg.REDCAP_NAMES_AND_INDEX_COLS[form][0]
            insert_stmt = f'INSERT OR REPLACE INTO "{pretty_name}" ({metric_column_names}) VALUES {insert_placeholder}'
            self.out_conn.executemany(insert_stmt, records)
        self.out_conn.commit()

    def import_all_from_redcap(self):
        with time_measured('redcap metadata import and table creation'):
            form_columns = self._create_tables_from_redcap_metadata()
        with time_measured('redcap data import'):
            self._import_data_from_redcap(form_columns)
