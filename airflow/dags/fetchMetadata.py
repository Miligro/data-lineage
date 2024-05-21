from itertools import permutations

from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
from sqlalchemy import create_engine, MetaData, Table
from sqlalchemy.orm import sessionmaker
from postgres_management import PostgresDatabaseManagement
from related_objects_extractor import SQLParser
from model import *
import pandas as pd
import numpy as np

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


def update_status_to_django(status, database_id, **context):
    engine = create_engine(
        f'postgresql+psycopg2://{DJANGO_DB_USER}:{DJANGO_DB_PASSWORD}@{DJANGO_DB_HOST}:{DJANGO_DB_PORT}/{DJANGO_DB_NAME}')

    session = sessionmaker(bind=engine)()
    metadata_obj = MetaData(bind=engine)
    metadata_obj.reflect(only=['databases'])
    databases_table = Table('databases', metadata_obj, autoload_with=engine)

    with engine.begin() as connection:
        connection.execute(
            databases_table.update().values(ingest_status=status).where(databases_table.c.id == database_id))

    session.close()


def fetch_objects(ti):
    db_manager = PostgresDatabaseManagement(DB_HOST, DB_NAME, DB_USER, DB_PASSWORD, DB_PORT)
    db_manager.connect()

    metadata = db_manager.fetch_table_metadata()
    procedures = db_manager.fetch_stored_procedures()
    functions = db_manager.fetch_stored_functions()
    db_manager.close()

    object_names = (list({row[0] for row in metadata}) + list({row[1] for row in procedures})
                    + list({row[1] for row in functions}))

    ti.xcom_push(key='object_names', value=object_names)


def fetch_relationships(ti):
    db_manager = PostgresDatabaseManagement(DB_HOST, DB_NAME, DB_USER, DB_PASSWORD, DB_PORT)
    db_manager.connect()

    constraints = db_manager.fetch_table_constraints()
    views = db_manager.fetch_view_dependencies()
    procedures = db_manager.fetch_stored_procedures()
    functions = db_manager.fetch_stored_functions()
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

    for procedure in procedures + functions:
        procedure_name = procedure[1]
        parser = SQLParser(procedure[3])
        objects = parser.extract_related_objects()
        for obj in objects:
            if obj != procedure_name:
                relationships.append({"source": procedure_name, "target": obj})
    ti.xcom_push(key='relationships', value=relationships)


def fetch_relationships_by_model():
    db_manager = PostgresDatabaseManagement(DB_HOST, DB_NAME, DB_USER, DB_PASSWORD, DB_PORT)
    db_manager.connect()

    metadata = db_manager.fetch_metadata_for_model()
    table_names = metadata['table_name'].unique()
    pairs = list(permutations(table_names, 2))
    table_name_similarities = analyze_table_names(metadata)
    column_name_similarities = analyze_column_names(metadata)
    model = load_model('/opt/airflow/plugins/forest.pkl')

    X_pred = []
    for pair in pairs:
        idx1 = table_name_similarities.index.get_loc(pair[0])
        idx2 = table_name_similarities.columns.get_loc(pair[1])
        name_similarity = table_name_similarities.iloc[idx1, idx2]
        columns_similarity = column_name_similarities.iloc[idx1, idx2]
        X_pred.append([name_similarity, columns_similarity])

    predicts = predict_relationships(model, np.array(X_pred), pairs)

    engine = create_engine(
        f'postgresql+psycopg2://{DJANGO_DB_USER}:{DJANGO_DB_PASSWORD}@{DJANGO_DB_HOST}:{DJANGO_DB_PORT}/{DJANGO_DB_NAME}')
    session = sessionmaker(bind=engine)()

    existing_relationships = pd.read_sql_table('object_relationships', engine)
    existing_relationships_set = set(zip(
        existing_relationships['source_object_id'],
        existing_relationships['target_object_id']
    ))

    objects_df = pd.read_sql_table('objects', engine)
    object_id_map = objects_df.set_index('name')['id'].to_dict()

    new_relationships = []
    for (source, target), probability in predicts:
        if probability > 0.0:
            source_id = object_id_map.get(source)
            target_id = object_id_map.get(target)
            if source_id is None or target_id is None:
                continue
            if (source_id, target_id) not in existing_relationships_set:
                new_relationships.append({
                    'database_id': 1,
                    'source_object_id': source_id,
                    'target_object_id': target_id,
                    'connection_probability': probability
                })

    if new_relationships:
        metadata_obj = MetaData(bind=engine)
        metadata_obj.reflect(only=['object_relationships'])
        relationships_table = Table('object_relationships', metadata_obj, autoload_with=engine)

        with engine.begin() as connection:
            connection.execute(relationships_table.insert(), new_relationships)

    session.close()


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


def set_in_progress_status(**context):
    update_status_to_django('in_progress', 1, **context)


def set_final_status(**context):
    task_instances = context['dag_run'].get_task_instances()
    any_failed = any(ti.state == 'failed' for ti in task_instances if ti.task_id != 'set_final_status')
    status = 'success' if not any_failed else 'failed'
    update_status_to_django(status, 1, **context)


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

    fetch_relationships_by_model_task = PythonOperator(
        task_id='fetch_relationships_by_model',
        python_callable=fetch_relationships_by_model,
        provide_context=True
    )

    set_in_progress_task = PythonOperator(
        task_id='set_in_progress_status',
        python_callable=set_in_progress_status,
        provide_context=True
    )

    set_final_status_task = PythonOperator(
        task_id='set_final_status',
        python_callable=set_final_status,
        trigger_rule='all_done',
        provide_context=True
    )

    set_in_progress_task >> fetch_objects_task >> load_objects_task >> fetch_relationships_task >> load_relationships_task >> fetch_relationships_by_model_task >> set_final_status_task
