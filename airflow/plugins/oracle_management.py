from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker


class OracleDatabaseManagement:
    def __init__(self, host, port, dbname, user, password):
        self.host = host
        self.port = port
        self.dbname = dbname
        self.user = user
        self.password = password
        self.engine = None
        self.Session = None

    def connect(self):
        dsn = f"oracle+cx_oracle://{self.user}:{self.password}@{self.host}:{self.port}/?service_name={self.dbname}"
        self.engine = create_engine(dsn, echo=True)
        self.Session = sessionmaker(bind=self.engine)
        print("Connected to the database - Oracle.")

    def close(self):
        if self.engine:
            self.engine.dispose()
            print("Database connection closed.")

    def fetch_table_metadata(self):
        query = """
        SELECT
            atc.table_name,
            atc.column_name,
            atc.data_type,
            ao.object_type
        FROM
            all_tab_columns atc
        JOIN
            all_objects ao
        ON
            atc.owner = ao.owner AND atc.table_name = ao.object_name
        WHERE
            NOT (atc.owner LIKE '%SYS%' OR atc.owner LIKE 'SYS%' OR atc.owner LIKE '%SYS')
            AND NOT (atc.owner LIKE '%ADMIN%' OR atc.owner LIKE 'ADMIN%' OR atc.owner LIKE '%ADMIN')
            AND NOT (atc.owner LIKE '%DBS%' OR atc.owner LIKE 'DBS%' OR atc.owner LIKE '%DBS')
            AND atc.owner NOT IN ('OUTLN', 'XDB', 'REMOTE_SCHEDULER_AGENT')
        """
        result = self.engine.execute(query).fetchall()
        return result

    def fetch_table_constraints(self):
        query = """
        SELECT
            acc.table_name  AS referencing_table,
            acc.column_name  AS referencing_column,
            rcc.table_name AS referenced_table,
            rcc.column_name AS referenced_column
        FROM
            all_cons_columns acc
            JOIN all_constraints ac ON acc.constraint_name = ac.constraint_name
            LEFT JOIN all_cons_columns rcc
                ON ac.r_constraint_name = rcc.constraint_name
                AND ac.constraint_type = 'R'
        WHERE
            ac.constraint_type = 'R'
            AND NOT (acc.owner LIKE '%SYS%' OR acc.owner LIKE 'SYS%' OR acc.owner LIKE '%SYS')
            AND NOT (acc.owner LIKE '%ADMIN%' OR acc.owner LIKE 'ADMIN%' OR acc.owner LIKE '%ADMIN')
            AND NOT (acc.owner LIKE '%DBS%' OR acc.owner LIKE 'DBS%' OR acc.owner LIKE '%DBS')
            AND acc.owner NOT IN ('OUTLN', 'XDB', 'REMOTE_SCHEDULER_AGENT')
        ORDER BY acc.owner, acc.table_name, acc.constraint_name
        """
        result = self.engine.execute(query).fetchall()
        return result

    def fetch_view_dependencies(self):
        query = """
        SELECT
            ad.name AS view_name,
            ad.referenced_name AS table_name,
            atc.column_name
        FROM
            all_dependencies ad
            JOIN all_tab_columns atc
              ON ad.referenced_name = atc.table_name
        WHERE
            ad.type = 'VIEW'
            AND NOT (ad.owner LIKE '%SYS%' OR ad.owner LIKE 'SYS%' OR ad.owner LIKE '%SYS')
            AND NOT (ad.owner LIKE '%ADMIN%' OR ad.owner LIKE 'ADMIN%' OR ad.owner LIKE '%ADMIN')
            AND NOT (ad.owner LIKE '%DBS%' OR ad.owner LIKE 'DBS%' OR ad.owner LIKE '%DBS')
            AND ad.owner NOT IN ('OUTLN', 'XDB', 'REMOTE_SCHEDULER_AGENT')
        """
        result = self.engine.execute(query).fetchall()
        return result

    def fetch_routines(self):
        query = """
        SELECT
            name as object_name,
            text as routine_definition,
            type as routine_type
        FROM
            all_source
        WHERE
            type IN ('PROCEDURE', 'FUNCTION')
            AND NOT (owner LIKE '%SYS%' OR owner LIKE 'SYS%' OR owner LIKE '%SYS')
            AND NOT (owner LIKE '%ADMIN%' OR owner LIKE 'ADMIN%' OR owner LIKE '%ADMIN')
            AND NOT (owner LIKE '%DBS%' OR owner LIKE 'DBS%' OR owner LIKE '%DBS')
            AND owner NOT IN ('OUTLN', 'XDB', 'REMOTE_SCHEDULER_AGENT', 'DVF')
        """
        result = self.engine.execute(query).fetchall()
        return result

    def fetch_metadata_for_model(self):
        query = """
        SELECT
            cols.table_name,
            cols.column_name,
            cols.data_type,
            cls.object_id
        FROM
            all_tab_columns cols
        JOIN
            all_objects cls
        ON
            cols.table_name = cls.object_name
        WHERE
            cls.object_type = 'TABLE'
            AND NOT (cols.owner LIKE '%SYS%' OR cols.owner LIKE 'SYS%' OR cols.owner LIKE '%SYS')
            AND NOT (cols.owner LIKE '%ADMIN%' OR cols.owner LIKE 'ADMIN%' OR cols.owner LIKE '%ADMIN')
            AND NOT (cols.owner LIKE '%DBS%' OR cols.owner LIKE 'DBS%' OR cols.owner LIKE '%DBS')
            AND cols.owner NOT IN ('OUTLN', 'XDB', 'REMOTE_SCHEDULER_AGENT', 'DVF')
        """
        result = self.engine.execute(query).fetchall()
        return result
