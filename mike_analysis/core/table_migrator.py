import re
import sqlite3


class TableMigrator:
    extract_type_pattern = re.compile(r'CREATE (?:UNIQUE )?([A-Z]+) ')

    def __init__(self, input_conn: sqlite3.Connection, output_conn: sqlite3.Connection):
        self.in_conn = input_conn
        self.out_conn = output_conn

    @staticmethod
    def get_original_create_stmt(element_name: str, conn: sqlite3.Connection) -> str:
        ret = conn.execute(f"SELECT sql FROM sqlite_master WHERE name == '{element_name}'").fetchone()
        return '' if ret is None else ret[0]

    def migrate_table_index_or_view(self, element_name: str):
        create_stmt = self.get_original_create_stmt(element_name, self.in_conn).replace('autoincrement', '')
        self.create_or_replace_table_index_or_view_from_stmt(element_name, create_stmt)

    def create_or_replace_table_index_or_view_from_stmt(self, element_name: str, create_stmt: str):
        create_elem_stmt_in = re.sub(r'\s+', ' ', create_stmt.strip())
        create_elem_stmt_out = re.sub(r'\s+', ' ', self.get_original_create_stmt(element_name, self.out_conn).strip())

        match = self.extract_type_pattern.search(create_elem_stmt_in)
        kind = match.group(1)

        if create_elem_stmt_in != create_elem_stmt_out:
            print(f'Updated {element_name}')
            if create_elem_stmt_out != '':
                self.out_conn.execute(f'DROP {kind} {element_name}')
            self.out_conn.execute(create_elem_stmt_in)

    def migrate_table_data(self, table_name: str):
        entries = self.in_conn.execute(f'''
                SELECT * FROM {table_name}
        ''').fetchall()
        if entries:
            placeholder = f"({', '.join(['?' for _ in entries[0]])})"
            self.out_conn.executemany(f'INSERT OR IGNORE INTO {table_name} VALUES {placeholder}', entries)
        self.out_conn.commit()

    def out_get_all_columns_except(self, table, ignore_list):
        return [elem[1] for elem in self.out_conn.execute(f'PRAGMA table_info({table});').fetchall() if elem[1] not in ignore_list]
