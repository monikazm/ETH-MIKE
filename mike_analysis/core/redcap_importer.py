import sqlite3
from collections import namedtuple
from typing import Dict, List

import pandas as pd

import mike_analysis.study_config as study_cfg
from mike_analysis.cfg import config as cfg
from mike_analysis.core.constants import SqlTypes, time_measured, RCCols
from mike_analysis.core.redcap_api import RedCap
from mike_analysis.core.table_migrator import TableMigrator


class RedcapImporter:
    ColumnCollection = namedtuple('ColumnCollection', ['key_cols', 'data_cols'])

    def __init__(self, table_migrator: TableMigrator, out_conn: sqlite3.Connection):
        self.migrator = table_migrator
        self.out_conn = out_conn
        self.rc = RedCap(api_url=cfg.REDCAP_URL, token=cfg.RECAP_API_TOKEN)

    def _create_redcap_table(self, columns: ColumnCollection, table_name: str, table_indices: List[str]):
        """
        Helper function to create a database table with the given name and columns.

        :param columns: tuple (List[key column names], List[other column names])
        :param table_name: name of the table to create
        :param table_indices: list of column names for which an index should be created in the database
        """
        redcap_column_defs = ',\n'.join([f'"{name}" {type_name}' for name, type_name in (columns.key_cols + columns.data_cols)])
        comma_separated_key_column_names = ', '.join(f'"{col}"' for col, _ in columns.key_cols)
        create_redcap_table_stmt = f'''
            CREATE TABLE "{table_name}" (
                {redcap_column_defs},
                PRIMARY KEY({comma_separated_key_column_names})
            )
        '''
        self.migrator.create_or_update_table_index_or_view_from_stmt(create_redcap_table_stmt)
        for index in table_indices:
            index_name = index.replace(',', '_').replace(' ', '')
            self.migrator.create_or_update_table_index_or_view_from_stmt(f'CREATE INDEX "{table_name}_{index_name}" ON {table_name} ({index})')

    def _create_tables_from_redcap_metadata(self) -> Dict[str, ColumnCollection]:
        """
        Create tables in the analysis db for all redcap forms.

        The table schemes are constructed dynamically based on metadata downloaded from the RedCap API.
        :return: dictionary which maps form name -> tuple (List[key column names], List[other column names])
        """
        # Request datadict over API
        redcap_columns = self.rc.export_columns(redcap_excluded_fields={study_cfg.REDCAP_RECORD_IDENTIFIER} | study_cfg.REDCAP_EXCLUDED_COLS)

        # Request form and event metadata
        repeating_forms_and_events = self.rc.export_repeating_events()
        repeating_events = repeating_forms_and_events[repeating_forms_and_events['form_name'].isna()]['event_name']
        repeating_forms = repeating_forms_and_events[repeating_forms_and_events['form_name'].notna()]['form_name']
        form_to_event_map = self.rc.export_event_map()

        # Split forms into different categories depending on whether they are repeated or not (-> different primary keys)
        # and build corresponding tables
        form_columns = {}
        for form in redcap_columns:
            if form not in study_cfg.REDCAP_NAMES_AND_INDEX_COLS:
                continue
            key_cols = [(study_cfg.REDCAP_RECORD_IDENTIFIER, 'integer not null')]
            form_events = form_to_event_map[form_to_event_map['form'] == form]['unique_event_name']

            # Include redcap_event_name if instrument appears in multiple events
            if len(form_events) > 1:
                key_cols.append((RCCols.EventName, f'varchar not null'))

            # Include redcap_repeat_instrument if form is repeated in any of the events
            form_is_repeated_in_any_event = (repeating_forms == form).any()
            if form_is_repeated_in_any_event:
                key_cols.append((RCCols.RepeatInstrument, 'varchar not null'))

            # Include redcap_repeat_instance for repeated forms and events
            if form_is_repeated_in_any_event or (form_events.isin(repeating_events)).any():
                key_cols.append((RCCols.RepeatInst, 'integer not null'))

            form_columns[form] = self.ColumnCollection(key_cols, redcap_columns[form])
            self._create_redcap_table(form_columns[form], *study_cfg.REDCAP_NAMES_AND_INDEX_COLS[form])
        return form_columns

    def _import_data_from_redcap(self, form_columns: Dict[str, ColumnCollection]):
        """
        Import record data from the RedCap API into the corresponding tables in the database.

        :param form_columns: dictionary which maps form name -> tuple (List[key column names], List[other column names])
        """

        # Get list of columns with a date type
        date_cols = [name for cols in form_columns.values() for name, t in cols.data_cols if t == SqlTypes.Date]

        # Download records from RedCap API
        data = self.rc.export_records(date_cols)

        # For each form, extract the relevant rows and columns from the record data frame and insert them
        # into the table corresponding to the form
        for form, columns in form_columns.items():
            data_col_names = [name for name, _ in columns.data_cols]
            all_col_names = [name for name, _ in columns.key_cols] + data_col_names

            # Extract relevant columns (for the current form)
            # Remove rows which do not contain any data for the current form
            # (Not all redcap records contain data for all forms)
            form_data = data.loc[:, all_col_names].dropna(how='all', subset=data_col_names)

            # Replace NULLs in key columns with 0/empty string (since primary key must not be NULL), in data columns with 'None'
            if RCCols.RepeatInst in form_data.columns:
                form_data.loc[:, RCCols.RepeatInst].fillna(0, inplace=True)
            if RCCols.RepeatInstrument in form_data.columns:
                form_data.loc[:, RCCols.RepeatInstrument].fillna('', inplace=True)
            form_data = form_data.replace({pd.NA: None})

            # Insert records into table
            form_table_name = study_cfg.REDCAP_NAMES_AND_INDEX_COLS[form][0]
            metric_column_names = ', '.join(all_col_names)
            insert_placeholder = ', '.join(['?' for _ in all_col_names])
            insert_stmt = f'INSERT OR REPLACE INTO "{form_table_name}" ({metric_column_names}) VALUES ({insert_placeholder})'
            self.out_conn.executemany(insert_stmt, form_data.values.tolist())
        self.out_conn.commit()

    def import_all_from_redcap(self):
        """Create tables in database based on RedCap metadata and populate them with record data from RedCap."""

        with time_measured('redcap metadata import and table creation'):
            form_columns = self._create_tables_from_redcap_metadata()
        with time_measured('redcap data import'):
            self._import_data_from_redcap(form_columns)
