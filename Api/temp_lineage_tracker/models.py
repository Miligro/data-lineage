from django.db import models


class Database(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=255)

    def __str__(self):
        return self.name

    class Meta:
        db_table = 'databases'
        managed = False


class Object(models.Model):
    id = models.AutoField(primary_key=True)
    database = models.ForeignKey(Database, on_delete=models.CASCADE)
    name = models.CharField(max_length=255)

    def __str__(self):
        return self.name

    class Meta:
        db_table = 'objects'
        managed = False


class ObjectRelationship(models.Model):
    id = models.AutoField(primary_key=True)
    database = models.ForeignKey(Database, on_delete=models.CASCADE)
    source_object = models.ForeignKey(Object, on_delete=models.CASCADE, related_name='source_object')
    target_object = models.ForeignKey(Object, on_delete=models.CASCADE, related_name='target_object')
    connection_probability = models.FloatField()

    class Meta:
        db_table = 'object_relationships'
        managed = False
        unique_together = (('database', 'source_object', 'target_object'),)
        constraints = [
            models.CheckConstraint(check=models.Q(connection_probability__gte=0), name='connection_probability_gte_0'),
            models.CheckConstraint(check=models.Q(connection_probability__lte=1), name='connection_probability_lte_1'),
        ]


class ObjectDetail(models.Model):
    id = models.AutoField(primary_key=True)
    database = models.ForeignKey(Database, on_delete=models.CASCADE)
    object = models.ForeignKey(Object, on_delete=models.CASCADE)
    column_name = models.CharField(max_length=255)
    column_type = models.CharField(max_length=255)

    class Meta:
        db_table = 'object_details'
        managed = False
        unique_together = (('database', 'object', 'column_name'),)
