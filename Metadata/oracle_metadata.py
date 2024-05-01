import os
import cx_Oracle

class OracleDatabaseMetadata:
    def __init__(self, host, port, dbname, user, password):
        self.host = host
        self.port = port
        self.dbname = dbname
        self.user = user
        self.password = password
        self.conn = None

    def connect(self):
        base_dir = os.path.dirname(os.path.abspath(__file__))
        oracle_client_dir = os.path.join(base_dir, "oracle_client")
        cx_Oracle.init_oracle_client(lib_dir=oracle_client_dir)

        dsn_tns = cx_Oracle.makedsn(self.host, self.port, service_name=self.dbname)
        self.conn = cx_Oracle.connect(user=self.user, password=self.password, dsn=dsn_tns)
        print("Connected to the database - Oracle.")

    def close(self):
        if self.conn:
            self.conn.close()
            print("Database connection closed.")

    def fetch_table_metadata(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                SELECT
                    owner,
                    table_name,
                    column_name,
                    data_type,
                    nullable,
                    data_default
                FROM
                    all_tab_columns
                WHERE
                    owner NOT IN ('SYS', 'SYSTEM')
            """)
            return cur.fetchall()

    def fetch_table_constraints(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                SELECT
                    acc.constraint_name,
                    acc.owner,
                    acc.table_name,
                    acc.column_name,
                    ac.constraint_type
                FROM 
                    all_cons_columns acc 
                    JOIN all_constraints ac ON acc.constraint_name = ac.constraint_name
                WHERE
                    ac.constraint_type IN ('P', 'R', 'U')
                    AND acc.owner NOT IN ('SYS', 'SYSTEM')
            """)
            return cur.fetchall()

    def fetch_view_dependencies(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                SELECT
                    name as view_name,
                    owner,
                    referenced_owner,
                    referenced_name
                FROM
                    all_dependencies
                WHERE
                    type = 'VIEW'
                    AND owner NOT IN ('SYS', 'SYSTEM')
            """)
            return cur.fetchall()


    def fetch_stored_procedures(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                SELECT
                    name as object_name,
                    owner,
                    type,
                    text
                FROM
                    all_source
                WHERE
                    type = 'PROCEDURE'
                    AND owner NOT IN ('SYS', 'SYSTEM')
            """)
            return cur.fetchall()
