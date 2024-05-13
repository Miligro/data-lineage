from django.db import models

class SystemOperationsWithQuery(models.Model):
    id = models.AutoField(primary_key=True)
    operation_type = models.CharField(max_length=255)
    obj_name = models.CharField(max_length=255)
    query = models.TextField()
    query_hash = models.BinaryField(max_length=32)

    class Meta:
        db_table = 'system_operations_with_query'
        unique_together = ('operation_type', 'obj_name', 'query_hash',)

class SystemOperationsWithDependencies(models.Model):
    id = models.AutoField(primary_key=True)
    operation_type = models.CharField(max_length=255)
    obj_name = models.CharField(max_length=255)
    obj_parent = models.CharField(max_length=255)

    class Meta:
        db_table = 'system_operations_with_dependencies'
        unique_together = ('operation_type', 'obj_name', 'obj_parent',)
