-- =====================================================
-- 01_basic_queries.sql
-- =====================================================

-- =====================================================
-- SECTION 1: DATASET OVERVIEW
--
-- Description:
-- This section provides a high-level summary of the dataset,
-- including its size, structure, and temporal coverage.
-- =====================================================


-- =====================================================
-- 1.1 OVERALL DATASET METRICS
-- =====================================================
-- This query compiles key dataset indicators into a single
-- result table using UNION ALL.
--
-- Included metrics:
--   • Total number of matches
--   • Total number of seasons
--   • Total number of unique teams
--   • Average number of matches per season

-- Total number of matches
SELECT 'Total Matches' AS metric, COUNT(*) AS value
FROM matches

UNION ALL

-- Total number of seasons
SELECT 'Total Seasons', COUNT(DISTINCT season)
FROM matches

UNION ALL

-- Total number of unique teams (home + away)
SELECT 'Total Teams', COUNT(*)
FROM (
    SELECT home_team AS team FROM matches
    UNION
    SELECT away_team AS team FROM matches
) AS all_teams

UNION ALL

-- Average number of matches per season
SELECT 'Average Matches per Season',
       ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT season), 2)
FROM matches;


-- =====================================================
-- 1.2 DATASET DATE RANGE
-- =====================================================
-- This query identifies the time span of the dataset by
-- retrieving the earliest and latest recorded match dates.

SELECT 'First Match' AS match, MIN(date) AS date
FROM matches

UNION ALL

SELECT 'Last Match', MAX(date)
FROM matches;



-- =====================================================
-- SECTION 2: GOALS & SCORING
--
-- Description:
-- This section examines scoring behavior across matches,
-- providing insights into goal frequency and distribution.
-- =====================================================


-- =====================================================
-- 2.1 OVERALL GOAL METRICS
-- =====================================================
-- This query summarizes overall scoring using two key metrics:
--   • Total goals scored across all matches
--   • Average goals per match

SELECT 'Total Goals' AS metric,
       SUM(goal_home_ft + goal_away_ft) AS value
FROM matches

UNION ALL

SELECT 'Average Goals per Match',
       ROUND(AVG(goal_home_ft + goal_away_ft), 2)
FROM matches;


-- =====================================================
-- 2.2 SCORING DISTRIBUTION
-- =====================================================
-- This query categorizes matches based on total goals scored,
-- helping to distinguish between low- and high-scoring games.

SELECT '0-0 Matches' AS metric,
       COUNT(*) AS value
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
WHERE (goal_home_ft + goal_away_ft) < 3;



-- =====================================================
-- SECTION 3: MATCH OUTCOMES
--
-- Description:
-- This section analyzes match results, focusing on the
-- distribution of outcomes and evaluating home advantage.
-- =====================================================


-- =====================================================
-- 3.1 MATCH RESULTS DISTRIBUTION
-- =====================================================
-- This query counts the number of matches that ended as:
--   • Home wins
--   • Away wins
--   • Draws

SELECT
    CASE
        WHEN goal_home_ft > goal_away_ft THEN 'Home Win'
        WHEN goal_home_ft < goal_away_ft THEN 'Away Win'
        ELSE 'Draw'
    END AS result,
    COUNT(*) AS total_matches
FROM matches
GROUP BY result
ORDER BY total_matches DESC;


-- =====================================================
-- 3.2 RESULT PERCENTAGES
-- =====================================================
-- This query calculates the percentage distribution of
-- match outcomes, allowing comparison between home wins,
-- away wins, and draws.

SELECT 'Draw Percentage' AS metric,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM matches), 2) AS value
FROM matches
WHERE goal_home_ft = goal_away_ft

UNION ALL

SELECT 'Home Win Percentage',
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM matches), 2)
FROM matches
WHERE goal_home_ft > goal_away_ft

UNION ALL

SELECT 'Away Win Percentage',
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM matches), 2)
FROM matches
WHERE goal_home_ft < goal_away_ft;



-- =====================================================
-- SECTION 4: DISCIPLINE (CARDS)
--
-- Description:
-- This section evaluates disciplinary aspects of matches,
-- focusing on yellow and red cards as indicators of match
-- intensity and referee intervention.
-- =====================================================


-- =====================================================
-- 4.1 OVERALL CARD METRICS
-- =====================================================
-- This query summarizes card-related statistics:
--   • Average total cards per match
--   • Average yellow cards per match
--   • Average red cards per match
--   • Maximum number of cards in a single match

SELECT 'Average Cards per Match' AS metric,
       ROUND(AVG(
           home_yellow_cards + away_yellow_cards +
           home_red_cards + away_red_cards
       ), 2) AS value
FROM matches

UNION ALL

SELECT 'Average Yellow Cards per Match',
       ROUND(AVG(
           home_yellow_cards + away_yellow_cards
       ), 2)
FROM matches

UNION ALL

SELECT 'Average Red Cards per Match',
       ROUND(AVG(
           home_red_cards + away_red_cards
       ), 2)
FROM matches

UNION ALL

SELECT 'Maximum Cards in a Match',
       MAX(
           home_yellow_cards + away_yellow_cards +
           home_red_cards + away_red_cards
       )
FROM matches;