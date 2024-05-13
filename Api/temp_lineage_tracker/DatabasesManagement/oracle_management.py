import os
import cx_Oracle


class OracleDatabaseManagement:
    def __init__(self, host, port, dbname, user, password):
        self.host = host
        self.port = port
        self.dbname = dbname
        self.user = user
        self.password = password
        self.conn = None
        self.init_oracle_client()
    
    def init_oracle_client(self):
        base_dir = os.path.dirname(os.path.abspath(__file__))
        oracle_client_dir = os.path.join(base_dir, "instantclient_19_9")
        cx_Oracle.init_oracle_client(lib_dir=oracle_client_dir)

    def connect(self):
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
                    NOT (owner LIKE '%SYS%' OR owner LIKE 'SYS%' OR owner LIKE '%SYS')
                    AND NOT (owner LIKE '%ADMIN%' OR owner LIKE 'ADMIN%' OR owner LIKE '%ADMIN')
                    AND NOT (owner LIKE '%DBS%' OR owner LIKE 'DBS%' OR owner LIKE '%DBS')
                    AND owner NOT IN ('OUTLN', 'XDB', 'REMOTE_SCHEDULER_AGENT')
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
                    AND NOT (acc.owner LIKE '%SYS%' OR acc.owner LIKE 'SYS%' OR acc.owner LIKE '%SYS')
                    AND NOT (acc.owner LIKE '%ADMIN%' OR acc.owner LIKE 'ADMIN%' OR acc.owner LIKE '%ADMIN')
                    AND NOT (acc.owner LIKE '%DBS%' OR acc.owner LIKE 'DBS%' OR acc.owner LIKE '%DBS')
                    AND acc.owner NOT IN ('OUTLN', 'XDB', 'REMOTE_SCHEDULER_AGENT')
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
                    AND NOT (owner LIKE '%SYS%' OR owner LIKE 'SYS%' OR owner LIKE '%SYS')
                    AND NOT (owner LIKE '%ADMIN%' OR owner LIKE 'ADMIN%' OR owner LIKE '%ADMIN')
                    AND NOT (owner LIKE '%DBS%' OR owner LIKE 'DBS%' OR owner LIKE '%DBS')
                    AND owner NOT IN ('OUTLN', 'XDB', 'REMOTE_SCHEDULER_AGENT')
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
                    AND NOT (owner LIKE '%SYS%' OR owner LIKE 'SYS%' OR owner LIKE '%SYS')
                    AND NOT (owner LIKE '%ADMIN%' OR owner LIKE 'ADMIN%' OR owner LIKE '%ADMIN')
                    AND NOT (owner LIKE '%DBS%' OR owner LIKE 'DBS%' OR owner LIKE '%DBS')
                    AND owner NOT IN ('OUTLN', 'XDB', 'REMOTE_SCHEDULER_AGENT')
            """)
            return cur.fetchall()
