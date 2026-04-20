-- =====================================================
-- 01_general_summary.sql
-- =====================================================
--
-- Description:
-- This script generates a single unified summary table
-- that captures the most important statistics of the
-- football dataset.
--
-- The output is structured as:
--   metric | value
--
-- It combines multiple analytical sections into one
-- result using UNION ALL, making it ideal for exporting
-- to CSV and further analysis in Python.
--
-- =====================================================


-- Overall dataset metrics
SELECT 'Total Matches' AS metric, COUNT(*) AS value
FROM matches

UNION ALL

SELECT 'Total Seasons', COUNT(DISTINCT season)
FROM matches

UNION ALL

-- Count unique teams (home + away)
SELECT 'Total Teams', COUNT(*)
FROM (
    SELECT home_team FROM matches
    UNION
    SELECT away_team FROM matches
) AS teams

UNION ALL

-- Average matches per season
SELECT 'Average Matches per Season',
       ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT season), 2)
FROM matches

UNION ALL

-- Date range
SELECT 'First Match', MIN(date)
FROM matches

UNION ALL

SELECT 'Last Match', MAX(date)
FROM matches

UNION ALL

-- Goal statistics
SELECT 'Total Goals',
       SUM(goal_home_ft + goal_away_ft)
FROM matches

UNION ALL

SELECT 'Average Goals per Match',
       ROUND(AVG(goal_home_ft + goal_away_ft), 2)
FROM matches

UNION ALL

-- Scoring distribution
SELECT '0-0 Matches',
       COUNT(*)
FROM matches
WHERE goal_home_ft = 0 AND goal_away_ft = 0

UNION ALL

SELECT 'Matches with > 3 Goals',
       COUNT(*)
FROM matches
WHERE (goal_home_ft + goal_away_ft) > 3

UNION ALL

SELECT 'Matches with = 3 Goals',
       COUNT(*)
FROM matches
WHERE (goal_home_ft + goal_away_ft) = 3

UNION ALL

SELECT 'Matches with < 3 Goals',
       COUNT(*)
FROM matches
WHERE (goal_home_ft + goal_away_ft) < 3

UNION ALL

-- Match outcomes
SELECT 'Home Wins',
       COUNT(*)
FROM matches
WHERE goal_home_ft > goal_away_ft

UNION ALL

SELECT 'Away Wins',
       COUNT(*)
FROM matches
WHERE goal_home_ft < goal_away_ft

UNION ALL

SELECT 'Draws',
       COUNT(*)
FROM matches
WHERE goal_home_ft = goal_away_ft

UNION ALL

-- Outcome percentages
SELECT 'Home Win Percentage',
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM matches), 2)
FROM matches
WHERE goal_home_ft > goal_away_ft

UNION ALL

SELECT 'Away Win Percentage',
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM matches), 2)
FROM matches
WHERE goal_home_ft < goal_away_ft

UNION ALL

SELECT 'Draw Percentage',
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM matches), 2)
FROM matches
WHERE goal_home_ft = goal_away_ft

UNION ALL

-- Card statistics
SELECT 'Average Cards per Match',
       ROUND(AVG(
           home_yellow_cards + away_yellow_cards +
           home_red_cards + away_red_cards
       ), 2)
FROM matches

UNION ALL

SELECT 'Average Yellow Cards per Match',
       ROUND(AVG(home_yellow_cards + away_yellow_cards), 2)
FROM matches

UNION ALL

SELECT 'Average Red Cards per Match',
       ROUND(AVG(home_red_cards + away_red_cards), 2)
FROM matches

UNION ALL

SELECT 'Maximum Cards in a Match',
       MAX(
           home_yellow_cards + away_yellow_cards +
           home_red_cards + away_red_cards
       )
FROM matches;