import re
import sqlite3
from typing import List, Iterable


class SQLiteMigrator:
    extract_type_pattern = re.compile(
        r'CREATE (?:UNIQUE )?([A-Z]+) ((?:\w+)|(?:".+?"))')

    def __init__(self, input_conn: sqlite3.Connection, output_conn: sqlite3.Connection):
        self.in_conn = input_conn
        self.out_conn = output_conn

    @staticmethod
    def get_original_create_stmt(element_name: str, conn: sqlite3.Connection) -> str:
        ret = conn.execute(
            f"SELECT sql FROM sqlite_master WHERE name == '{element_name}'").fetchone()
        if ret is None:
            return ''
        else:
            try:
                return ret[0]
            except:
                return ret['sql']

    def out_has_tables(self, table_names: List[str]):
        entries = self.out_conn.execute(
            f"SELECT name FROM sqlite_master WHERE type='table' AND name IN ({','.join(['?']*len(table_names))})", table_names).fetchall()
        return len(entries) == len(table_names)

    # def create_table_in_output_db(self, table_name: str):

    #     self.out_conn.execute(
    #         f"CREATE TABLE IF NOT EXISTS " + table_name)

    def migrate_table_index_or_view(self, element_name: str, overwrite: bool = False):
        create_stmt = self.get_original_create_stmt(
            element_name, self.in_conn).replace('autoincrement', '')
        self.create_or_update_table_index_or_view_from_stmt(
            create_stmt, overwrite)

    def create_or_update_table_index_or_view_from_stmt(self, create_stmt: str, overwrite: bool = False):
        create_elem_stmt_in = re.sub(r'\s+', ' ', create_stmt.strip())
        match = self.extract_type_pattern.search(create_elem_stmt_in)
        if not match:
            raise RuntimeError(
                'Could not extract kind and name from create statement')
        kind = match.group(1)
        element_name = match.group(2)

        create_elem_stmt_out = re.sub(r'\s+', ' ', self.get_original_create_stmt(
            element_name.replace('"', ''), self.out_conn).strip())

        if create_elem_stmt_in != create_elem_stmt_out or overwrite:
            print(f'Updated {element_name}')
            if create_elem_stmt_out != '':
                with self.out_conn:  # Create transaction
                    self.out_conn.execute('BEGIN TRANSACTION;')
                    if kind == 'TABLE' and not overwrite:
                        # Create temporary table with same schema as original table
                        create_tmp_table = create_elem_stmt_out.replace(
                            match.group(0), 'CREATE TEMP TABLE tmp_migration')
                        self.out_conn.execute(create_tmp_table)

                        # Backup all data from the old table into the temp table
                        self.out_conn.execute(
                            f'INSERT INTO tmp_migration SELECT * FROM {element_name}')

                        # Drop the old table
                        self.out_conn.execute(f'DROP TABLE {element_name}')

                        # Create the new table
                        self.out_conn.execute(create_elem_stmt_in)

                        old_cols = self.out_get_all_columns_except(
                            'tmp_migration', ())
                        new_cols = self.out_get_all_columns_except(
                            element_name, ())
                        migrated_cols = ', '.join(
                            set(new_cols) & set(old_cols))

                        # Restore columns which still exist from backup
                        self.out_conn.execute(
                            f'INSERT INTO {element_name} ({migrated_cols}) SELECT {migrated_cols} FROM tmp_migration')

                        # Drop the temp table
                        self.out_conn.execute('DROP TABLE tmp_migration')
                    else:
                        self.out_conn.execute(f'DROP {kind} {element_name}')
                        # print(create_elem_stmt_in)
                        self.out_conn.execute(create_elem_stmt_in)
            else:
                self.out_conn.execute(create_elem_stmt_in)

    def migrate_table_data(self, table_name: str, filter_cond: str = ''):
        """
        Copy all rows which satisfy filter_cond (if any) and do not already exist from table 'table_name' in the input database
        to the table 'table_name' in the output database.
        """
        entries = self.in_conn.execute(f'''
                SELECT * FROM {table_name}
                {(f"WHERE {filter_cond}" if filter_cond else "")}
        ''').fetchall()
        if entries:
            placeholder = ', '.join(['?' for _ in entries[0]])
            self.out_conn.executemany(
                f'INSERT OR IGNORE INTO {table_name} VALUES ({placeholder})', entries)
        self.out_conn.commit()

    def out_get_all_columns_except(self, table: str, ignore_list: Iterable[str]) -> List[str]:
        """Return list of columns in table 'table' without columns in ignore_list."""
        return [elem[1] for elem in self.out_conn.execute(f'PRAGMA table_info({table});').fetchall() if elem[1] not in ignore_list]

    def columns_except(self, table: str, alias: str, ignore_list: Iterable[str]) -> str:
        """
        Return comma separated list of all column names (qualified by alias, e.g. {alias}.col1) from 'table' which are not in ignore_list.

        e.g. columns_except('Patient', 'P', ['PatientId', 'SubjectNr']) == 'P.Age, P.LeftImpaired, P.RightImpaired, ...'

        This function is useful when building a database query where you want to include all columns of a table EXCEPT some columns
        (cannot use wildcard * in that case).

        :param table: table in output database from which to take columns
        :param alias: will get prepended to column names (e.g. '{alias}.Col1, {alias}.Col2'),
                      can be empty string ('') to return unqualified column names ('Col1, Col2').
        :param ignore_list: List of column names which should be excluded from the result
        :return: comma separated list of selected (qualified) column names
        """
        prefix = f'{alias}.' if alias else ''
        return ', '.join([f'{prefix}{col}' for col in self.out_get_all_columns_except(table, ignore_list)])

    def migrate_table_and_index(self, table_name: str, index_name: str, filter_cond: str = ''):
        if table_name != '':
            print(table_name)
            self.migrate_table_index_or_view(table_name, overwrite=True)
            if index_name != '':
                self.migrate_table_index_or_view(index_name, overwrite=True)
            self.migrate_table_data(table_name, filter_cond)
