from pyspark.sql import SparkSession
from pyspark.sql.functions import (
    col,
    dayofmonth,
    month,
    to_timestamp,
    unix_timestamp,
    upper,
    year,
)
from pyspark.sql.types import DoubleType, StringType, StructField, StructType

# --------------------------------------------------
# Spark Session
# --------------------------------------------------
spark = SparkSession.builder.appName("Weather Bronze To Silver").getOrCreate()

# --------------------------------------------------
# Explicit Schema definition (Bypasses inferSchema)
# --------------------------------------------------
bronze_schema = StructType(
    [
        StructField("EventId", StringType(), True),
        StructField("Type", StringType(), True),
        StructField("Severity", StringType(), True),
        StructField("StartTime(UTC)", StringType(), True),
        StructField("EndTime(UTC)", StringType(), True),
        StructField("Precipitation(in)", DoubleType(), True),
        StructField("TimeZone", StringType(), True),

        StructField("AirportCode", StringType(), True),
        StructField("LocationLat", DoubleType(), True),
        StructField("LocationLng", DoubleType(), True),
        StructField("City", StringType(), True),
        StructField("County", StringType(), True),
        StructField("State", StringType(), True),
        StructField("ZipCode", StringType(), True),
    ]
)

BRONZE_PATH = (
    "hdfs://namenode:9000/weather/bronze/WeatherEvents_Jan2016-Dec2022.csv"
)
SILVER_PATH = "hdfs://namenode:9000/weather/silver/weather_events"

# --------------------------------------------------
# Read Bronze CSV (Using schema definition)
# --------------------------------------------------
df = (
    spark.read.option("header", True)
    .schema(bronze_schema)  # 👈 Massively faster
    .csv(BRONZE_PATH)
)

# --------------------------------------------------
# Transformations & Data Cleaning
# --------------------------------------------------
df = df.dropDuplicates(["EventId"])

df = df.na.drop(subset=["EventId", "Type", "Severity", "AirportCode"])

df = df.withColumn("start_time", to_timestamp(col("StartTime(UTC)"))).withColumn(
    "end_time", to_timestamp(col("EndTime(UTC)"))
)

df = df.withColumn(
    "duration_minutes",
    (unix_timestamp("end_time") - unix_timestamp("start_time")) / 60,
)

df = df.filter(col("duration_minutes") >= 0)

valid_severities = ["Light", "Moderate", "Severe"]
df = df.filter(col("Severity").isin(valid_severities))

df = df.filter(
    (col("LocationLat") >= -90)
    & (col("LocationLat") <= 90)
    & (col("LocationLng") >= -180)
    & (col("LocationLng") <= 180)
)

df = df.withColumn("state", upper(col("State"))).withColumn(
    "precipitation_in", col("Precipitation(in)").cast("double")
)

df = (
    df.withColumn("year", year(col("start_time")))
    .withColumn("month", month(col("start_time")))
    .withColumn("day", dayofmonth(col("start_time")))
)

# --------------------------------------------------
# Final Silver Schema Selection
# --------------------------------------------------
silver_df = df.select(
    col("EventId").alias("event_id"),
    col("Type").alias("event_type"),
    col("Severity").alias("severity"),
    col("start_time"),
    col("end_time"),
    col("duration_minutes"),
    col("precipitation_in"),
    col("AirportCode").alias("airport_code"),
    col("LocationLat").alias("latitude"),
    col("LocationLng").alias("longitude"),
    col("City").alias("city"),
    col("County").alias("county"),
    col("state"),
    col("ZipCode").alias("zipcode"),
    col("year"),
    col("month"),
    col("day"),
)

# --------------------------------------------------
# Write Silver Layer as Parquet
# --------------------------------------------------
(
    silver_df.write.mode("overwrite")
    .partitionBy("year")
    .parquet(SILVER_PATH)
)

print("Silver layer written successfully.")
spark.stop()