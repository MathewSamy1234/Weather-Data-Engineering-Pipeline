from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

default_args = {
    "owner": "data-engineer",
    "start_date": datetime(2024, 1, 1),
    "retries": 1,
}

with DAG(
    dag_id="weather_end_to_end_pipeline",
    default_args=default_args,
    schedule=None,
    catchup=False,
    description="Weather Data Pipeline: HDFS → Spark → PostgreSQL → dbt",
) as dag:

    upload_to_hdfs = BashOperator(
        task_id="upload_to_hdfs",
        bash_command="""
        docker exec namenode-weather bash -c "
        hdfs dfs -mkdir -p /weather/bronze &&
        hdfs dfs -put -f /tmp/data/WeatherEvents_Jan2016-Dec2022.csv /weather/bronze/
        "
        """,
    )

   
    bronze_to_silver = BashOperator(
        task_id="bronze_to_silver",
        bash_command="""
        docker exec spark-master-weather bash -c "
        /opt/spark/bin/spark-submit \
        --master local[*] \
        --driver-memory 4G \
        --executor-memory 4G \
        /opt/spark/jobs/bronze_to_silver.py
        "
        """,
    )

    silver_to_postgres = BashOperator(
        task_id="silver_to_postgres",
        bash_command="""
        docker exec spark-master-weather bash -c "
        /opt/spark/bin/spark-submit \
        --master local[*] \
        --driver-memory 4G \
        --executor-memory 4G \
        --jars /opt/postgresql-42.7.11.jar \
        /opt/spark/jobs/silver_to_postgres.py
        "
        """,
    )

   

    (
        upload_to_hdfs
        >> bronze_to_silver
        >> silver_to_postgres
    )