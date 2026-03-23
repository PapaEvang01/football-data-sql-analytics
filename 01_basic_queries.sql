-- =====================================================
-- 01_basic_queries.sql
-- Football Data SQL Analytics Project
--
-- Description:
-- This script contains fundamental SQL queries used to
-- explore and analyze football match data.
-- =====================================================


-- =====================================================
-- SECTION 1: OVERVIEW METRICS
-- Total matches, teams, and seasons
-- =====================================================
SELECT 'Total Matches' AS metric, COUNT(*) AS value
FROM matches

UNION ALL

SELECT 'Total Teams' AS metric, COUNT(*) AS value
FROM (
    SELECT home_team FROM matches
    UNION
    SELECT away_team FROM matches
)

UNION ALL

SELECT 'Total Seasons' AS metric, COUNT(DISTINCT season) AS value
FROM matches;


-- =====================================================
-- SECTION 2: HIGH-SCORING MATCHES
-- Top 10 matches with the most goals
-- =====================================================
SELECT
    date,
    season,
    home_team,
    away_team,
    goal_home_ft,
    goal_away_ft,
    (goal_home_ft + goal_away_ft) AS total_goals
FROM matches
ORDER BY total_goals DESC
LIMIT 10;


-- =====================================================
-- SECTION 3: MOST INTENSE MATCHES
-- Based on total cards (yellow + red)
-- =====================================================
SELECT
    date,
    season,
    home_team,
    away_team,
    home_yellow_cards,
    away_yellow_cards,
    home_red_cards,
    away_red_cards,
    (
        home_yellow_cards + away_yellow_cards +
        home_red_cards + away_red_cards
    ) AS total_cards
FROM matches
ORDER BY total_cards DESC
LIMIT 10;


-- =====================================================
-- SECTION 4: TEAM PERFORMANCE ANALYSIS
-- =====================================================

-- 4A. Teams with most goals scored
SELECT
    team_name,
    SUM(goals_scored) AS total_goals
FROM (
    SELECT home_team AS team_name, goal_home_ft AS goals_scored
    FROM matches

    UNION ALL

    SELECT away_team AS team_name, goal_away_ft AS goals_scored
    FROM matches
) AS all_goals
GROUP BY team_name
ORDER BY total_goals DESC
LIMIT 10;


-- 4B. Teams with most wins
SELECT
    team_name,
    COUNT(*) AS total_wins
FROM (
    SELECT home_team AS team_name
    FROM matches
    WHERE goal_home_ft > goal_away_ft

    UNION ALL

    SELECT away_team AS team_name
    FROM matches
    WHERE goal_away_ft > goal_home_ft
) AS winning_teams
GROUP BY team_name
ORDER BY total_wins DESC
LIMIT 10;


-- =====================================================
-- SECTION 5: MATCH OUTCOMES DISTRIBUTION
-- =====================================================
SELECT 'Draws' AS metric, COUNT(*) AS value
FROM matches
WHERE goal_home_ft = goal_away_ft

UNION ALL

SELECT 'Home Wins' AS metric, COUNT(*) AS value
FROM matches
WHERE goal_home_ft > goal_away_ft

UNION ALL

SELECT 'Away Wins' AS metric, COUNT(*) AS value
FROM matches
WHERE goal_home_ft < goal_away_ft;


-- =====================================================
-- SECTION 6: GOAL DISTRIBUTION ANALYSIS
-- =====================================================
SELECT
    SUM(CASE WHEN (goal_home_ft + goal_away_ft) > 3 THEN 1 ELSE 0 END) AS more_than_3,
    SUM(CASE WHEN (goal_home_ft + goal_away_ft) = 3 THEN 1 ELSE 0 END) AS exactly_3,
    SUM(CASE WHEN (goal_home_ft + goal_away_ft) < 3 THEN 1 ELSE 0 END) AS less_than_3
FROM matches;


-- =====================================================
-- SECTION 7: MATCHES PER YEAR
-- =====================================================
SELECT
    strftime('%Y', date) AS match_year,
    COUNT(*) AS total_matches
FROM matches
GROUP BY strftime('%Y', date)
ORDER BY match_year;