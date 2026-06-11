import csv
from src.sql_utils import read_sql_file

def initialize_batch_tracker(cur):
    batch_ddl_query = read_sql_file("sql/ddl/04_create_batch_tracker.sql")
    cur.execute(batch_ddl_query)
    print("Batch tracker initialized!")

def start_batch(cur):
    cur.execute("""
        INSERT INTO raw.batch_runs (status, start_time)
        VALUES ('running', NOW())
        RETURNING batch_id;
    """)
    batch_id = cur.fetchone()[0]
    return batch_id

def end_batch(cur, batch_id, status, error_message=None):
    cur.execute("""
        UPDATE raw.batch_runs
        SET status = %s,
            end_time = NOW(),
            error_message = %s
        WHERE batch_id = %s;
    """, (status, error_message, batch_id))

def load_incremental_raw(cur, batch_id, file_path):
    incremental_dml_query = read_sql_file("sql/dml/04_load_incremental.sql")
    print(f"Loading new CSV for batch {batch_id}...")
    with open(file_path, "r") as file:
        rows = csv.DictReader(file)
        for row in rows:
            row = {k.strip(): v.strip() for k, v in row.items()}
            row = {k: (None if v == "" else v) for k, v in row.items()}
            cur.execute(incremental_dml_query, (
                row["tournament_name"],
                row["stage_name"],
                row["group_name"],
                row["group_stage"],
                row["knockout_stage"],
                row["replayed"],
                row["replay"],
                row["match_date"],
                row["match_time"],
                row["stadium_name"],
                row["city_name"],
                row["country_name"],
                row["team_name"],
                row["team_code"],
                row["opponent_name"],
                row["opponent_code"],
                row["home_team"],
                row["away_team"],
                row["goals_for"],
                row["goals_against"],
                row["extra_time"],
                row["penalty_shootout"],
                row["penalties_for"],
                row["penalties_against"],
                row["result"],
                row["is_host"],
                row["yellow_cards"],
                row["red_cards"],
                row["possession"],
                row["shots"],
                row["shots_on_target"],
                row["passes_completed"],
                row["passes_attempted"],
                row["corners"],
                row["fouls"],
                row["team_prior_matches"],
                row["team_prior_win_rate"],
                row["team_prior_goals_scored_avg"],
                row["team_prior_goals_conceded_avg"],
                row["opp_prior_matches"],
                row["opp_prior_win_rate"],
                row["opp_prior_goals_scored_avg"],
                row["opp_prior_goals_conceded_avg"],
                row["h2h_prior_matches"],
                row["h2h_prior_win_rate"],
                row["team_curr_form_pts_avg"],
                row["team_curr_goals_scored_avg"],
                row["team_curr_goals_conceded_avg"],
                row["opp_curr_form_pts_avg"],
                row["opp_curr_goals_scored_avg"],
                row["opp_curr_goals_conceded_avg"],
                row["possession_h1"],
                row["possession_h2"],
                row["shots_h1"],
                row["shots_h2"],
                row["shots_on_target_h1"],
                row["shots_on_target_h2"],
                row["passes_completed_h1"],
                row["passes_completed_h2"],
                row["passes_attempted_h1"],
                row["passes_attempted_h2"],
                row["corners_h1"],
                row["corners_h2"],
                row["fouls_h1"],
                row["fouls_h2"],
                row["yellow_cards_h1"],
                row["yellow_cards_h2"],
                row["red_cards_h1"],
                row["red_cards_h2"],
                row["outcome"],
                batch_id
            ))
    print(f"Incremental raw loaded for batch {batch_id}!")

def load_incremental_stg(cur):
    cur.execute("TRUNCATE TABLE stg.stg_fifa_wc;")
    stg_dml_query = read_sql_file("sql/dml/02_load_stg_tables.sql")
    cur.execute(stg_dml_query)
    print("Incremental staging loaded!")

def load_incremental_final(cur):
    cur.execute("TRUNCATE TABLE final.fact_match CASCADE;")
    cur.execute("TRUNCATE TABLE final.dim_tournament CASCADE;")
    cur.execute("TRUNCATE TABLE final.dim_team CASCADE;")
    cur.execute("TRUNCATE TABLE final.dim_venue CASCADE;")
    cur.execute("TRUNCATE TABLE final.dim_stage CASCADE;")
    cur.execute("TRUNCATE TABLE final.dim_date CASCADE;")
    final_dml_query = read_sql_file("sql/dml/03_load_final_tables.sql")
    cur.execute(final_dml_query)
    print("Incremental final loaded!")