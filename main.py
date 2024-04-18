from data_lineage import DataLineageGraph
from postgres_metadata import PostgresDatabaseMetadata


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

