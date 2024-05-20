from django.shortcuts import get_object_or_404
from django.views import View
from django.http import JsonResponse
from .lineage_ml.model import ModelManager
from django.db import models
from .models import Database, Object, ObjectRelationship


class ListDatabasesView(View):
    def get(self, request):
        databases = Database.objects.all()
        databases_dict = {
            'databases': [
                {'id': db.id, 'name': db.name} for db in databases
            ]
        }
        return JsonResponse(databases_dict)


class ListObjectsView(View):
    def get(self, request, database_id):
        print(database_id)
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
                    'name': obj.name
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
            objects_set.add((relationship.source_object.id,relationship.source_object.name))
            objects_set.add((relationship.target_object.id,relationship.target_object.name))

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
                        'connection_probability': rel.connection_probability
                    },
                } for rel in relationships
            ]
            + [
                {
                    'data': {
                        'id': object_t[0],
                        'label': object_t[1]
                    }
                } for object_t in objects_set
            ]
        }
        return JsonResponse(response_data)


class LineageModelView(View):
    def post(self, _, database_id):
        # TODO
        loaded_model = ModelManager.load_model('Api/temp_lineage_tracker/lineage_ml/models/forest.pkl')
        # predicted_relationships = predict_relationships(loaded_model, X_test, pairs_test)
        # visualize_relationships(predicted_relationships)
