import json
from django.views import View
from django.conf import settings
from django.http import JsonResponse

from .DatabasesManagement.related_objects_extractor import SQLParser
from .DatabasesManagement.postgres_management import PostgresDatabaseManagement
from .DatabasesManagement.sqlserver_management import SQLServerDatabaseManagement
from .DatabasesManagement.oracle_management import OracleDatabaseManagement


def get_database_connection(db_name):
    db_settings = settings.DATABASES[db_name]
    host = db_settings['HOST']
    dbname = db_settings['NAME']
    user = db_settings['USER']
    port = db_settings['PORT']
    password = db_settings['PASSWORD']

    if db_settings['ENGINE'] == 'django.db.backends.postgresql':
        return PostgresDatabaseManagement(host=host, dbname=dbname, user=user, password=password, port=port)
    elif db_settings['ENGINE'] == 'django.db.backends.oracle':
        return OracleDatabaseManagement(host=host, port=port, dbname=dbname, user=user, password=password)
    elif db_settings['ENGINE'] == 'mssql':
        return SQLServerDatabaseManagement(server=host, database=dbname, username=user, password=password, port=port)


class BaseDatabaseView(View):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.postgres_db = get_database_connection("postgres")
        # self.oracle_db = get_database_connection("oracle")
        self.sql_server_db = get_database_connection("sqlserver")
        self.connect_to_databases()

    def connect_to_databases(self):
        self.postgres_db.connect()
        # self.oracle_db.connect()
        self.sql_server_db.connect()


class ListDatabasesView(BaseDatabaseView):
    def get(self, _):
        database_ids = {
            'databases': [
            {
                'id': 'POS01',
                'name': 'Postgres'
            },
            {
                'id': 'ORA02',
                'name': 'Oracle'
            },
            {
                'id': 'SRV03',
                'name': 'SQL Server'
            },
        ]}
        return JsonResponse(database_ids)


def convert_to_json(columns, constraints, views, procedures, functions):
    tables_names = []
    nodes_json = []
    edges_json = []

    for constraint in constraints:
        if constraint[4] == 'FOREIGN KEY' or constraint[4] == 'R':
            source = constraint[2]
            target = constraint[3].split('_')[0]

            if source not in tables_names:
                tables_names.append(source)

            if target not in tables_names:
                tables_names.append(target)

            edge_id = f"{source}_{target}"
            edges_json.append({"data": {"id": edge_id, "source": source, "target": target}})

    for view in views:
        source_view = view[1]
        target_table = view[3]

        if source_view not in tables_names:
            tables_names.append(source_view)

        if target_table not in tables_names:
            tables_names.append(target_table)

        edge_id = f"{target_table}_{source_view}"
        edges_json.append({"data": {"id": edge_id, "source": target_table, "target": source_view}})

    for procedure in procedures + functions:
        procedure_name = procedure[1]
        parser = SQLParser(procedure[3])
        print(procedure[3], end='\n\n\n')
        objects = parser.extract_related_objects()
        print(objects, end='\n\n\n')
        for obj in objects:
            if obj != procedure_name:
                if procedure_name not in tables_names:
                    tables_names.append(procedure_name)

                if obj not in tables_names:
                    tables_names.append(obj)

                edge_id = f"{procedure_name}_{obj}"
                edges_json.append({"data": {"id": edge_id, "source": procedure_name, "target": obj}})

    for table_name in tables_names:
        nodes_json.append({"data": {"id": table_name, "label": table_name}})

    return json.dumps({"nodes": nodes_json, "edges": edges_json}, indent=4)


def process_lineage(db_metadata):
    columns = db_metadata.fetch_table_metadata()
    constraints = db_metadata.fetch_table_constraints()
    views = db_metadata.fetch_view_dependencies()
    procedures = db_metadata.fetch_stored_procedures()
    functions = db_metadata.fetch_stored_functions()

    return convert_to_json(columns, constraints, views, procedures, functions)
    

class ProcessLineageView(BaseDatabaseView):
    def get(self, _, database_id):
        if database_id == 'POS01':
            return JsonResponse(json.loads(process_lineage(self.postgres_db)))
        elif database_id == 'ORA02':
            return JsonResponse(json.loads(process_lineage(self.oracle_db)))
        elif database_id == 'SRV03':
            return JsonResponse(json.loads(process_lineage(self.sql_server_db)))
        else:
            return JsonResponse({'error': 'Invalid database ID'}, status=400)
