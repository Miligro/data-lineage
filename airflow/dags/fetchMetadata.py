import yaml
import numpy as np
import pandas as pd
import os

from model import *
from airflow import DAG
from datetime import datetime
from itertools import permutations
from sqlalchemy.orm import sessionmaker
from related_objects_extractor import SQLParser
from airflow.operators.python import PythonOperator
from sqlalchemy import create_engine, MetaData, Table
from oracle_management import OracleDatabaseManagement
from postgres_management import PostgresDatabaseManagement
from sqlserver_management import SQLServerDatabaseManagement


def get_lineage_database_engine():
    user = os.environ.get("LINEAGE_DATABASE_USER")
    password = os.environ.get("LINEAGE_DATABASE_PASSWORD")
    db = os.environ.get("LINEAGE_DATABASE_DB")
    host = os.environ.get("LINEAGE_DATABASE_HOST")
    port = os.environ.get("LINEAGE_DATABASE_PORT")
    engine = create_engine(
        f'postgresql+psycopg2://{user}:{password}@{host}:{port}/{db}')
    return engine


def get_database_manager(**kwargs):
    database_id = kwargs['dag_run'].conf.get('database_id')
    database_config = None
    with open('/opt/airflow/databases-config/databases.yml', 'r') as file:
        config = yaml.safe_load(file)
        databases = config['databases']
        for db in databases:
            if db['id'] == database_id:
                database_config = db
    if database_config:
        if database_config['type'] == 'postgres':
            db_manager = PostgresDatabaseManagement(
                database_config['host'],
                database_config['db_name'],
                database_config['user'],
                database_config['password'],
                database_config['port'])
            db_manager.connect()
            return db_manager
        elif database_config['type'] == 'sqlserver':
            db_manager = SQLServerDatabaseManagement(
                database_config['host'],
                database_config['db_name'],
                database_config['user'],
                database_config['password'],
                database_config['port'])
            db_manager.connect()
            return db_manager
        elif database_config['type'] == 'oracle':
            db_manager = OracleDatabaseManagement(
                database_config['host'],
                database_config['port'],
                database_config['db_name'],
                database_config['user'],
                database_config['password'])
            db_manager.connect()
            return db_manager
    return None


def get_relationships_idx(engine, database_id):
    read_object_relationships_query = "SELECT * FROM object_relationships WHERE database_id = %(database_id)s"
    object_relationships_df = pd.read_sql_query(read_object_relationships_query, engine, params={"database_id": database_id})

    read_objects_query = "SELECT * FROM objects WHERE database_id = %(database_id)s"
    objects_df = pd.read_sql_query(read_objects_query, engine, params={"database_id": database_id})

    merged_df = object_relationships_df.merge(objects_df, left_on='source_object_id', right_on='id',
                                              suffixes=('', '_source'))
    merged_df = merged_df.merge(objects_df, left_on='target_object_id', right_on='id', suffixes=('', '_target'))
    result_df = merged_df[
        ['id', 'source_object_id', 'name', 'target_object_id', 'name_target']]

    object_id_map = result_df.set_index(['name', 'name_target'])['id'].to_dict()

    return object_id_map


def get_objects_idx(engine, database_id):
    read_objects_query = "SELECT * FROM objects WHERE database_id = %(database_id)s"
    objects_df = pd.read_sql_query(read_objects_query, engine, params={"database_id": database_id})
    object_id_map = objects_df.set_index('name')['id'].to_dict()

    return object_id_map

def update_status_to_django(status, **kwargs):
    database_id = kwargs['dag_run'].conf.get('database_id')
    engine = get_lineage_database_engine()
    session = sessionmaker(bind=engine)()
    metadata_obj = MetaData(bind=engine)
    metadata_obj.reflect(only=['databases'])
    databases_table = Table('databases', metadata_obj, autoload_with=engine)

    with engine.begin() as connection:
        connection.execute(
            databases_table.update().values(ingest_status_id=status).where(databases_table.c.id == database_id))

    session.close()


def manage_objects(**kwargs):
    database_id = kwargs['dag_run'].conf.get('database_id')
    db_manager = get_database_manager(**kwargs)

    metadata = db_manager.fetch_table_metadata()
    routines = db_manager.fetch_routines()
    db_manager.close()

    objects = (list({(row[0], row[3]) for row in metadata}) + list({(row[0], row[2]) for row in routines}))
    objects_records = [{'database_id': database_id, 'name': tab.upper(), 'type': tab_type}
                       for tab, tab_type in objects]

    engine = get_lineage_database_engine()
    objects_records_df = pd.DataFrame(objects_records)
    session = sessionmaker(bind=engine)()

    metadata_obj = MetaData(bind=engine)
    metadata_obj.reflect(only=['objects'])
    objects_table = Table('objects', metadata_obj, autoload_with=engine)
    data_dicts = objects_records_df.to_dict('records')
    if data_dicts:
        with engine.begin() as connection:
            connection.execute(objects_table.delete().where(objects_table.c.database_id == database_id))
            connection.execute(objects_table.insert(), data_dicts)

    object_id_map = get_objects_idx(engine, database_id)

    columns_details = []
    for (table_name, column_name, data_type, table_type) in metadata:
        object_id = object_id_map.get(table_name.upper())
        if object_id:
            columns_details.append({
                'database_id': database_id,
                'object_id': object_id,
                'column_name': column_name.upper(),
                'column_type': data_type
            })

    object_details_df = pd.DataFrame(columns_details)
    metadata_obj.reflect(only=['object_details'])
    object_details_table = Table('object_details', metadata_obj, autoload_with=engine)
    details_data_dicts = object_details_df.to_dict('records')

    if(details_data_dicts):
        with engine.begin() as connection:
            connection.execute(object_details_table.delete().where(object_details_table.c.database_id == database_id))
            connection.execute(object_details_table.insert(), details_data_dicts)

    session.close()


def manage_relationships(**kwargs):
    database_id = kwargs['dag_run'].conf.get('database_id')
    db_manager = get_database_manager(**kwargs)
    constraints = db_manager.fetch_table_constraints()
    views = db_manager.fetch_view_dependencies()
    routines = db_manager.fetch_routines()
    db_manager.close()
    relationships = []
    for constraint in constraints:
        source = constraint[0]
        target = constraint[2]
        relationships.append({"source": source.upper(), "target": target.upper()})
    for view in views:
        target_view = view[0]
        source_table = view[1]
        relationships.append({"source": source_table.upper(), "target": target_view.upper()})

    relationships_details = []
    for routine in routines:
        procedure_name = routine[0]
        parser = SQLParser(routine[1])
        objects, columns = parser.extract_related_objects()
        for relationship in columns:
            if len(relationship) > 0:
                relationships_details.append({"routine": procedure_name.upper(), "object": next(iter(relationship)).upper(),
                                              "columns": relationship[next(iter(relationship))]})
        for obj in objects:
            if obj != procedure_name:
                relationships.append({"source": procedure_name.upper(), "target": obj.upper()})

    engine = get_lineage_database_engine()
    session = sessionmaker(bind=engine)()

    object_id_map = get_objects_idx(engine, database_id)

    unique_relationships = set()
    for rel in relationships:
        source_name = rel['source']
        target_name = rel['target']
        connection_probability = 1

        source_id = object_id_map.get(source_name.upper())
        target_id = object_id_map.get(target_name.upper())
        if source_id is None or target_id is None:
            continue
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

    if data_dicts:
        with engine.begin() as connection:
            connection.execute(relationships_table.delete().where(relationships_table.c.database_id == database_id))
            connection.execute(relationships_table.insert(), data_dicts)

    object_id_map = get_relationships_idx(engine, database_id)

    relationships_details_list = []
    for relationship_detail in relationships_details:
        relationship_id = object_id_map.get((relationship_detail["routine"], relationship_detail["object"]))
        if relationship_id:
            for column in relationship_detail["columns"]:
                relationships_details_list.append({"database_id": database_id, "relation_id": relationship_id,
                                                   "column_name": column})
                
    if relationships_details_list:
        metadata_obj = MetaData(bind=engine)
        metadata_obj.reflect(only=['object_relationships_details'])
        relationships_details_table = Table('object_relationships_details', metadata_obj, autoload_with=engine)

        with engine.begin() as connection:
            connection.execute(
                relationships_details_table.delete().where(relationships_details_table.c.database_id == database_id))
            connection.execute(relationships_details_table.insert(), relationships_details_list)

    session.close()


def manage_relationships_details(**kwargs):
    database_id = kwargs['dag_run'].conf.get('database_id')
    db_manager = get_database_manager(**kwargs)
    constraints = db_manager.fetch_table_constraints()
    views = db_manager.fetch_view_dependencies()
    db_manager.close()

    engine = get_lineage_database_engine()
    session = sessionmaker(bind=engine)()
    object_id_map = get_relationships_idx(engine, database_id)

    relationships_details = []
    for constraint in constraints:
        relationship_id = object_id_map.get((constraint[0].upper(), constraint[2].upper()))
        if relationship_id:
            relationships_details.append({"database_id": database_id, "relation_id": relationship_id,
                                          "column_name": constraint[3].upper()})

    for view in views:
        relationship_id = object_id_map.get((view[1].upper(), view[0].upper()))
        if relationship_id:
            relationships_details.append({"database_id": database_id, "relation_id": relationship_id,
                                          "column_name": view[2].upper()})

    if relationships_details:
        metadata_obj = MetaData(bind=engine)
        metadata_obj.reflect(only=['object_relationships_details'])
        relationships_details_table = Table('object_relationships_details', metadata_obj, autoload_with=engine)

        with engine.begin() as connection:
            connection.execute(relationships_details_table.insert(), relationships_details)

    session.close()


def manage_relationships_by_model(**kwargs):
    database_id = kwargs['dag_run'].conf.get('database_id')
    db_manager = get_database_manager(**kwargs)

    metadata = db_manager.fetch_metadata_for_model()
    table_names = metadata['table_name'].unique()
    pairs = list(permutations(table_names, 2))
    table_names_similarities = analyze_table_names(metadata)
    column_name_similarities = analyze_column_names(metadata)
    table_idx_similarities = analyze_column_idx(metadata)
    model = load_model('/opt/airflow/plugins/forest.pkl')

    X_pred = []
    pairs_pred = []
    for pair in pairs:
        if (metadata[metadata['table_name'] == pair[0]].iloc[0]['oid'] <
                metadata[metadata['table_name'] == pair[1]].iloc[0]['oid']):
            pairs_pred.append(pair)
            idx1 = column_name_similarities.index.get_loc(pair[0])
            idx2 = column_name_similarities.columns.get_loc(pair[1])
            names_similarity = table_names_similarities.iloc[idx1, idx2]
            columns_similarity = column_name_similarities.iloc[idx1, idx2]
            idx_similarity = table_idx_similarities.iloc[idx1, idx2]
            X_pred.append([names_similarity, columns_similarity, idx_similarity])

    predicts = predict_relationships(model, np.array(X_pred), pairs_pred)

    engine = get_lineage_database_engine()
    session = sessionmaker(bind=engine)()

    read_object_relationships_query = "SELECT * FROM object_relationships WHERE database_id = %(database_id)s"
    existing_relationships = pd.read_sql_query(read_object_relationships_query, engine, params={"database_id": database_id})
    existing_relationships_set = set(zip(
        existing_relationships['source_object_id'],
        existing_relationships['target_object_id']
    ))

    object_id_map = get_objects_idx(engine, database_id)

    new_relationships = []
    for (source, target), probability in predicts:
        if probability > 0.0:
            source_id = object_id_map.get(source)
            target_id = object_id_map.get(target)
            if source_id is None or target_id is None:
                continue
            if (source_id, target_id) not in existing_relationships_set:
                new_relationships.append({
                    'database_id': database_id,
                    'source_object_id': source_id,
                    'target_object_id': target_id,
                    'connection_probability': round(probability.astype(float), 3)
                })

    if new_relationships:
        metadata_obj = MetaData(bind=engine)
        metadata_obj.reflect(only=['object_relationships'])
        relationships_table = Table('object_relationships', metadata_obj, autoload_with=engine)

        with engine.begin() as connection:
            connection.execute(relationships_table.insert(), new_relationships)

    session.close()


def set_in_progress_status(**kwargs):
    update_status_to_django(3, **kwargs)


def set_final_status(**kwargs):
    task_instances = kwargs['dag_run'].get_task_instances()
    any_failed = any(ti.state == 'failed' for ti in task_instances if ti.task_id != 'set_final_status')
    status = 1 if not any_failed else 2
    update_status_to_django(status, **kwargs)


with DAG(
        dag_id='postgres_to_django',
        start_date=datetime(2023, 1, 1),
        schedule_interval='@daily',
        catchup=False
) as dag:
    manage_objects_task = PythonOperator(
        task_id='manage_objects',
        python_callable=manage_objects,
        provide_context=True
    )

    manage_relationships_task = PythonOperator(
        task_id='manage_relationships',
        python_callable=manage_relationships,
        provide_context=True
    )

    manage_relationships_details_task = PythonOperator(
        task_id='manage_relationships_details',
        python_callable=manage_relationships_details,
        provide_context=True
    )

    manage_relationships_by_model_task = PythonOperator(
        task_id='manage_relationships_by_model',
        python_callable=manage_relationships_by_model,
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

    set_in_progress_task >> manage_objects_task >> manage_relationships_task >> manage_relationships_details_task >> manage_relationships_by_model_task >> set_final_status_task
