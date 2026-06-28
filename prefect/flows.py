import subprocess
import sys
from pathlib import Path
from prefect import flow, task
from prefect.schedules import Cron

# Project root — two levels up from this file
PROJECT_ROOT = Path(__file__).parent.parent


@task(name="Run Frankfurter Ingestion")
def run_frankfurter():
    result = subprocess.run(
        [sys.executable, str(PROJECT_ROOT / "data_generator" / "frankfurter_to_snowflake.py")],
        capture_output=True, text=True
    )
    print(result.stdout)
    if result.returncode != 0:
        raise Exception(result.stderr)


@task(name="Run dbt")
def run_dbt(command: str):
    result = subprocess.run(
        ["dbt", command, "--profiles-dir", "."],
        cwd=str(PROJECT_ROOT / "ecommerce_dbt"),
        capture_output=True, text=True
    )
    print(result.stdout)
    if result.returncode != 0:
        raise Exception(result.stderr)


@task(name="Run Faker Generator")
def run_faker():
    result = subprocess.run(
        [sys.executable, str(PROJECT_ROOT / "data_generator" / "faker_generator.py")],
        capture_output=True, text=True
    )
    print(result.stdout)
    if result.returncode != 0:
        raise Exception(result.stderr)


@flow(name="Frankfurter Ingestion")
def frankfurter_flow():
    run_frankfurter()


@flow(name="dbt Run")
def dbt_flow():
    run_dbt("run")
    run_dbt("test")


@flow(name="Faker Generator")
def faker_flow():
    run_faker()


if __name__ == "__main__":
    frankfurter_flow()