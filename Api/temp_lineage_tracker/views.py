from django.shortcuts import get_object_or_404
from django.views import View
from django.http import JsonResponse
from django.db import models
from .models import Database, Object, ObjectRelationship, ObjectDetail, ObjectRelationshipDetail
import requests
import yaml
import os


AIRFLOW_URL = os.environ.get("AIRFLOW_BASE_URL") + '/api/v1/dags/{dag_id}/dagRuns'
AIRFLOW_USERNAME = os.environ.get("AIRFLOW_USERNAME")
AIRFLOW_PASSWORD = os.environ.get("AIRFLOW_PASSWORD")


class ListDatabasesView(View):
    def get(self, request):
        databases = Database.objects.select_related('ingest_status').all()
        databases_dict = {
            'databases': [{
                'id': db.id,
                'name': db.name,
                'ingest_status': {
                    'id': db.ingest_status.id,
                    'name': db.ingest_status.name
                } if db.ingest_status else None
            } for db in databases
            ]
        }
        return JsonResponse(databases_dict)


class ListObjectsView(View):
    def get(self, request, database_id):
        database = get_object_or_404(Database, id=database_id)
        objects = Object.objects.filter(database=database)
        response_data = {
            'database': {
                'id': database.id,
                'name': database.name
            },
            'objects': [
                {
                    'id': obj.id,
                    'name': obj.name,
                    'type': obj.type
                } for obj in objects
            ]
        }

        return JsonResponse(response_data)


class ListObjectRelationshipsView(View):
    def get(self, request, database_id, object_id):
        database = get_object_or_404(Database, id=database_id)
        obj = get_object_or_404(Object, database=database, id=object_id)

        relationships = ObjectRelationship.objects.filter(database=database).filter(
            models.Q(source_object=obj) | models.Q(target_object=obj)
        )

        objects_set = set()
        for relationship in relationships:
            objects_set.add((relationship.source_object.id, relationship.source_object.name, relationship.source_object.type))
            objects_set.add((relationship.target_object.id, relationship.target_object.name, relationship.target_object.type))

        object_ids = [object_t[0] for object_t in objects_set]
        object_details = ObjectDetail.objects.filter(database=database, object_id__in=object_ids)

        object_details_dict = {}
        for detail in object_details:
            if detail.object_id not in object_details_dict:
                object_details_dict[detail.object_id] = []
            object_details_dict[detail.object_id].append({
                'column_name': detail.column_name,
                'column_type': detail.column_type
            })

        relationship_ids = [rel.id for rel in relationships]
        relationship_details = ObjectRelationshipDetail.objects.filter(database=database,
                                                                       relation_id__in=relationship_ids)

        relationship_details_dict = {}
        for detail in relationship_details:
            if detail.relation_id not in relationship_details_dict:
                relationship_details_dict[detail.relation_id] = []
            relationship_details_dict[detail.relation_id].append({
                'column_name': detail.column_name
            })

        response_data = {
            'database': {
                'id': database.id,
                'name': database.name
            },
            'object': {
                'id': obj.id,
                'name': obj.name
            },
            'relationships': [
             {
                 'data': {
                     'id': f'{rel.source_object.id}-{rel.target_object.id}',
                     'source': rel.source_object.id,
                     'target': rel.target_object.id,
                     'connection_probability': rel.connection_probability,
                     'details': relationship_details_dict.get(rel.id, [])
                 },
             } for rel in relationships
            ]
            + [
             {
                 'data': {
                     'id': object_t[0],
                     'label': object_t[1],
                     'type': object_t[2],
                     'details': object_details_dict.get(object_t[0], [])
                 }
             } for object_t in objects_set
            ]
        }
        return JsonResponse(response_data)
    
class ListObjectRelationshipsTargetView(View):
    def get(self, request, database_id, object_id):
        database = get_object_or_404(Database, id=database_id)
        obj = get_object_or_404(Object, database=database, id=object_id)

        relationships = ObjectRelationship.objects.filter(database=database).filter(
            models.Q(target_object=obj)
        )

        objects_set = set()
        for relationship in relationships:
            objects_set.add((relationship.source_object.id, relationship.source_object.name, relationship.source_object.type))
            objects_set.add((relationship.target_object.id, relationship.target_object.name, relationship.target_object.type))

        object_ids = [object_t[0] for object_t in objects_set]
        object_details = ObjectDetail.objects.filter(database=database, object_id__in=object_ids)

        object_details_dict = {}
        for detail in object_details:
            if detail.object_id not in object_details_dict:
                object_details_dict[detail.object_id] = []
            object_details_dict[detail.object_id].append({
                'column_name': detail.column_name,
                'column_type': detail.column_type
            })

        relationship_ids = [rel.id for rel in relationships]
        relationship_details = ObjectRelationshipDetail.objects.filter(database=database,
                                                                       relation_id__in=relationship_ids)

        relationship_details_dict = {}
        for detail in relationship_details:
            if detail.relation_id not in relationship_details_dict:
                relationship_details_dict[detail.relation_id] = []
            relationship_details_dict[detail.relation_id].append({
                'column_name': detail.column_name
            })

        response_data = {
            'database': {
                'id': database.id,
                'name': database.name
            },
            'object': {
                'id': obj.id,
                'name': obj.name
            },
            'relationships': [
             {
                 'data': {
                     'id': f'{rel.source_object.id}-{rel.target_object.id}',
                     'source': rel.source_object.id,
                     'target': rel.target_object.id,
                     'connection_probability': rel.connection_probability,
                     'details': relationship_details_dict.get(rel.id, [])
                 },
             } for rel in relationships
            ]
            + [
             {
                 'data': {
                     'id': object_t[0],
                     'label': object_t[1],
                     'type': object_t[2],
                     'details': object_details_dict.get(object_t[0], [])
                 }
             } for object_t in objects_set
            ]
        }
        return JsonResponse(response_data)

class LineageModelView(View):
    def post(self, _, database_id):
        url = AIRFLOW_URL.format(dag_id='database_lineage')
        auth = (AIRFLOW_USERNAME, AIRFLOW_PASSWORD)
        payload = {
            "conf": {
                "database_id": database_id,
            }
        }
        response = requests.post(url, auth=auth, json=payload)

        if response.status_code == 200:
            return JsonResponse({'status': 'success', 'message': 'DAG triggered successfully'})
        else:
            return JsonResponse({'status': 'error', 'message': 'Failed to trigger DAG', 'details': response.json()})

    def get(self, _, database_id):
        url = AIRFLOW_URL.format(dag_id='database_lineage')
        auth = (AIRFLOW_USERNAME, AIRFLOW_PASSWORD)
        response = requests.get(url, auth=auth)

        if response.status_code == 200:
            data = response.json()
            if 'dag_runs' in data and data['dag_runs']:
                last_run = data['dag_runs'][-1]
                start_date = last_run['start_date']
                state = last_run['state']
                return JsonResponse({'start_date': start_date, 'dag_id': 'database_lineage', 'state': state})
            else:
                return JsonResponse(
                    {'status': 'success', 'dag_id': 'database_lineage', 'message': 'No DAG runs found'})
        else:
            return JsonResponse(
                {'status': 'error', 'message': 'Failed to retrieve DAG status', 'details': response.json()})


class LoadDatabasesView(View):
    def post(self, request):
        with open('databases-config/databases.yml', 'r') as file:
            config = yaml.safe_load(file)
            databases = config['databases']
            for db in databases:
                Database.objects.get_or_create(
                    id=db['id'],
                    name=db['name'],
                )
            return JsonResponse({'status': 'success'})