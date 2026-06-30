from pyspark.sql import SparkSession


def main():
    spark = (
        SparkSession.builder
        .appName("SilverToPostgresLoader")
        .getOrCreate()
    )

    print("Reading Silver data from HDFS...")

    df = spark.read.parquet(
        "hdfs://namenode:9000/weather/silver/weather_events"
    )

    print(f"Rows found: {df.count()}")

    df.printSchema()

    # Optional: reduce number of JDBC writers
    df = df.repartition(8)

    jdbc_url = "jdbc:postgresql://warehouse-postgres:5432/weather"

    connection_properties = {
        "user": "weather",
        "password": "weather",  # replace if you changed it again
        "driver": "org.postgresql.Driver"
    }

    print("Writing data to PostgreSQL...")

    (
        df.write
        .mode("overwrite")
        .jdbc(
            url=jdbc_url,
            table="silver.weather_events",
            properties=connection_properties
        )
    )

    print("Data successfully loaded into PostgreSQL")
    print("Table: silver.weather_events")

    spark.stop()


if __name__ == "__main__":
    main()