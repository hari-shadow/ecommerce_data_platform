from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'airflow',
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id='frankfurter_ingestion',
    default_args=default_args,
    description='Daily Frankfurter exchange rate ingestion to Snowflake',
    schedule='0 1 * * *',  # 1am daily
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=['ingestion', 'frankfurter'],
) as dag:

    run_frankfurter = BashOperator(
        task_id='run_frankfurter_script',
        bash_command='cd /usr/local/airflow && python data_generator/frankfurter_to_snowflake.py',
    )