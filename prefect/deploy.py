# from prefect import serve
# from flows import frankfurter_flow, dbt_flow, faker_flow

# if __name__ == "__main__":
#     serve(
#         frankfurter_flow.to_deployment(
#             name="frankfurter-daily",
#             cron="0 1 * * *",   # 1am daily
#         ),
#         dbt_flow.to_deployment(
#             name="dbt-daily",
#             cron="0 2 * * *",   # 2am daily
#         ),
#         faker_flow.to_deployment(
#             name="faker-every-30min",
#             cron="*/30 * * * *",  # every 30 mins
#         ),
#     )


# from prefect.deployments import DeploymentImage
from prefect.runner.storage import GitRepository
from flows import frankfurter_flow, dbt_flow, faker_flow

source = GitRepository(
    url="https://github.com/hari-shadow/ecommerce_data_platform",
    branch="main",
)

if __name__ == "__main__":
    frankfurter_flow.from_source(
        source=source,
        entrypoint="prefect/flows.py:frankfurter_flow",
    ).deploy(
        name="frankfurter-daily",
        work_pool_name="managed-pool",
        cron="0 1 * * *",
        job_variables={
            "pip_packages": [
                "snowflake-connector-python",
                "requests",
                "python-dotenv"
            ]
        }
    )

    dbt_flow.from_source(
        source=source,
        entrypoint="prefect/flows.py:dbt_flow",
    ).deploy(
        name="dbt-daily",
        work_pool_name="managed-pool",
        cron="0 2 * * *",
        job_variables={
            "pip_packages": [
                "dbt-snowflake",
                "python-dotenv"
            ]
        }
    )

    faker_flow.from_source(
        source=source,
        entrypoint="prefect/flows.py:faker_flow",
    ).deploy(
        name="faker-every-30min",
        work_pool_name="managed-pool",
        cron="*/30 * * * *",
        job_variables={
            "pip_packages": [
                "psycopg2-binary",
                "faker",
                "python-dotenv"
            ]
        }
    )