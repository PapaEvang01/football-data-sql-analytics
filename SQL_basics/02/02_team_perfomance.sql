-- =====================================================
-- 02_team_performance.sql
-- Football Data SQL Analytics Project
--
-- Description:
-- This script analyzes team performance using match data.
-- It includes:
--   • Overall performance (matches, wins, losses, draws)
--   • Home vs away performance
--   • Goals analysis (offense vs defense)
--   • Win rate evaluation (team strength)
-- =====================================================



-- =====================================================
-- SECTION 1: OVERALL TEAM PERFORMANCE
--
-- Objective:
-- Provide a complete summary of each team’s performance
-- across all matches (home + away combined).
--
-- Metrics:
--   • Total matches played
--   • Total wins
--   • Total losses
--   • Total draws
--
-- Logic:
--   Combine home and away matches using UNION ALL,
--   then classify each match result (WIN / LOSS / DRAW).
-- =====================================================

SELECT
    team,

    COUNT(*) AS total_matches,

    SUM(CASE WHEN result = 'WIN' THEN 1 ELSE 0 END) AS total_wins,
    SUM(CASE WHEN result = 'LOSS' THEN 1 ELSE 0 END) AS total_losses,
    SUM(CASE WHEN result = 'DRAW' THEN 1 ELSE 0 END) AS total_draws

FROM (
    -- Home team perspective
    SELECT
        home_team AS team,
        CASE
            WHEN goal_home_ft > goal_away_ft THEN 'WIN'
            WHEN goal_home_ft < goal_away_ft THEN 'LOSS'
            ELSE 'DRAW'
        END AS result
    FROM matches

    UNION ALL

    -- Away team perspective
    SELECT
        away_team AS team,
        CASE
            WHEN goal_away_ft > goal_home_ft THEN 'WIN'
            WHEN goal_away_ft < goal_home_ft THEN 'LOSS'
            ELSE 'DRAW'
        END AS result
    FROM matches
) AS all_matches

GROUP BY team

-- Sort teams by most wins (strongest first)
ORDER BY total_wins DESC;



-- =====================================================
-- SECTION 2: HOME VS AWAY PERFORMANCE
--
-- Objective:
-- Compare how teams perform depending on match location.
--
-- Metrics:
--   • Home matches vs away matches
--   • Home wins vs away wins
--   • Home draws vs away draws
--   • Home losses vs away losses
--
-- Insight:
-- Helps identify:
--   • Teams that rely on home advantage
--   • Teams that perform consistently away
-- =====================================================

SELECT
    team,

    SUM(home_matches) AS home_matches,
    SUM(away_matches) AS away_matches,

    SUM(home_wins) AS home_wins,
    SUM(away_wins) AS away_wins,

    SUM(home_draws) AS home_draws,
    SUM(away_draws) AS away_draws,

    SUM(home_losses) AS home_losses,
    SUM(away_losses) AS away_losses

FROM (
    -- Home matches contribution
    SELECT
        home_team AS team,

        1 AS home_matches,
        0 AS away_matches,

        CASE WHEN goal_home_ft > goal_away_ft THEN 1 ELSE 0 END AS home_wins,
        0 AS away_wins,

        CASE WHEN goal_home_ft = goal_away_ft THEN 1 ELSE 0 END AS home_draws,
        0 AS away_draws,

        CASE WHEN goal_home_ft < goal_away_ft THEN 1 ELSE 0 END AS home_losses,
        0 AS away_losses
    FROM matches

    UNION ALL

    -- Away matches contribution
    SELECT
        away_team AS team,

        0 AS home_matches,
        1 AS away_matches,

        0 AS home_wins,
        CASE WHEN goal_away_ft > goal_home_ft THEN 1 ELSE 0 END AS away_wins,

        0 AS home_draws,
        CASE WHEN goal_home_ft = goal_away_ft THEN 1 ELSE 0 END AS away_draws,

        0 AS home_losses,
        CASE WHEN goal_away_ft < goal_home_ft THEN 1 ELSE 0 END AS away_losses
    FROM matches
) AS performance_split

GROUP BY team

-- Sort by strongest home performance
ORDER BY home_wins DESC;



-- =====================================================
-- SECTION 3: GOALS ANALYSIS PER TEAM
--
-- Objective:
-- Evaluate offensive and defensive performance.
--
-- Metrics:
--   • Total goals scored (offense)
--   • Total goals conceded (defense)
--   • Goal difference (overall strength)
--   • Average goals scored per match (consistency)
--
-- Insight:
--   • High scoring → strong attack
--   • Low conceded → strong defense
--   • High difference → dominant team
-- =====================================================

SELECT
    team,

    COUNT(*) AS total_matches,

    SUM(goals_scored) AS total_goals_scored,
    SUM(goals_conceded) AS total_goals_conceded,

    SUM(goals_scored) - SUM(goals_conceded) AS goal_difference,

    ROUND(
        CAST(SUM(goals_scored) AS REAL) / COUNT(*),
    2) AS avg_goals_scored_per_match

FROM (
    -- Home perspective
    SELECT
        home_team AS team,
        goal_home_ft AS goals_scored,
        goal_away_ft AS goals_conceded
    FROM matches

    UNION ALL

    -- Away perspective
    SELECT
        away_team AS team,
        goal_away_ft AS goals_scored,
        goal_home_ft AS goals_conceded
    FROM matches
) AS team_goals

GROUP BY team

-- Sort by attacking strength
ORDER BY total_goals_scored DESC;



-- =====================================================
-- SECTION 4: STRONG & WEAK TEAMS (WIN RATE)
--
-- Objective:
-- Evaluate true team performance using win rate.
--
-- Metric:
--   • Win rate (%) = wins / total matches
--
-- Important:
--   Apply minimum match threshold to avoid
--   misleading results from small sample sizes.
--
-- Filter:
--   Only include teams with at least 30 matches
-- =====================================================

SELECT
    team,

    COUNT(*) AS total_matches,

    SUM(CASE WHEN result = 'WIN' THEN 1 ELSE 0 END) AS total_wins,
    SUM(CASE WHEN result = 'LOSS' THEN 1 ELSE 0 END) AS total_losses,
    SUM(CASE WHEN result = 'DRAW' THEN 1 ELSE 0 END) AS total_draws,

    ROUND(
        CAST(SUM(CASE WHEN result = 'WIN' THEN 1 ELSE 0 END) AS REAL)
        / COUNT(*) * 100,
    2) AS win_rate_percentage

FROM (
    -- Home perspective
    SELECT
        home_team AS team,
        CASE
            WHEN goal_home_ft > goal_away_ft THEN 'WIN'
            WHEN goal_home_ft < goal_away_ft THEN 'LOSS'
            ELSE 'DRAW'
        END AS result
    FROM matches

    UNION ALL

    -- Away perspective
    SELECT
        away_team AS team,
        CASE
            WHEN goal_away_ft > goal_home_ft THEN 'WIN'
            WHEN goal_away_ft < goal_home_ft THEN 'LOSS'
            ELSE 'DRAW'
        END AS result
    FROM matches
) AS team_results

GROUP BY team

-- Ensure statistical reliability
HAVING COUNT(*) >= 30

-- Sort by strongest teams (highest win rate)
ORDER BY win_rate_percentage DESC;