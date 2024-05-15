from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
from sqlalchemy import create_engine, MetaData, Table
from sqlalchemy.orm import sessionmaker
from postgres_management import PostgresDatabaseManagement
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


def fetch_table_metadata():
    db_manager = PostgresDatabaseManagement(DB_HOST, DB_NAME, DB_USER, DB_PASSWORD, DB_PORT)

    db_manager.connect()
    metadata = db_manager.fetch_table_metadata()
    table_names = list({row[0] for row in metadata})
    db_manager.close()

    return [{'database_id': 1, 'object_name': tab} for tab in table_names]


def load_data_to_django(**kwargs):
    ti = kwargs['ti']
    metadata = ti.xcom_pull(task_ids='fetch_table_metadata')

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


with DAG(
        dag_id='postgres_to_django',
        start_date=datetime(2023, 1, 1),
        schedule_interval='@daily',
        catchup=False
) as dag:
    fetch_metadata_task = PythonOperator(
        task_id='fetch_table_metadata',
        python_callable=fetch_table_metadata
    )

    load_data_task = PythonOperator(
        task_id='load_data_to_django',
        python_callable=load_data_to_django,
        provide_context=True
    )

    fetch_metadata_task >> load_data_task
