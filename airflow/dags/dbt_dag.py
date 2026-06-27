from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'airflow',
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id='dbt_run',
    default_args=default_args,
    description='Daily dbt run and test',
    schedule='0 2 * * *',  # 2am daily, after Frankfurter
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=['dbt', 'transform'],
) as dag:

    dbt_run = BashOperator(
        task_id='dbt_run',
        bash_command='cd /usr/local/airflow/ecommerce_dbt && dbt run --profiles-dir .',
    )

    dbt_test = BashOperator(
        task_id='dbt_test',
        bash_command='cd /usr/local/airflow/ecommerce_dbt && dbt test --profiles-dir .',
    )

    dbt_run >> dbt_test