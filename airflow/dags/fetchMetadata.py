from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
from sqlalchemy import create_engine, MetaData, Table
from sqlalchemy.orm import sessionmaker
from postgres_management import PostgresDatabaseManagement
from related_objects_extractor import SQLParser
import pandas as pd


DB_HOST = 'postgres-data-lineage-postgres-1'
DB_NAME = 'online_store'
DB_USER = 'postgres'
DB_PASSWORD = 'postgres'
DB_PORT = 5432

DJANGO_DB_HOST = 'database-data-lineage-management-1'
DJANGO_DB_NAME = 'LineageManagement'
DJANGO_DB_USER = 'postgres'
DJANGO_DB_PASSWORD = 'postgres'
DJANGO_DB_PORT = 5432


def fetch_objects(ti):
    db_manager = PostgresDatabaseManagement(DB_HOST, DB_NAME, DB_USER, DB_PASSWORD, DB_PORT)
    db_manager.connect()

    metadata = db_manager.fetch_table_metadata()
    db_manager.close()

    object_names = list({row[0] for row in metadata})

    ti.xcom_push(key='object_names', value=object_names)


def fetch_relationships(ti):
    db_manager = PostgresDatabaseManagement(DB_HOST, DB_NAME, DB_USER, DB_PASSWORD, DB_PORT)
    db_manager.connect()

    constraints = db_manager.fetch_table_constraints()
    views = db_manager.fetch_view_dependencies()
    # procedures = db_manager.fetch_stored_procedures()
    # functions = db_manager.fetch_stored_functions()
    db_manager.close()
    relationships = []

    for constraint in constraints:
        source = constraint[1]
        target = constraint[3]
        relationships.append({"source": source, "target": target})
    for view in views:
        source_view = view[1]
        target_table = view[3]
        relationships.append({"source": source_view, "target": target_table})

    # for procedure in procedures + functions:
    #     procedure_name = procedure[1]
    #     parser = SQLParser(procedure[3])
    #     objects = parser.extract_related_objects()
    #     for obj in objects:
    #         if obj != procedure_name:
    #
    #             edge_id = f"{procedure_name}_{obj}"
    #             relationships.append({"source": procedure_name, "target": obj})
    ti.xcom_push(key='relationships', value=relationships)


def load_objects_to_django(ti):
    object_names = ti.xcom_pull(task_ids='fetch_objects', key='object_names')
    if not object_names:
        raise ValueError("No data fetched from XCom.")
    metadata = [{'database_id': 1, 'name': tab} for tab in object_names]

    engine = create_engine(
        f'postgresql+psycopg2://{DJANGO_DB_USER}:{DJANGO_DB_PASSWORD}@{DJANGO_DB_HOST}:{DJANGO_DB_PORT}/{DJANGO_DB_NAME}')

    metadata_df = pd.DataFrame(metadata)
    session = sessionmaker(bind=engine)()

    metadata_obj = MetaData(bind=engine)
    metadata_obj.reflect(only=['objects'])
    objects_table = Table('objects', metadata_obj, autoload_with=engine)
    data_dicts = metadata_df.to_dict('records')

    with engine.begin() as connection:
        connection.execute(objects_table.delete())
        connection.execute(objects_table.insert(), data_dicts)

    session.close()


def load_relationships_to_django(ti):
    relationships = ti.xcom_pull(task_ids='fetch_relationships', key='relationships')
    if not relationships:
        raise ValueError("No data fetched from XCom.")

    engine = create_engine(
        f'postgresql+psycopg2://{DJANGO_DB_USER}:{DJANGO_DB_PASSWORD}@{DJANGO_DB_HOST}:{DJANGO_DB_PORT}/{DJANGO_DB_NAME}')

    session = sessionmaker(bind=engine)()

    objects_df = pd.read_sql_table('objects', engine)
    object_id_map = objects_df.set_index('name')['id'].to_dict()

    unique_relationships = set()
    for rel in relationships:
        source_name = rel['source']
        target_name = rel['target']
        database_id = 1
        connection_probability = 1

        source_id = object_id_map.get(source_name)
        target_id = object_id_map.get(target_name)
        if source_id is None or target_id is None:
            raise ValueError(f"Object ID not found for source: {source_name} or target: {target_name}")

        unique_relationships.add((
            database_id,
            source_id,
            target_id,
            connection_probability
        ))

    data_dicts = [
        {
            'database_id': database_id,
            'source_object_id': source_id,
            'target_object_id': target_id,
            'connection_probability': connection_probability
        }
        for (database_id, source_id, target_id, connection_probability) in unique_relationships
    ]

    metadata_obj = MetaData(bind=engine)
    metadata_obj.reflect(only=['object_relationships'])
    relationships_table = Table('object_relationships', metadata_obj, autoload_with=engine)

    with engine.begin() as connection:
        connection.execute(relationships_table.delete())
        connection.execute(relationships_table.insert(), data_dicts)

    session.close()


with DAG(
        dag_id='postgres_to_django',
        start_date=datetime(2023, 1, 1),
        schedule_interval='@daily',
        catchup=False
) as dag:

    fetch_objects_task = PythonOperator(
        task_id='fetch_objects',
        python_callable=fetch_objects,
        provide_context=True
    )

    load_objects_task = PythonOperator(
        task_id='load_objects_to_django',
        python_callable=load_objects_to_django,
        provide_context=True
    )

    fetch_relationships_task = PythonOperator(
        task_id='fetch_relationships',
        python_callable=fetch_relationships,
        provide_context=True
    )

    load_relationships_task = PythonOperator(
        task_id='load_relationships_to_django',
        python_callable=load_relationships_to_django,
        provide_context=True
    )

    fetch_objects_task >> load_objects_task >> fetch_relationships_task >> load_relationships_task
