-- TOP 10 TEAMS BY WINS
SELECT
    t.team_name,
    COUNT(*) AS total_matches,
    SUM(CASE WHEN f.outcome = 'Win' THEN 1 ELSE 0 END) AS total_wins,
    SUM(CASE WHEN f.outcome = 'Draw' THEN 1 ELSE 0 END) AS total_draws,
    SUM(CASE WHEN f.outcome = 'Loss' THEN 1 ELSE 0 END) AS total_losses,
    ROUND(SUM(CASE WHEN f.outcome = 'Win' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS win_rate
FROM final.fact_match f
JOIN final.dim_team t ON t.team_id = f.team_id
GROUP BY t.team_name
ORDER BY total_wins DESC
LIMIT 10;

-- TOP 10 TEAMS BY GOALS SCORED
SELECT
    t.team_name,
    SUM(f.goals_for) AS total_goals_scored,
    ROUND(AVG(f.goals_for), 2) AS avg_goals_per_match
FROM final.fact_match f
JOIN final.dim_team t ON t.team_id = f.team_id
GROUP BY t.team_name
ORDER BY total_goals_scored DESC
LIMIT 10;

-- TOP 10 TEAMS BY APPEARANCES
SELECT
    t.team_name,
    COUNT(*) AS total_appearances
FROM final.fact_match f
JOIN final.dim_team t ON t.team_id = f.team_id
GROUP BY t.team_name
ORDER BY total_appearances DESC
LIMIT 10;

-- MOST DISCIPLINED TEAMS (LEAST YELLOW CARDS)
SELECT
    t.team_name,
    SUM(f.yellow_cards) AS total_yellow_cards,
    SUM(f.red_cards) AS total_red_cards
FROM final.fact_match f
JOIN final.dim_team t ON t.team_id = f.team_id
WHERE f.yellow_cards IS NOT NULL
GROUP BY t.team_name
ORDER BY total_yellow_cards ASC
LIMIT 10;

-- MOST AGGRESSIVE TEAMS (MOST YELLOW CARDS)
SELECT
    t.team_name,
    SUM(f.yellow_cards) AS total_yellow_cards,
    SUM(f.red_cards) AS total_red_cards
FROM final.fact_match f
JOIN final.dim_team t ON t.team_id = f.team_id
WHERE f.yellow_cards IS NOT NULL
GROUP BY t.team_name
ORDER BY total_yellow_cards DESC
LIMIT 10;