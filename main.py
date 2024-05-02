from Lineage.data_lineage import DataLineageGraph
from Metadata.postgres_metadata import PostgresDatabaseMetadata
from Metadata.sqlserver_metadata import SQLServerDatabaseMetadata
from Metadata.oracle_metadata import OracleDatabaseMetadata


def postgres_lineage(host, database, username, password, port):
    postgres_metadata = PostgresDatabaseMetadata(host, database, username, password, port)
    try:
        postgres_metadata.connect()
        columns = postgres_metadata.fetch_table_metadata()
        constraints = postgres_metadata.fetch_table_constraints()
        views = postgres_metadata.fetch_view_dependencies()
        procedures = postgres_metadata.fetch_stored_procedures()
        data_lineage = DataLineageGraph(columns, constraints, views, procedures)
        data_lineage.draw_graph()
    finally:
        postgres_metadata.close()

def sqlserver_lineage(host, database, username, password, port):
    sql_server_metadata = SQLServerDatabaseMetadata(host, database, username, password, port)
    try:
        sql_server_metadata.connect()
        columns = sql_server_metadata.fetch_table_metadata()
        constraints = sql_server_metadata.fetch_table_constraints()
        views = sql_server_metadata.fetch_view_dependencies()
        procedures = sql_server_metadata.fetch_stored_procedures()
        data_lineage = DataLineageGraph(columns, constraints, views, procedures)
        data_lineage.draw_graph()
    finally:
        sql_server_metadata.close()

def oracle_lineage(host, database, username, password, port):
    oracle_metadata = OracleDatabaseMetadata(host, port, database, username, password)
    try:
        oracle_metadata.connect()
        columns = oracle_metadata.fetch_table_metadata()
        constraints = oracle_metadata.fetch_table_constraints()
        views = oracle_metadata.fetch_view_dependencies()
        procedures = oracle_metadata.fetch_stored_procedures()
        data_lineage = DataLineageGraph(columns, constraints, views, procedures, True)
        data_lineage.draw_graph()
    finally:
        oracle_metadata.close()


if __name__ == "__main__":
    postgres_lineage('localhost', 'bank', 'postgres', 'Mysecretpassword123!', 5431)
    sqlserver_lineage('localhost', 'bank', 'SA', 'Mysecretpassword123!', 1433)
    oracle_lineage('localhost', 'XE', 'system', 'Mysecretpassword123!', 1521)
