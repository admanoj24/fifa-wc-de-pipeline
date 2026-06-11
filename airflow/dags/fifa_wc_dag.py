from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
import sys
import os

sys.path.insert(0, "/opt/airflow/project")

os.environ["DB_HOST"] = "host.docker.internal"
os.environ["DB_PORT"] = "5432"
os.environ["DB_NAME"] = "fifa_wc_db"
os.environ["DB_USER"] = "postgres"
os.environ["DB_PASSWORD"] = "admin@54321"
os.environ["PROJECT_DIR"] = "/opt/airflow/project"

from database import get_connection
from etl.load_raw import initialize_raw_layer, load_raw_layer
from etl.load_stg import initialize_stg_layer, load_stg_layer
from etl.load_final import initialize_final_layer, load_final_layer
from etl.load_incremental import (
    initialize_batch_tracker,
    start_batch,
    end_batch,
    load_incremental_raw,
    load_incremental_stg,
    load_incremental_final
)

# # # # # # # # # # # # # # # #
# # # DEFAULT ARGUMENTS # # # #
# # # # # # # # # # # # # # # #
default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

# # # # # # # # # # # # # # # #
# # # # TASK FUNCTIONS # # # #
# # # # # # # # # # # # # # # #
def task_load_raw():
    conn = get_connection()
    cur = conn.cursor()
    initialize_raw_layer(cur)
    load_raw_layer(cur)
    conn.commit()
    conn.close()
    print("RAW layer loaded successfully")

def task_load_stg():
    conn = get_connection()
    cur = conn.cursor()
    initialize_stg_layer(cur)
    load_stg_layer(cur)
    conn.commit()
    conn.close()
    print("STAGING layer loaded successfully")

def task_load_final():
    conn = get_connection()
    cur = conn.cursor()
    initialize_final_layer(cur)
    load_final_layer(cur)
    conn.commit()
    conn.close()
    print("WAREHOUSE layer loaded successfully")

def task_incremental_load():
    conn = get_connection()
    cur = conn.cursor()

    initialize_batch_tracker(cur)
    conn.commit()

    batch_id = start_batch(cur)
    conn.commit()
    print(f"Batch {batch_id} started!")

    try:
        load_incremental_raw(
            cur,
            batch_id,
            "/opt/airflow/project/data/new/fifa_wc_new.csv"
        )
        load_incremental_stg(cur)
        load_incremental_final(cur)
        conn.commit()

        end_batch(cur, batch_id, "success")
        conn.commit()
        print(f"Batch {batch_id} completed successfully!")

    except Exception as e:
        end_batch(cur, batch_id, "failed", str(e))
        conn.commit()
        print(f"Batch {batch_id} failed: {e}")

    conn.close()

# # # # # # # # # # # # # # # #
# # # # DAG DEFINITION # # # #
# # # # # # # # # # # # # # # #
with DAG(
    "fifa_wc_pipeline",
    default_args=default_args,
    description="FIFA World Cup Data Engineering Pipeline",
    schedule_interval="@daily",
    start_date=datetime(2024, 1, 1),
    catchup=False,
) as dag:

    raw_layer = PythonOperator(
        task_id="extract_raw_layer",
        python_callable=task_load_raw,
    )

    stg_layer = PythonOperator(
        task_id="transform_stg_layer",
        python_callable=task_load_stg,
    )

    final_layer = PythonOperator(
        task_id="load_warehouse_layer",
        python_callable=task_load_final,
    )

    incremental = PythonOperator(
        task_id="incremental_load",
        python_callable=task_incremental_load,
    )

    # # TASK DEPENDENCIES
    raw_layer >> stg_layer >> final_layer >> incremental