-- MATCHES BY STAGE
SELECT
    s.stage_name,
    COUNT(*) AS total_matches,
    SUM(f.goals_for) AS total_goals,
    ROUND(AVG(f.goals_for), 2) AS avg_goals
FROM final.fact_match f
JOIN final.dim_stage s ON s.stage_id = f.stage_id
GROUP BY s.stage_name
ORDER BY total_matches DESC;

-- WIN RATE BY STAGE
SELECT
    s.stage_name,
    COUNT(*) AS total_matches,
    SUM(CASE WHEN f.outcome = 'Win' THEN 1 ELSE 0 END) AS total_wins,
    SUM(CASE WHEN f.outcome = 'Draw' THEN 1 ELSE 0 END) AS total_draws,
    ROUND(SUM(CASE WHEN f.outcome = 'Win' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS win_rate
FROM final.fact_match f
JOIN final.dim_stage s ON s.stage_id = f.stage_id
GROUP BY s.stage_name
ORDER BY win_rate DESC;

-- EXTRA TIME AND PENALTIES BY STAGE
SELECT
    s.stage_name,
    SUM(f.extra_time) AS extra_time_matches,
    SUM(f.penalty_shootout) AS penalty_shootout_matches
FROM final.fact_match f
JOIN final.dim_stage s ON s.stage_id = f.stage_id
GROUP BY s.stage_name
ORDER BY penalty_shootout_matches DESC;