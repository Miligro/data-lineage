import psycopg2


class PostgresDatabaseMetadata:
    def __init__(self, host, dbname, user, password, port=5431):
        self.host = host
        self.dbname = dbname
        self.user = user
        self.password = password
        self.port = port
        self.conn = None

    def connect(self):
        self.conn = psycopg2.connect(
            host=self.host,
            dbname=self.dbname,
            user=self.user,
            password=self.password,
            port=self.port
        )
        print("Connected to the database - PostgreSQL.")

    def close(self):
        if self.conn:
            self.conn.close()
            print("Database connection closed.")

    def fetch_table_metadata(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                SELECT
                    table_schema,
                    table_name,
                    column_name,
                    data_type,
                    is_nullable,
                    column_default
                FROM
                    information_schema.columns
                WHERE
                    table_schema NOT IN ('information_schema', 'pg_catalog');
            """)
            return cur.fetchall()

    def fetch_table_constraints(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                SELECT
                    tc.constraint_name,
                    tc.table_schema,
                    tc.table_name,
                    kcu.column_name,
                    tc.constraint_type
                FROM 
                    information_schema.table_constraints AS tc 
                    JOIN information_schema.key_column_usage AS kcu 
                    ON tc.constraint_name = kcu.constraint_name
                    AND tc.table_schema = kcu.table_schema
                WHERE
                    tc.constraint_type IN ('PRIMARY KEY', 'FOREIGN KEY', 'UNIQUE')
                    AND tc.table_schema NOT IN ('information_schema', 'pg_catalog');
            """)
            return cur.fetchall()

    def fetch_view_dependencies(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                SELECT
                    view_schema,
                    view_name,
                    table_schema,
                    table_name
                FROM
                    information_schema.view_table_usage
                WHERE
                    view_schema NOT IN ('information_schema', 'pg_catalog');
            """)
            return cur.fetchall()

    def fetch_stored_procedures(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                SELECT
                    routine_schema,
                    routine_name,
                    data_type,
                    routine_definition
                FROM
                    information_schema.routines
                WHERE
                    routine_schema NOT IN ('pg_catalog', 'information_schema')
                    AND routine_type='PROCEDURE';
            """)
            return cur.fetchall()
