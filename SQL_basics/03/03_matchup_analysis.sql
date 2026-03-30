-- =====================================================
-- 03_matchup_analysis.sql
--
-- Description:
-- This script analyzes head-to-head matchups between teams,
-- focusing on how often teams face each other, how those
-- matches typically end, and how they differ in terms of
-- scoring and competitiveness.
--
-- The analysis includes matchup frequency, win/draw breakdown,
-- goal statistics (total and average), and goal difference
-- to identify both high-scoring rivalries and more balanced
-- or one-sided matchups.
--
-- The script uses standard SQL techniques such as GROUP BY,
-- aggregation functions (COUNT, SUM, AVG), CASE WHEN logic,
-- and Common Table Expressions (CTEs) to structure the analysis
-- in a clear and readable way.
-- =====================================================

-- =====================================================
-- SECTION 1: TOP 20 MOST FREQUENT MATCHUPS
--
-- Description:
-- This query identifies the top 20 most common matchups
-- between pairs of teams. Team pairs are normalized so
-- that (A vs B) = (B vs A).
-- =====================================================

WITH matchups AS (
    SELECT
        CASE 
            WHEN home_team < away_team THEN home_team
            ELSE away_team
        END AS team_1,
        CASE 
            WHEN home_team < away_team THEN away_team
            ELSE home_team
        END AS team_2
    FROM matches
),

matchup_counts AS (
    SELECT
        team_1,
        team_2,
        COUNT(*) AS total_matches
    FROM matchups
    GROUP BY team_1, team_2
)

SELECT
    team_1,
    team_2,
    total_matches
FROM matchup_counts
ORDER BY total_matches DESC
LIMIT 20;

-- =====================================================
-- SECTION 2: RESULTS BREAKDOWN FOR TOP 20 MATCHUPS
--
-- Description:
-- This section analyzes the top 20 most frequent matchups
-- and shows the head-to-head results for each pair:
--   - total matches
--   - wins for team_1
--   - wins for team_2
--   - draws
--
-- Team pairs are normalized so that (A vs B) = (B vs A),
-- while the original home/away information is preserved
-- in order to assign wins correctly.
-- =====================================================

WITH matchups AS (
    SELECT
        CASE
            WHEN home_team < away_team THEN home_team
            ELSE away_team
        END AS team_1,
        CASE
            WHEN home_team < away_team THEN away_team
            ELSE home_team
        END AS team_2,
        home_team,
        away_team,
        goal_home_ft,
        goal_away_ft
    FROM matches
),

matchup_counts AS (
    SELECT
        team_1,
        team_2,
        COUNT(*) AS total_matches
    FROM matchups
    GROUP BY team_1, team_2
),

top_20_matchups AS (
    SELECT
        team_1,
        team_2,
        total_matches
    FROM matchup_counts
    ORDER BY total_matches DESC
    LIMIT 20
)

SELECT
    m.team_1,
    m.team_2,
    COUNT(*) AS total_matches,

    SUM(
        CASE
            WHEN (m.home_team = m.team_1 AND m.goal_home_ft > m.goal_away_ft)
              OR (m.away_team = m.team_1 AND m.goal_away_ft > m.goal_home_ft)
            THEN 1
            ELSE 0
        END
    ) AS team_1_wins,

    SUM(
        CASE
            WHEN (m.home_team = m.team_2 AND m.goal_home_ft > m.goal_away_ft)
              OR (m.away_team = m.team_2 AND m.goal_away_ft > m.goal_home_ft)
            THEN 1
            ELSE 0
        END
    ) AS team_2_wins,

    SUM(
        CASE
            WHEN m.goal_home_ft = m.goal_away_ft THEN 1
            ELSE 0
        END
    ) AS draws

FROM matchups m
JOIN top_20_matchups t
    ON m.team_1 = t.team_1
   AND m.team_2 = t.team_2

GROUP BY
    m.team_1,
    m.team_2

ORDER BY
    total_matches DESC,
    m.team_1,
    m.team_2;	
	
-- =====================================================
-- SECTION 3: GOAL ANALYSIS FOR MATCHUPS
--
-- Description:
-- This section examines scoring patterns across all team
-- matchups. Team pairs are normalized so that
-- (A vs B) = (B vs A).
--
-- It includes:
--   3.1 Top 20 matchups by total goals scored
--   3.2 Top 20 matchups by average goals per match
--   3.3 Goal analysis for top 20 matchups
-- =====================================================


-- =====================================================
-- SECTION 3.1: TOP 20 MATCHUPS BY TOTAL GOALS
--
-- Description:
-- This query shows the top 20 team matchups with the
-- highest total number of goals scored across all their
-- meetings.
-- =====================================================

WITH matchups AS (
    SELECT
        CASE
            WHEN home_team < away_team THEN home_team
            ELSE away_team
        END AS team_1,
        CASE
            WHEN home_team < away_team THEN away_team
            ELSE home_team
        END AS team_2,
        goal_home_ft,
        goal_away_ft
    FROM matches
)

SELECT
    team_1,
    team_2,
    COUNT(*) AS matchup_count,
    SUM(goal_home_ft + goal_away_ft) AS total_goals,
    ROUND(AVG(goal_home_ft + goal_away_ft), 2) AS avg_goals
FROM matchups
GROUP BY team_1, team_2
ORDER BY total_goals DESC
LIMIT 20;


-- =====================================================
-- SECTION 3.2: TOP 20 MATCHUPS BY AVERAGE GOALS
--
-- Description:
-- This query shows the top 20 team matchups with the
-- highest average number of goals per match.
--
-- Only matchups with at least 5 matches are included,
-- so that the results are more meaningful.
-- =====================================================

WITH matchups AS (
    SELECT
        CASE
            WHEN home_team < away_team THEN home_team
            ELSE away_team
        END AS team_1,
        CASE
            WHEN home_team < away_team THEN away_team
            ELSE home_team
        END AS team_2,
        goal_home_ft,
        goal_away_ft
    FROM matches
)

SELECT
    team_1,
    team_2,
    COUNT(*) AS matchup_count,
    SUM(goal_home_ft + goal_away_ft) AS total_goals,
    ROUND(AVG(goal_home_ft + goal_away_ft), 2) AS avg_goals
FROM matchups
GROUP BY team_1, team_2
HAVING COUNT(*) >= 5
ORDER BY avg_goals DESC
LIMIT 20;

-- SECTION 3.3: GOAL ANALYSIS FOR TOP 20 MATCHUPS
--
-- Description:
-- This query focuses on the 20 most frequent matchups
-- and analyzes their scoring behavior:
--   - total matches (matchup_count)
--   - total goals scored
--   - average goals per match
--
-- Team pairs are normalized so that (A vs B) = (B vs A).
-- =====================================================

WITH matchups AS (
    SELECT
        CASE
            WHEN home_team < away_team THEN home_team
            ELSE away_team
        END AS team_1,
        CASE
            WHEN home_team < away_team THEN away_team
            ELSE home_team
        END AS team_2,
        goal_home_ft,
        goal_away_ft
    FROM matches
),

matchup_counts AS (
    SELECT
        team_1,
        team_2,
        COUNT(*) AS matchup_count
    FROM matchups
    GROUP BY team_1, team_2
),

top_20_matchups AS (
    SELECT
        team_1,
        team_2,
        matchup_count
    FROM matchup_counts
    ORDER BY matchup_count DESC
    LIMIT 20
)

SELECT
    m.team_1,
    m.team_2,
    COUNT(*) AS matchup_count,
    SUM(m.goal_home_ft + m.goal_away_ft) AS total_goals,
    ROUND(AVG(m.goal_home_ft + m.goal_away_ft), 2) AS avg_goals
FROM matchups m
JOIN top_20_matchups t
    ON m.team_1 = t.team_1
   AND m.team_2 = t.team_2
GROUP BY
    m.team_1,
    m.team_2
ORDER BY
    matchup_count DESC,
    total_goals DESC;

-- =====================================================
-- SECTION 4: GOAL DIFFERENCE ANALYSIS FOR MATCHUPS
--
-- Description:
-- This section examines how balanced or one-sided each
-- matchup is, based on goal difference.
-- Team pairs are normalized so that (A vs B) = (B vs A).
--
-- It includes:
--   4.1 Top 20 matchups by total goal difference
--   4.2 Top 20 matchups by average goal difference
--   4.3 Goal difference analysis for the top 20 most
--       frequent matchups
-- =====================================================


-- =====================================================
-- SECTION 4.1: TOP 20 MATCHUPS BY TOTAL GOAL DIFFERENCE
--
-- Description:
-- This query shows the top 20 team matchups with the
-- highest cumulative goal difference across all meetings.
-- A higher value suggests more one-sided scorelines over
-- time.
-- =====================================================

WITH matchups AS (
    SELECT
        CASE
            WHEN home_team < away_team THEN home_team
            ELSE away_team
        END AS team_1,
        CASE
            WHEN home_team < away_team THEN away_team
            ELSE home_team
        END AS team_2,
        goal_home_ft,
        goal_away_ft
    FROM matches
)

SELECT
    team_1,
    team_2,
    COUNT(*) AS matchup_count,
    SUM(ABS(goal_home_ft - goal_away_ft)) AS total_goal_diff,
    ROUND(AVG(ABS(goal_home_ft - goal_away_ft)), 2) AS avg_goal_diff
FROM matchups
GROUP BY team_1, team_2
ORDER BY total_goal_diff DESC
LIMIT 20;

-- =====================================================
-- SECTION 4.2: TOP 20 MATCHUPS BY AVERAGE GOAL DIFFERENCE
--
-- Description:
-- This query shows the top 20 team matchups with the
-- highest average goal difference per match.
--
-- Only matchups with at least 5 matches are included,
-- so that the results are more meaningful.
-- =====================================================

WITH matchups AS (
    SELECT
        CASE
            WHEN home_team < away_team THEN home_team
            ELSE away_team
        END AS team_1,
        CASE
            WHEN home_team < away_team THEN away_team
            ELSE home_team
        END AS team_2,
        goal_home_ft,
        goal_away_ft
    FROM matches
)

SELECT
    team_1,
    team_2,
    COUNT(*) AS matchup_count,
    SUM(ABS(goal_home_ft - goal_away_ft)) AS total_goal_diff,
    ROUND(AVG(ABS(goal_home_ft - goal_away_ft)), 2) AS avg_goal_diff
FROM matchups
GROUP BY team_1, team_2
HAVING COUNT(*) >= 5
ORDER BY avg_goal_diff DESC
LIMIT 20;

-- =====================================================
-- SECTION 4.3: GOAL DIFFERENCE ANALYSIS FOR TOP 20 MATCHUPS
--
-- Description:
-- This query focuses on the 20 most frequent matchups
-- and analyzes their goal difference behavior:
--   - total matches (matchup_count)
--   - total goal difference
--   - average goal difference per match
-- =====================================================

WITH matchups AS (
    SELECT
        CASE
            WHEN home_team < away_team THEN home_team
            ELSE away_team
        END AS team_1,
        CASE
            WHEN home_team < away_team THEN away_team
            ELSE home_team
        END AS team_2,
        goal_home_ft,
        goal_away_ft
    FROM matches
),

matchup_counts AS (
    SELECT
        team_1,
        team_2,
        COUNT(*) AS matchup_count
    FROM matchups
    GROUP BY team_1, team_2
),

top_20_matchups AS (
    SELECT
        team_1,
        team_2,
        matchup_count
    FROM matchup_counts
    ORDER BY matchup_count DESC
    LIMIT 20
)

SELECT
    m.team_1,
    m.team_2,
    COUNT(*) AS matchup_count,
    SUM(ABS(m.goal_home_ft - m.goal_away_ft)) AS total_goal_diff,
    ROUND(AVG(ABS(m.goal_home_ft - m.goal_away_ft)), 2) AS avg_goal_diff
FROM matchups m
JOIN top_20_matchups t
    ON m.team_1 = t.team_1
   AND m.team_2 = t.team_2
GROUP BY
    m.team_1,
    m.team_2
ORDER BY
    matchup_count DESC,
    total_goal_diff DESC;

