<div align="center">

# ⚽ FIFA Men's World Cup (1970-2022) — Data Engineering Pipeline

<img src="https://img.shields.io/badge/Records-1322-blue?style=for-the-badge&logo=databricks&logoColor=white"/>
<img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white"/>
<img src="https://img.shields.io/badge/Apache_Airflow-017CEE?style=for-the-badge&logo=Apache%20Airflow&logoColor=white"/>
<img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white"/>
<img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white"/>
<img src="https://img.shields.io/badge/Years-1970--2022-orange?style=for-the-badge"/>

<br/>
<br/>

> **An end-to-end ETL pipeline** that ingests, transforms, and warehouses 1,322 match records from 14 FIFA Men's World Cup tournaments (1970–2022) into a star-schema data warehouse — orchestrated with Apache Airflow and Docker.

</div>

---

## 📌 Table of Contents

- [📊 Project Overview](#-project-overview)
- [🔢 Key Metrics at a Glance](#-key-metrics-at-a-glance)
- [🗂️ Project Structure](#️-project-structure)
- [🧹 Data Profiling Findings](#-data-profiling-findings)
- [⭐ Star Schema Design](#-star-schema-design)
- [⚙️ ETL Pipeline](#️-etl-pipeline)
- [🚀 How to Run](#-how-to-run)
- [📈 Key Findings & Insights](#-key-findings--insights)
- [🌬️ Airflow Orchestration](#️-airflow-orchestration)

---

## 📊 Project Overview

This project builds an **end-to-end ETL data pipeline** for FIFA Men's World Cup data. It follows the **Medallion Architecture** (Raw → Staging → Warehouse) and uses a **Star Schema** optimized for fast analytical queries.

| Property         | Value                                 |
| ---------------- | ------------------------------------- |
| 📁 Source        | FIFA Men's World Cup Dataset (Kaggle) |
| 🗄️ Database      | PostgreSQL                            |
| 🔢 Total Records | 1,322 matches                         |
| 📅 Years Covered | 1970 – 2022 (14 tournaments)          |
| 🧱 Architecture  | Medallion (Raw → Staging → Warehouse) |
| 🌐 Orchestration | Apache Airflow (Dockerized)           |
| 🐍 Language      | Python + SQL                          |

---

## 🔢 Key Metrics at a Glance

<div align="center">

| ⚽ Total Matches | 🏆 Tournaments | 🌍 Teams | 🥅 Total Goals | 🟨 Yellow Cards |
| :--------------: | :------------: | :------: | :------------: | :-------------: |
|    **1,322**     |     **14**     |  **83**  |   **1,670**    |    **2,543**    |

</div>

---

## 🗂️ Project Structure

```
fifa_wc_de/
│
├── 📁 airflow/                     → Airflow + Docker
│   ├── dags/
│   │   └── fifa_wc_dag.py         → Airflow DAG definition
│   ├── logs/                      → Airflow execution logs
│   ├── plugins/                   → Airflow plugins
│   ├── .env                       → Airflow UID config
│   └── docker-compose.yml         → Docker configuration
│
├── 📁 data/
│   ├── raw/                       → Full load CSV
│   │   └── fifa_wc_mens_match_dataset_1970_2022.csv
│   └── new/                       → Incremental CSV
│       └── fifa_wc_new.csv
│
├── 📁 database/                   → Database connection
│   ├── __init__.py
│   └── postgresql.py
│
├── 📁 etl/                        → ETL pipeline logic
│   ├── __init__.py
│   ├── load_raw.py                → Extract CSV → Raw layer
│   ├── load_stg.py                → Transform → Staging layer
│   ├── load_final.py              → Load → Warehouse layer
│   └── load_incremental.py        → Incremental load + batch tracker
│
├── 📁 sql/
│   ├── ddl/                       → Table creation queries
│   │   ├── 01_create_raw_tables.sql
│   │   ├── 02_create_stg_tables.sql
│   │   ├── 03_create_final_tables.sql
│   │   └── 04_create_batch_tracker.sql
│   └── dml/                       → Data insertion queries
│       ├── 01_load_raw_tables.sql
│       ├── 02_load_stg_tables.sql
│       ├── 03_load_final_tables.sql
│       └── 04_load_incremental.sql
│
├── 📁 profiling/
│   └── profiling.py               → Data profiling script
│
├── 📁 analysis/                   → Analytical queries
│   ├── 01_kpi_metrics.sql
│   ├── 02_team_analysis.sql
│   ├── 03_tournament_analysis.sql
│   ├── 04_venue_analysis.sql
│   └── 05_stage_analysis.sql
│
├── 📁 src/                        → Utility functions
│   ├── __init__.py
│   └── sql_utils.py
│
├── main.py                        → Pipeline entry point
└── README.md                      → Project documentation
```

---

## 🧹 Data Profiling Findings

| Column             | Issue Found             | Action Taken                                  |
| ------------------ | ----------------------- | --------------------------------------------- |
| `possession`       | 554 NULLs (41.91%)      | Kept as NULL — early tournaments didn't track |
| `shots`            | 554 NULLs (41.91%)      | Kept as NULL                                  |
| `passes_completed` | 554 NULLs (41.91%)      | Kept as NULL                                  |
| `corners`          | 554 NULLs (41.91%)      | Kept as NULL                                  |
| `fouls`            | 554 NULLs (41.91%)      | Kept as NULL                                  |
| `replayed`         | Always 0                | Dropped — useless column                      |
| `replay`           | Always 0                | Dropped — useless column                      |
| `Duplicates`       | 0 duplicate records     | No action needed ✅                           |
| `group_stage`      | Float values (0.0, 1.0) | Cast via FLOAT → SMALLINT                     |

> 🔍 Run `profiling/profiling.py` for the complete data profiling report.

---

## ⭐ Star Schema Design

```
                         ┌──────────────────┐
                         │  dim_tournament  │  → WHEN (which WC)
                         └────────┬─────────┘
                                  │
  ┌─────────────┐        ┌────────▼─────────┐        ┌────────────┐
  │  dim_team   │───────►│   fact_match     │◄───────│  dim_venue │
  └─────────────┘        └────────┬─────────┘        └────────────┘
   (WHO played)                   │                   (WHERE played)
                     ┌────────────┼────────────┐
                     │                         │
              ┌──────▼──────┐          ┌───────▼──────┐
              │  dim_stage  │          │   dim_date   │
              └─────────────┘          └──────────────┘
               (WHAT stage)              (WHEN exactly)
```

### Why Star Schema?

- ⚡ **Fast analytical queries** — minimal joins needed
- 🔁 **No data redundancy** — dimensions stored once
- 👁️ **Easy to understand** — business-friendly structure
- 🏭 **Industry standard** — battle-tested for data warehouses

---

## ⚙️ ETL Pipeline

```
┌──────────────────────────────────────────────────────────────┐
│                        ETL PIPELINE                          │
│                                                              │
│  📥 EXTRACT         🔄 TRANSFORM          📤 LOAD           │
│  ─────────          ───────────          ──────              │
│  CSV File     →    Cast types       →   dim tables first     │
│  1,322 rows        NULL handling         fact table last     │
│  TEXT only         Drop useless          Referential         │
│                    columns               integrity           │
│                    FLOAT→SMALLINT        maintained          │
└──────────────────────────────────────────────────────────────┘
```

| Phase           | Source           | Destination            | Key Operations                                 |
| --------------- | ---------------- | ---------------------- | ---------------------------------------------- |
| **Extract**     | CSV (1,322 rows) | `raw.raw_fifa_wc`      | Load as TEXT, no transforms                    |
| **Transform**   | Raw layer        | `stg.stg_fifa_wc`      | Type casting, NULL handling, drop useless cols |
| **Load**        | Staging layer    | Final warehouse tables | Star schema load, referential integrity        |
| **Incremental** | New CSV files    | Warehouse              | Batch tracking, ON CONFLICT DO NOTHING         |

---

## 🛠️ Technologies Used

| Tool           | Purpose                      |
| -------------- | ---------------------------- |
| Python         | ETL pipeline development     |
| PostgreSQL     | Data warehouse storage       |
| psycopg2       | Python-PostgreSQL connection |
| Apache Airflow | Pipeline orchestration       |
| Docker         | Airflow containerization     |
| pgAdmin        | Database management          |

---

## 🚀 How to Run

### 1️⃣ Prerequisites

```bash
pip install psycopg2 pandas
```

### 2️⃣ Setup Database

1. Open **pgAdmin**
2. Create a database named: `fifa_wc_db`
3. Update your credentials in `database/postgresql.py`

### 3️⃣ Place CSV Files

```
data/raw/fifa_wc_mens_match_dataset_1970_2022.csv   ← full load
data/new/fifa_wc_new.csv                            ← incremental load
```

### 4️⃣ Run Full Load Pipeline

```bash
# Activate virtual environment
venv\Scripts\activate        # Windows
source venv/bin/activate     # macOS / Linux

# Run the ETL pipeline
python main.py
```

### ✅ Expected Output

```
Database Connected Successfully
Loading CSV...
Raw layer loaded!
RAW layer loaded successfully
Staging layer loaded!
STAGING layer loaded successfully
Final layer loaded!
WAREHOUSE layer loaded successfully
Batch tracker initialized!
Batch 1 started!
Incremental raw loaded for batch 1!
Incremental staging loaded!
Incremental final loaded!
Batch 1 completed successfully!
```

### 5️⃣ Run Data Profiling

```bash
python profiling/profiling.py
```

### 6️⃣ Run Analysis Queries

```
Open analysis/ folder in pgAdmin
Run each .sql file one by one
```

---

## 🌬️ Airflow Orchestration

### Prerequisites

- ✅ Docker Desktop installed and running

### Start Airflow

```bash
cd airflow
docker-compose up -d
```

### Access Airflow UI

| Setting     | Value                   |
| ----------- | ----------------------- |
| 🌐 URL      | `http://localhost:8080` |
| 👤 Username | `airflow`               |
| 🔑 Password | `airflow`               |

### DAG Overview

| Property  | Value                                         |
| --------- | --------------------------------------------- |
| DAG ID    | `fifa_wc_pipeline`                            |
| Schedule  | `@daily`                                      |
| Task 1    | `extract_raw_layer` — Load CSV to raw table   |
| Task 2    | `transform_stg_layer` — Clean data in staging |
| Task 3    | `load_warehouse_layer` — Load star schema     |
| Task 4    | `incremental_load` — Load new records only    |
| Task Flow | `extract → transform → load → incremental`    |

### Stop Airflow

```bash
docker-compose down
```

---

## 📈 Key Findings & Insights

| Insight              | Detail                                    |
| -------------------- | ----------------------------------------- |
| ⚽ Total Goals       | 1,670 goals across 1,322 matches          |
| 📊 Avg Goals/Match   | 1.26 goals per match                      |
| 🏆 Most Wins         | Brazil — most wins across all tournaments |
| 🟨 Most Cards        | 2,543 yellow cards · 154 red cards total  |
| 🎯 Penalty Shootouts | 66 matches (5% of all matches)            |
| ⏱️ Extra Time        | 109 matches went to extra time (8.2%)     |
| 🌍 Host Advantage    | Host nations show higher win rates        |

### 📊 Summary KPIs

```
⚽ Total Matches          →  1,322
🏆 Total Tournaments      →  14 (1970 – 2022)
🌍 Total Teams            →  83
🥅 Total Goals            →  1,670
📊 Avg Goals per Match    →  1.26
🟨 Total Yellow Cards     →  2,543
🟥 Total Red Cards        →  154
🎯 Penalty Shootouts      →  66 matches
⏱️ Extra Time Matches     →  109 matches
🏟️ Total Stadiums         →  142
```

---

## 📦 Dataset

- **Source:** [FIFA Men's World Cup Dataset — Kaggle](https://www.kaggle.com/datasets)
- **Records:** 1,322
- **Columns:** 70
- **Years:** 1970 — 2022

---

<div align="center">

**Built with ❤️ by Manoj Adhikari using Python · PostgreSQL · Apache Airflow · Docker**

</div>
