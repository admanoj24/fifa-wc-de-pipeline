-- TOTAL MATCHES
SELECT COUNT(*) AS total_matches
FROM final.fact_match;

-- TOTAL GOALS SCORED
SELECT SUM(goals_for) AS total_goals
FROM final.fact_match;

-- AVERAGE GOALS PER MATCH
SELECT ROUND(AVG(goals_for), 2) AS avg_goals_per_match
FROM final.fact_match;

-- TOTAL TOURNAMENTS
SELECT COUNT(*) AS total_tournaments
FROM final.dim_tournament;

-- TOTAL TEAMS
SELECT COUNT(*) AS total_teams
FROM final.dim_team;

-- MATCH OUTCOMES DISTRIBUTION
SELECT
    outcome,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM final.fact_match
GROUP BY outcome
ORDER BY total DESC;

-- TOTAL YELLOW CARDS
SELECT SUM(yellow_cards) AS total_yellow_cards
FROM final.fact_match
WHERE yellow_cards IS NOT NULL;

-- TOTAL RED CARDS
SELECT SUM(red_cards) AS total_red_cards
FROM final.fact_match
WHERE red_cards IS NOT NULL;

-- MATCHES WITH PENALTY SHOOTOUT
SELECT COUNT(*) AS penalty_shootout_matches
FROM final.fact_match
WHERE penalty_shootout = 1;

-- MATCHES WITH EXTRA TIME
SELECT COUNT(*) AS extra_time_matches
FROM final.fact_match
WHERE extra_time = 1;