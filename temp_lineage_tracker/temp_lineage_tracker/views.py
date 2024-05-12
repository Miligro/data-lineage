import json
import logging
from django.views import View
from django.conf import settings
from django.http import JsonResponse
from DatabasesManagement.postgres_management import PostgresDatabaseManagement
from DatabasesManagement.sqlserver_management import SQLServerDatabaseManagement
from DatabasesManagement.oracle_management import OracleDatabaseManagement


class BaseDatabaseView(View):
    def __init__(self):
        super().__init__()
        self.postgres_db = self.get_database_connection("postgres")
        self.oracle_db = self.get_database_connection("oracle")
        self.sql_server_db = self.get_database_connection("sqlserver")

    def get_database_connection(self, db_name):
        db_settings = settings.DATABASES[db_name]
        host = db_settings['HOST']
        dbname = db_settings['NAME']
        user = db_settings['USER']
        port = db_settings['PROT']
        password = db_settings['PASSWORD']

        if db_settings['ENGINE'] == 'django.db.backends.postgresql':
            return PostgresDatabaseManagement(host=host, dbname=dbname, user=user, password=password, port=port)
        elif db_settings['ENGINE'] == 'django.db.backends.oracle':
            return OracleDatabaseManagement(host=host, port=port, dbname=dbname, user=user, password=password)
        elif db_settings['ENGINE'] == 'mssql':
            return SQLServerDatabaseManagement(host=host, dbname=dbname, user=user, password=password, port=port)

    def connect_to_databases(self):
        self.postgres_db.connect()
        self.oracle_db.connect()
        self.sql_server_db.connect()



class ListDatabasesView(BaseDatabaseView):
    def get(self, request):
        database_ids = {
            'postgres': 'POS01',
            'oracle': 'ORA02',
            'sql_server': 'SRV03'
        }
        return JsonResponse(database_ids)


class CheckExtensionInstalledView(BaseDatabaseView):
    def get(self, request, database_id):
        if database_id == 'POS01':
            is_installed = self.postgres_db.check_extension_installed()
        elif database_id == 'ORA02':
            # is_installed = self.oracle_db.check_extension_installed()
            pass
        elif database_id == 'SRV03':
            is_installed = self.sql_server_db.check_extension_installed()
        else:
            return JsonResponse({'error': 'Invalid database ID'}, status=400)

        return JsonResponse({'is_installed': is_installed})


class InstallExtensionView(BaseDatabaseView):
    def install_extension(self, db_metadata):
        try:
            db_metadata.create_system_operations_with_query_table()
            db_metadata.create_system_operations_with_dependencies()
            db_metadata.handle_create_table_as_function()
            db_metadata.create_table_as_trigger()
            db_metadata.handle_create_view_function()
            db_metadata.create_view_trigger()
            return True
        except Exception as e:
            logging.error('Install ext. error: %s', e, exc_info=True)
            return False

    def install_sql_server_extension(self):
        success = self.install_extension(self.sql_server_db)

        if success:
            try:
                self.sql_server_db.create_temp_table_extended_event()
                return True
            except Exception as e:
                logging.error('SQL Server adj. error: %s', e, exc_info=True)
                return False
        else:
            return False

    def install_postgres_extension(self):
        return self.install_extension(self.postgres_db)

    def install_oracle_extension(self):
        return self.install_extension(self.oracle_db)

    def post(self, request, database_id):
        if database_id == 'POS01':
            success = self.install_postgres_extension()
        elif database_id == 'ORA02':
            # success = self.install_oracle_extension()
            pass
        elif database_id == 'SRV03':
            success = self.install_sql_server_extension()
        else:
            return JsonResponse({'error': 'Invalid database ID'}, status=400)

        if success:
            return JsonResponse({'message': 'Extension installed successfully'})
        else:
            return JsonResponse({'error': 'Extension installation failed'}, status=500)


class ProcessLineageView(BaseDatabaseView):
    def get(self, request, database_id):
        if database_id == 'POS01':
            return self.process_postgres_lineage()
        elif database_id == 'ORA02':
            return self.process_oracle_lineage()
        elif database_id == 'SRV03':
            return self.process_sql_server_lineage()
        else:
            return JsonResponse({'error': 'Invalid database ID'}, status=400)

    def process_postgres_lineage(self):
        self.postgres_db.operations_with_query_to_dependencies()
        columns = self.postgres_db.fetch_table_metadata()
        constraints = self.postgres_db.fetch_table_constraints()
        views = self.postgres_db.fetch_view_dependencies()
        procedures = self.postgres_db.fetch_stored_procedures()
        operations = self.postgres_db.fetch_system_operations()

        return self.convert_to_json(columns, constraints, views, procedures, operations)
        
    def process_oracle_lineage(self):
        columns = self.oracle_db.fetch_table_metadata()
        constraints = self.oracle_db.fetch_table_constraints()
        views = self.oracle_db.fetch_view_dependencies()
        procedures = self.oracle_db.fetch_stored_procedures()

        return self.convert_to_json(columns, constraints, views, procedures, [])
        
    def process_sql_server_lineage(self):
        self.sql_server_db.insert_from_events_file()
        self.sql_server_db.operations_with_query_to_dependencies()
        columns = self.sql_server_db.fetch_table_metadata()
        constraints = self.sql_server_db.fetch_table_constraints()
        views = self.sql_server_db.fetch_view_dependencies()
        procedures = self.sql_server_db.fetch_stored_procedures()
        operations = self.sql_server_db.fetch_system_operations()
        
        return self.convert_to_json(columns, constraints, views, procedures, operations)

    def convert_to_json(columns, constraints, views, procedures, operations):
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

        # TODO
        # for procedure in procedures:
        #     procedure_name = procedure[1]
        #     cleaned_query = data_lineage_graph.clean_query(procedure[3])
        #     results = data_lineage_graph.parse_procedure(procedure_name, cleaned_query)
        #     for result in results:
        #         if len(result) == 3:
        #             source = result[0]
        #             target = result[1]
        #             edge_id = f"{source}_{target}"
        #             edges_json.append({"data": {"id": edge_id, "source": source, "target": target}})

        for operation in operations:
            _, object_name, object_parent_name = operation

            if object_name not in tables_names:
                tables_names.append(object_name)
                
            if object_parent_name not in tables_names:
                tables_names.append(object_parent_name)

            edge_id = f"{object_parent_name}_{object_name}"
            edges_json.append({"data": {"id": edge_id, "source": object_parent_name, "target": object_name}})
        
        for table_name in tables_names:
            nodes_json.append({"data": {"id": table_name, "label": table_name}})

        return json.dumps({"nodes": nodes_json, "edges": edges_json}, indent=4)

