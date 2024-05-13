from django.db import models


class SystemOperationsWithQuery(models.Model):
    id = models.AutoField(primary_key=True)
    operation_type = models.CharField(max_length=255)
    obj_name = models.CharField(max_length=255)
    query = models.TextField()

    class Meta:
        unique_together = ('operation_type', 'obj_name', 'query',)

class SystemOperationsWithDependencies(models.Model):
    id = models.AutoField(primary_key=True)
    operation_type = models.CharField(max_length=255)
    obj_name = models.CharField(max_length=255)
    obj_parent = models.CharField(max_length=255)

    class Meta:
        unique_together = ('operation_type', 'obj_name', 'obj_parent',)
