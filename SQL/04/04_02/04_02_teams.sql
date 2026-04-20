-- =====================================================
-- 04_team_summary.sql
-- Final team performance summary table
-- =====================================================

-- This query creates a complete performance profile
-- for each team by combining home and away matches
-- into a unified structure.

SELECT
    team,

    COUNT(DISTINCT season) AS total_seasons,
    COUNT(*) AS total_matches,

    SUM(CASE WHEN result = 'WIN' THEN 1 ELSE 0 END) AS total_wins,
    SUM(CASE WHEN result = 'DRAW' THEN 1 ELSE 0 END) AS total_draws,
    SUM(CASE WHEN result = 'LOSS' THEN 1 ELSE 0 END) AS total_losses,

    -- Overall result rates
    ROUND(100.0 * SUM(CASE WHEN result = 'WIN' THEN 1 ELSE 0 END) / COUNT(*), 2) AS win_rate_pct,
    ROUND(100.0 * SUM(CASE WHEN result = 'LOSS' THEN 1 ELSE 0 END) / COUNT(*), 2) AS loss_rate_pct,
    ROUND(100.0 * SUM(CASE WHEN result = 'DRAW' THEN 1 ELSE 0 END) / COUNT(*), 2) AS draw_rate_pct,

    -- Home result rates
    ROUND(100.0 * SUM(CASE WHEN location = 'HOME' AND result = 'WIN' THEN 1 ELSE 0 END)
        / SUM(CASE WHEN location = 'HOME' THEN 1 ELSE 0 END), 2) AS home_win_rate_pct,

    ROUND(100.0 * SUM(CASE WHEN location = 'HOME' AND result = 'LOSS' THEN 1 ELSE 0 END)
        / SUM(CASE WHEN location = 'HOME' THEN 1 ELSE 0 END), 2) AS home_loss_rate_pct,

    ROUND(100.0 * SUM(CASE WHEN location = 'HOME' AND result = 'DRAW' THEN 1 ELSE 0 END)
        / SUM(CASE WHEN location = 'HOME' THEN 1 ELSE 0 END), 2) AS home_draw_rate_pct,

    -- Away result rates
    ROUND(100.0 * SUM(CASE WHEN location = 'AWAY' AND result = 'WIN' THEN 1 ELSE 0 END)
        / SUM(CASE WHEN location = 'AWAY' THEN 1 ELSE 0 END), 2) AS away_win_rate_pct,

    ROUND(100.0 * SUM(CASE WHEN location = 'AWAY' AND result = 'LOSS' THEN 1 ELSE 0 END)
        / SUM(CASE WHEN location = 'AWAY' THEN 1 ELSE 0 END), 2) AS away_loss_rate_pct,

    ROUND(100.0 * SUM(CASE WHEN location = 'AWAY' AND result = 'DRAW' THEN 1 ELSE 0 END)
        / SUM(CASE WHEN location = 'AWAY' THEN 1 ELSE 0 END), 2) AS away_draw_rate_pct,

    -- Goal metrics
    ROUND(AVG(goals_scored), 2) AS avg_goals_scored,
    ROUND(AVG(goals_conceded), 2) AS avg_goals_conceded,
    ROUND(AVG(goals_scored - goals_conceded), 2) AS avg_goal_difference

FROM (

    -- Home matches perspective
    SELECT
        home_team AS team,
        season,
        'HOME' AS location,

        CASE
            WHEN goal_home_ft > goal_away_ft THEN 'WIN'
            WHEN goal_home_ft < goal_away_ft THEN 'LOSS'
            ELSE 'DRAW'
        END AS result,

        goal_home_ft AS goals_scored,
        goal_away_ft AS goals_conceded

    FROM matches

    UNION ALL

    -- Away matches perspective
    SELECT
        away_team AS team,
        season,
        'AWAY' AS location,

        CASE
            WHEN goal_away_ft > goal_home_ft THEN 'WIN'
            WHEN goal_away_ft < goal_home_ft THEN 'LOSS'
            ELSE 'DRAW'
        END AS result,

        goal_away_ft AS goals_scored,
        goal_home_ft AS goals_conceded

    FROM matches

) AS team_data

GROUP BY team

-- Sort by strongest teams (highest win rate)
ORDER BY win_rate_pct DESC;