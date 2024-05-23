import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.engine.url import URL

class SQLServerDatabaseManagement:
    def __init__(self, host, dbname, user, password, port=1433):
        self.database_url = URL.create(
            drivername='mssql+pyodbc',
            username=user,
            password=password,
            host=host,
            port=port,
            database=dbname
        )
        self.database_url.query['driver'] = 'ODBC+Driver+17+for+SQL+Server'
        self.engine = create_engine(self.database_url)
        self.Session = sessionmaker(bind=self.engine)
        self.session = None

    def connect(self):
        self.session = self.Session()
        print("Connected to the database - SQL Server.")

    def close(self):
        if self.session:
            self.session.close()
            print("Database connection closed.")

    def fetch_table_metadata(self):
        query = """
            SELECT
                c.TABLE_NAME,
                c.COLUMN_NAME,
                c.DATA_TYPE,
                t.TABLE_TYPE
            FROM
                INFORMATION_SCHEMA.COLUMNS c
            JOIN
                INFORMATION_SCHEMA.TABLES t
                ON c.TABLE_NAME = t.TABLE_NAME
                AND c.TABLE_SCHEMA = t.TABLE_SCHEMA;
        """
        result = self.engine.execute(query).fetchall()
        return result

    def fetch_table_constraints(self):
        query = """
        SELECT
            tc.TABLE_SCHEMA,
            tc.TABLE_NAME AS referencing_table,
            kcu.COLUMN_NAME AS referencing_column,
            ccu.TABLE_NAME AS referenced_table,
            ccu.COLUMN_NAME AS referenced_column,
        FROM
            INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS tc
            JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS kcu
            ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
            AND tc.TABLE_SCHEMA = kcu.TABLE_SCHEMA
            JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS ccu
            ON ccu.CONSTRAINT_NAME = tc.CONSTRAINT_NAME
            AND ccu.TABLE_SCHEMA = tc.TABLE_SCHEMA
        WHERE tc.CONSTRAINT_TYPE = 'FOREIGN KEY';
        """
        result = self.engine.execute(query).fetchall()
        return result


    def fetch_view_dependencies(self):
        query = """
        SELECT
            VIEW_NAME,
            TABLE_SCHEMA,
            TABLE_NAME,
            COLUMN_NAME
        FROM
            INFORMATION_SCHEMA.VIEW_COLUMN_USAGE;
        """
        result = self.engine.execute(query).fetchall()
        return result


    def fetch_stored_procedures(self):
        query = """
        SELECT
            ROUTINE_NAME,
            DATA_TYPE,
            ROUTINE_DEFINITION,
            ROUTINE_TYPE
        FROM
            INFORMATION_SCHEMA.ROUTINES
        WHERE
            ROUTINE_TYPE='PROCEDURE';
        """
        result = self.engine.execute(query).fetchall()
        return result

    def fetch_stored_functions(self):
        query = """
        SELECT
            ROUTINE_NAME,
            DATA_TYPE,
            ROUTINE_DEFINITION,
            ROUTINE_TYPE
        FROM
            INFORMATION_SCHEMA.ROUTINES
        WHERE
            ROUTINE_TYPE='FUNCTION';
        """
        result = self.engine.execute(query).fetchall()
        return result

    def fetch_metadata_for_model(self):
        query = """
        SELECT
            c.TABLE_NAME,
            c.COLUMN_NAME,
            c.DATA_TYPE,
            t.object_id AS oid
        FROM
            INFORMATION_SCHEMA.COLUMNS AS c
        JOIN
            sys.tables AS t
        ON
            c.TABLE_NAME = t.name;
        """
        result = self.engine.execute(query).fetchall()
        return pd.DataFrame(result, columns=['table_name', 'column_name', 'data_type', 'oid'])
