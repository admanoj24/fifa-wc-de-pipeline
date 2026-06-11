CREATE SCHEMA IF NOT EXISTS final;

-- Dimension: Tournament
CREATE TABLE IF NOT EXISTS final.dim_tournament (
    tournament_id   SERIAL PRIMARY KEY,
    tournament_name VARCHAR(100) NOT NULL UNIQUE,
    tournament_year SMALLINT NOT NULL
);

-- Dimension: Team
CREATE TABLE IF NOT EXISTS final.dim_team (
    team_id     SERIAL PRIMARY KEY,
    team_name   VARCHAR(100) NOT NULL,
    team_code   VARCHAR(10) NOT NULL,
    UNIQUE (team_name, team_code)
);

-- Dimension: Venue
CREATE TABLE IF NOT EXISTS final.dim_venue (
    venue_id        SERIAL PRIMARY KEY,
    stadium_name    VARCHAR(100) NOT NULL,
    city_name       VARCHAR(100) NOT NULL,
    country_name    VARCHAR(100) NOT NULL,
    UNIQUE (stadium_name, city_name)
);

-- Dimension: Stage
CREATE TABLE IF NOT EXISTS final.dim_stage (
    stage_id        SERIAL PRIMARY KEY,
    stage_name      VARCHAR(50) NOT NULL UNIQUE,
    group_stage     SMALLINT NOT NULL,
    knockout_stage  SMALLINT NOT NULL
);

-- Dimension: Date
CREATE TABLE IF NOT EXISTS final.dim_date (
    date_id         SERIAL PRIMARY KEY,
    match_date      DATE NOT NULL UNIQUE,
    match_year      SMALLINT NOT NULL,
    match_month     SMALLINT NOT NULL,
    match_day       SMALLINT NOT NULL,
    day_of_week     VARCHAR(20) NOT NULL
);

-- Fact Table: Match
CREATE TABLE IF NOT EXISTS final.fact_match (
    fact_id                         SERIAL PRIMARY KEY,
    tournament_id                   INT REFERENCES final.dim_tournament(tournament_id),
    team_id                         INT REFERENCES final.dim_team(team_id),
    opponent_id                     INT REFERENCES final.dim_team(team_id),
    venue_id                        INT REFERENCES final.dim_venue(venue_id),
    stage_id                        INT REFERENCES final.dim_stage(stage_id),
    date_id                         INT REFERENCES final.dim_date(date_id),
    match_time                      TIME NULL,
    home_team                       SMALLINT NULL,
    away_team                       SMALLINT NULL,
    goals_for                       SMALLINT NULL,
    goals_against                   SMALLINT NULL,
    extra_time                      SMALLINT NULL,
    penalty_shootout                SMALLINT NULL,
    penalties_for                   SMALLINT NULL,
    penalties_against               SMALLINT NULL,
    result                          VARCHAR(10) NULL,
    outcome                         VARCHAR(10) NULL,
    is_host                         SMALLINT NULL,
    yellow_cards                    SMALLINT NULL,
    red_cards                       SMALLINT NULL,
    possession                      NUMERIC(5,2) NULL,
    shots                           SMALLINT NULL,
    shots_on_target                 SMALLINT NULL,
    passes_completed                SMALLINT NULL,
    passes_attempted                SMALLINT NULL,
    corners                         SMALLINT NULL,
    fouls                           SMALLINT NULL,
    team_prior_win_rate             NUMERIC(5,4) NULL,
    team_prior_goals_scored_avg     NUMERIC(5,2) NULL,
    team_prior_goals_conceded_avg   NUMERIC(5,2) NULL,
    opp_prior_win_rate              NUMERIC(5,4) NULL,
    team_curr_form_pts_avg          NUMERIC(5,2) NULL,
    team_curr_goals_scored_avg      NUMERIC(5,2) NULL,
    team_curr_goals_conceded_avg    NUMERIC(5,2) NULL
);