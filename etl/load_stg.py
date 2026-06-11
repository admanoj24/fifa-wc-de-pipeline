from src.sql_utils import read_sql_file

def initialize_stg_layer(cur):
    stg_ddl_query = read_sql_file("sql/ddl/02_create_stg_tables.sql")
    cur.execute(stg_ddl_query)
    cur.execute("TRUNCATE TABLE stg.stg_fifa_wc;")

def load_stg_layer(cur):
    stg_dml_query = read_sql_file("sql/dml/02_load_stg_tables.sql")
    cur.execute(stg_dml_query)
    print("Staging layer loaded!")