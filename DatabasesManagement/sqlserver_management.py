import pyodbc


class SQLServerDatabaseManagement:
    def __init__(self, server, database, username, password, port=1433):
        self.server = server
        self.database = database
        self.username = username
        self.password = password
        self.port = port
        self.conn = None

    def connect(self):
        conn_str = f"DRIVER=ODBC Driver 17 for SQL Server;SERVER={self.server};DATABASE={self.database};UID={self.username};PWD={self.password}"
        self.conn = pyodbc.connect(conn_str)
        print("Connected to the database - SQL Server.")

    def close(self):
        if self.conn:
            self.conn.close()
            print("Database connection closed.")

    def fetch_table_metadata(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                SELECT
                    TABLE_SCHEMA,
                    TABLE_NAME,
                    COLUMN_NAME,
                    DATA_TYPE,
                    IS_NULLABLE,
                    COLUMN_DEFAULT
                FROM
                    INFORMATION_SCHEMA.COLUMNS;
            """)
            return cur.fetchall()

    def fetch_table_constraints(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                SELECT
                    tc.CONSTRAINT_NAME,
                    tc.TABLE_SCHEMA,
                    tc.TABLE_NAME,
                    kcu.COLUMN_NAME,
                    tc.CONSTRAINT_TYPE
                FROM
                    INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS tc
                    JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS kcu
                    ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
                    AND tc.TABLE_SCHEMA = kcu.TABLE_SCHEMA;
            """)
            return cur.fetchall()

    def fetch_view_dependencies(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                SELECT
                    VIEW_SCHEMA,
                    VIEW_NAME,
                    TABLE_SCHEMA,
                    TABLE_NAME
                FROM
                    INFORMATION_SCHEMA.VIEW_TABLE_USAGE;
            """)
            return cur.fetchall()

    def fetch_stored_procedures(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                SELECT
                    ROUTINE_SCHEMA,
                    ROUTINE_NAME,
                    DATA_TYPE,
                    ROUTINE_DEFINITION
                FROM
                    INFORMATION_SCHEMA.ROUTINES
                WHERE
                    ROUTINE_TYPE='PROCEDURE';
            """)
            return cur.fetchall()
