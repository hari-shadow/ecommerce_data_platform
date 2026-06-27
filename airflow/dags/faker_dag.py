from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'airflow',
    'retries': 1,
    'retry_delay': timedelta(minutes=2),
}

with DAG(
    dag_id='faker_data_generator',
    default_args=default_args,
    description='Insert fake orders into Neon every 30 minutes',
    schedule='*/30 * * * *',  # every 30 minutes
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=['ingestion', 'faker'],
) as dag:

    run_faker = BashOperator(
        task_id='run_faker_script',
        bash_command='python /usr/local/airflow/include/faker_generator.py',
    )