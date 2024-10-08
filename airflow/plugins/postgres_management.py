from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.engine.url import URL
import pandas as pd


class PostgresDatabaseManagement:
    def __init__(self, host, dbname, user, password, port=5431):
        self.database_url = URL.create(
            drivername='postgresql+psycopg2',
            username=user,
            password=password,
            host=host,
            port=port,
            database=dbname
        )
        self.engine = create_engine(self.database_url)
        self.Session = sessionmaker(bind=self.engine)
        self.session = None

    def connect(self):
        self.session = self.Session()
        print("Connected to the database - PostgreSQL.")

    def close(self):
        if self.session:
            self.session.close()
            print("Database connection closed.")

    def fetch_table_metadata(self):
        query = """
            SELECT
                c.table_name,
                c.column_name,
                c.data_type,
                t.table_type
            FROM
                information_schema.columns c
            JOIN
                information_schema.tables t
                ON c.table_name = t.table_name
                AND c.table_schema = t.table_schema
            WHERE
                c.table_schema NOT IN ('information_schema', 'pg_catalog');
        """
        result = self.engine.execute(query).fetchall()
        return result

    def fetch_table_constraints(self):
        query = """
        SELECT
            tc.table_name AS referencing_table,
            kcu.column_name AS referencing_column,
            ccu.table_name AS referenced_table,
            ccu.column_name AS referenced_column
        FROM
            information_schema.table_constraints AS tc
            JOIN information_schema.key_column_usage AS kcu
              ON tc.constraint_name = kcu.constraint_name
              AND tc.table_schema = kcu.table_schema
            JOIN information_schema.constraint_column_usage AS ccu
              ON ccu.constraint_name = tc.constraint_name
              AND ccu.table_schema = tc.table_schema
        WHERE tc.constraint_type = 'FOREIGN KEY';
        """
        result = self.engine.execute(query).fetchall()
        return result

    def fetch_view_dependencies(self):
        query = """
        SELECT
            view_name,
            table_name,
            column_name
        FROM
            information_schema.view_column_usage
        WHERE
            view_schema NOT IN ('information_schema', 'pg_catalog');
        """
        result = self.engine.execute(query).fetchall()
        return result

    def fetch_routines(self):
        query = """
        SELECT
            routine_name,
            routine_definition,
            routine_type
        FROM
            information_schema.routines
        WHERE
            routine_schema NOT IN ('pg_catalog', 'information_schema')
            AND routine_type IN ('PROCEDURE', 'FUNCTION');
        """
        result = self.engine.execute(query).fetchall()
        return result

    def fetch_metadata_for_model(self):
        query = """
            SELECT
                cols.table_name,
                cols.column_name,
                cols.data_type,
                cls.oid
            FROM
                information_schema.columns AS cols
            JOIN
                pg_class AS cls
            ON
                cols.table_name = cls.relname
            WHERE
                cols.table_schema NOT IN ('information_schema', 'pg_catalog');
        """
        result = self.engine.execute(query).fetchall()
        return pd.DataFrame(result, columns=['table_name', 'column_name', 'data_type', 'oid'])
