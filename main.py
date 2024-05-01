from Lineage.data_lineage import DataLineageGraph
from Metadata.postgres_metadata import PostgresDatabaseMetadata
from Metadata.sqlserver_metadata import SQLServerDatabaseMetadata
from Metadata.oracle_metadata import OracleDatabaseMetadata


def postgres_lineage():
    postgres_metadata = PostgresDatabaseMetadata('localhost', 'bank', 'postgres', 'Mysecretpassword123!', 5431)
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

def sqlserver_lineage():
    sql_server_metadata = SQLServerDatabaseMetadata('localhost', 'bank', 'SA', 'Mysecretpassword123!')
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

def oracle_lineage():
    oracle_metadata = OracleDatabaseMetadata('localhost', 1521, 'XE', 'system', 'Mysecretpassword123!')
    try:
        oracle_metadata.connect()
        columns = oracle_metadata.fetch_table_metadata()
        constraints = oracle_metadata.fetch_table_constraints()
        views = oracle_metadata.fetch_view_dependencies()
        procedures = oracle_metadata.fetch_stored_procedures()
        data_lineage = DataLineageGraph(columns, constraints, views, procedures)
        data_lineage.draw_graph()
    finally:
        oracle_metadata.close()


if __name__ == "__main__":
    postgres_lineage()
    sqlserver_lineage()
    oracle_lineage()
