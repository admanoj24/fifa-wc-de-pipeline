import psycopg2
import os

def get_connection():
    conn = psycopg2.connect(
        host=os.getenv("DB_HOST", "localhost"),
        port=os.getenv("DB_PORT", 5432),
        database=os.getenv("DB_NAME", "fifa_wc_db"),
        user=os.getenv("DB_USER", "postgres"),
        password=os.getenv("DB_PASSWORD", "admin@54321")
    )
    return conn