# Weather Data Engineering Pipeline

## Overview

This project implements an end-to-end data engineering pipeline for processing and analyzing weather event data using a modern data stack.

The pipeline ingests raw weather event data, stores it in Hadoop HDFS, processes and cleans it using Apache Spark, loads curated data into PostgreSQL, and builds an analytical warehouse using dbt.

The final warehouse follows a dimensional modeling approach with a star schema and includes aggregated analytics tables for reporting and business intelligence.

---

## Architecture

```text
Weather Events Dataset (CSV)
            │
            ▼
      Apache Airflow
            │
            ▼
       HDFS Bronze
            │
            ▼
      Apache Spark
     Bronze → Silver
            │
            ▼
      PostgreSQL
   silver.weather_events
            │
            ▼
            dbt
            │
 ┌──────────┼──────────┐
 ▼          ▼          ▼
dim_date dim_location dim_weather_event
 └──────────┼──────────┘
            ▼
   fact_weather_events
            │
 ┌──────────┼──────────┐
 ▼          ▼          ▼
Monthly   By State   By Type
Analytics Analytics Analytics
![img][architetcure.png]

## Technology Stack

### Data Storage

* Hadoop HDFS
* PostgreSQL

### Data Processing

* Apache Spark (PySpark)

### Orchestration

* Apache Airflow

### Data Modeling

* dbt (Data Build Tool)

### Development Environment

* Docker Compose
* Jupyter Notebook
* CloudBeaver

---

## Project Structure

text
weather-project
│
├── airflow/
│   └── dags/
│
├── spark/
│   ├── bronze_to_silver.py
│   └── silver_to_postgres.py
│
├── dbt/
│   ├── models/
│   │   ├── staging/
│   │   ├── marts/
│   │   └── analytics/
│   └── tests/
│
├── data/
│
└── docker-compose.yml


---

## Data Pipeline

### 1. Bronze Layer

Raw weather event CSV data is loaded into Hadoop HDFS using Apache Airflow.

Location:

```text
/weather/bronze/
```

---

### 2. Silver Layer

Apache Spark processes the raw data and performs:

* Explicit schema enforcement
* Duplicate removal
* Null validation
* Timestamp conversion
* Duration calculation
* Severity validation
* Geographic coordinate validation
* State normalization
* Date extraction

Output:

```text
/weather/silver/weather_events
```

Stored as partitioned Parquet files.

---

### 3. Warehouse Layer

Curated Silver data is loaded into PostgreSQL.

Table:

```text
silver.weather_events
```

This table acts as the source for dbt transformations.

---

## Data Modeling

### Staging Layer

#### stg_weather_events

Standardizes source data and prepares it for dimensional modeling.

---

### Dimensions

#### dim_date

Calendar dimension containing:

* DateSK
* Date
* Day
* Month
* Quarter
* Year

#### dim_location

Location dimension containing:

* location_id
* airport_code
* city
* county
* state
* zipcode

#### dim_weather_event

Weather event dimension containing:

* weather_event_id
* event_type
* severity

---

### Fact Table

#### fact_weather_events

Contains weather event measurements and foreign keys.

Measures:

* duration_minutes
* precipitation_in

Foreign Keys:

* date_sk
* location_id
* weather_event_id

---

## Star Schema

```text
                dim_date
                    │
                    │
dim_location ── fact_weather_events ── dim_weather_event
```

---

## Analytics Layer

### agg_weather_events_monthly

Monthly weather event trends.

Metrics:

* Total Events
* Average Duration
* Total Precipitation

---

### agg_weather_events_by_state

Weather event analysis by state.

Metrics:

* Event Count
* Average Duration
* Average Precipitation

---

### agg_weather_events_by_type

Weather event analysis by event type.

Metrics:

* Event Count
* Average Duration
* Average Precipitation

---

## Data Quality Testing

dbt tests are used to validate warehouse quality.

### Dimension Tests

* date_sk not null
* location_id unique
* location_id not null
* weather_event_id unique
* weather_event_id not null

### Fact Tests

* event_id unique
* event_id not null
* valid date_sk relationships
* valid location_id relationships
* valid weather_event_id relationships

---

## Airflow Workflow

Current Airflow orchestration:

text
upload_to_hdfs
        │
        ▼
bronze_to_silver
        │
        ▼
silver_to_postgres


dbt transformations and tests are executed locally against PostgreSQL after pipeline completion.

---

## Running the Project

### Start Infrastructure

```bash
docker compose up -d
```

### Run Airflow Pipeline

Trigger DAG:

```text
ingest_bronze_silver
```

### Execute dbt

```bash
cd dbt
dbt build
```

---

## Key Features

* End-to-end data engineering pipeline
* Hadoop-based data lake architecture
* Spark data processing and cleansing
* PostgreSQL analytical warehouse
* Dimensional modeling with dbt
* Star schema implementation
* Data quality testing
* Analytics-ready aggregate tables
* Containerized development environment

---

## Future Improvements

* Containerized dbt execution
* Airflow orchestration of dbt models
* Incremental dbt models
* Data quality monitoring
* Power BI/Tableau dashboard integration
* CI/CD pipeline for automated deployment
