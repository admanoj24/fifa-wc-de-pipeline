from src.sql_utils import read_sql_file

def initialize_final_layer(cur):
    final_ddl_query = read_sql_file("sql/ddl/03_create_final_tables.sql")
    cur.execute(final_ddl_query)
    cur.execute("""
        TRUNCATE TABLE final.fact_match CASCADE;
        TRUNCATE TABLE final.dim_tournament CASCADE;
        TRUNCATE TABLE final.dim_team CASCADE;
        TRUNCATE TABLE final.dim_venue CASCADE;
        TRUNCATE TABLE final.dim_stage CASCADE;
        TRUNCATE TABLE final.dim_date CASCADE;
    """)

def load_final_layer(cur):
    final_dml_query = read_sql_file("sql/dml/03_load_final_tables.sql")
    cur.execute(final_dml_query)
    print("Final layer loaded!")