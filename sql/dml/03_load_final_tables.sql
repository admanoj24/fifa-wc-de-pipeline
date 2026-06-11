-- dim_tournament
INSERT INTO final.dim_tournament (tournament_name, tournament_year)
SELECT DISTINCT
    tournament_name,
    SUBSTRING(tournament_name, 1, 4)::SMALLINT AS tournament_year
FROM stg.stg_fifa_wc
WHERE tournament_name IS NOT NULL
ON CONFLICT DO NOTHING;

-- dim_team
INSERT INTO final.dim_team (team_name, team_code)
SELECT DISTINCT
    team_name,
    team_code
FROM stg.stg_fifa_wc
WHERE team_name IS NOT NULL
ON CONFLICT DO NOTHING;

-- dim_venue
INSERT INTO final.dim_venue (stadium_name, city_name, country_name)
SELECT DISTINCT
    stadium_name,
    city_name,
    country_name
FROM stg.stg_fifa_wc
WHERE stadium_name IS NOT NULL
ON CONFLICT DO NOTHING;

-- dim_stage
INSERT INTO final.dim_stage (stage_name, group_stage, knockout_stage)
SELECT DISTINCT
    stage_name,
    group_stage,
    knockout_stage
FROM stg.stg_fifa_wc
WHERE stage_name IS NOT NULL
ON CONFLICT DO NOTHING;

-- dim_date
INSERT INTO final.dim_date (
    match_date,
    match_year,
    match_month,
    match_day,
    day_of_week
)
SELECT DISTINCT
    match_date,
    EXTRACT(YEAR FROM match_date)::SMALLINT,
    EXTRACT(MONTH FROM match_date)::SMALLINT,
    EXTRACT(DAY FROM match_date)::SMALLINT,
    TO_CHAR(match_date, 'Day')
FROM stg.stg_fifa_wc
WHERE match_date IS NOT NULL
ON CONFLICT DO NOTHING;

-- fact_match
INSERT INTO final.fact_match (
    tournament_id,
    team_id,
    opponent_id,
    venue_id,
    stage_id,
    date_id,
    match_time,
    home_team,
    away_team,
    goals_for,
    goals_against,
    extra_time,
    penalty_shootout,
    penalties_for,
    penalties_against,
    result,
    outcome,
    is_host,
    yellow_cards,
    red_cards,
    possession,
    shots,
    shots_on_target,
    passes_completed,
    passes_attempted,
    corners,
    fouls,
    team_prior_win_rate,
    team_prior_goals_scored_avg,
    team_prior_goals_conceded_avg,
    opp_prior_win_rate,
    team_curr_form_pts_avg,
    team_curr_goals_scored_avg,
    team_curr_goals_conceded_avg
)
SELECT
    t.tournament_id,
    tm.team_id,
    opp.team_id,
    v.venue_id,
    st.stage_id,
    d.date_id,
    s.match_time,
    s.home_team,
    s.away_team,
    s.goals_for,
    s.goals_against,
    s.extra_time,
    s.penalty_shootout,
    s.penalties_for,
    s.penalties_against,
    s.result,
    s.outcome,
    s.is_host,
    s.yellow_cards,
    s.red_cards,
    s.possession,
    s.shots,
    s.shots_on_target,
    s.passes_completed,
    s.passes_attempted,
    s.corners,
    s.fouls,
    s.team_prior_win_rate,
    s.team_prior_goals_scored_avg,
    s.team_prior_goals_conceded_avg,
    s.opp_prior_win_rate,
    s.team_curr_form_pts_avg,
    s.team_curr_goals_scored_avg,
    s.team_curr_goals_conceded_avg
FROM stg.stg_fifa_wc s
JOIN final.dim_tournament t
    ON t.tournament_name = s.tournament_name
JOIN final.dim_team tm
    ON tm.team_name = s.team_name
    AND tm.team_code = s.team_code
JOIN final.dim_team opp
    ON opp.team_name = s.opponent_name
    AND opp.team_code = s.opponent_code
JOIN final.dim_venue v
    ON v.stadium_name = s.stadium_name
    AND v.city_name = s.city_name
JOIN final.dim_stage st
    ON st.stage_name = s.stage_name
JOIN final.dim_date d
    ON d.match_date = s.match_date
WHERE s.goals_for IS NOT NULL
AND s.goals_against IS NOT NULL;