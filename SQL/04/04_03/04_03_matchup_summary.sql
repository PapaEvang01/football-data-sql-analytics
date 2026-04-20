-- =====================================================
-- 04_03_matchup_summary.sql
-- Final matchup performance summary table
-- =====================================================

-- This query creates a complete summary table for
-- normalized team matchups. Each row represents one
-- pair of teams, regardless of home or away order.

SELECT
    team_1,
    team_2,

    COUNT(*) AS total_matches,

    -- Match result rates
    ROUND(
        100.0 * SUM(
            CASE
                WHEN (home_team = team_1 AND goal_home_ft > goal_away_ft)
                  OR (away_team = team_1 AND goal_away_ft > goal_home_ft)
                THEN 1 ELSE 0
            END
        ) / COUNT(*),
    2) AS team_1_win_rate_pct,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN (home_team = team_2 AND goal_home_ft > goal_away_ft)
                  OR (away_team = team_2 AND goal_away_ft > goal_home_ft)
                THEN 1 ELSE 0
            END
        ) / COUNT(*),
    2) AS team_2_win_rate_pct,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN goal_home_ft = goal_away_ft THEN 1 ELSE 0
            END
        ) / COUNT(*),
    2) AS draw_rate_pct,

    -- Goal metrics
    ROUND(AVG(goal_home_ft + goal_away_ft), 2) AS avg_goals,
    ROUND(AVG(ABS(goal_home_ft - goal_away_ft)), 2) AS avg_goal_difference,

    -- Discipline metrics
    ROUND(AVG(home_yellow_cards + away_yellow_cards), 2) AS avg_yellow_cards,
    ROUND(AVG(home_red_cards + away_red_cards), 2) AS avg_red_cards,

    -- Match activity metrics
    ROUND(AVG(home_offsides + away_offsides), 2) AS avg_offsides,
    ROUND(AVG(home_corners + away_corners), 2) AS avg_corners,
    ROUND(AVG(home_fouls_conceded + away_fouls_conceded), 2) AS avg_fouls,
    ROUND(AVG(home_shots + away_shots), 2) AS avg_shots

FROM (
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
        goal_away_ft,
        home_yellow_cards,
        away_yellow_cards,
        home_red_cards,
        away_red_cards,
        home_offsides,
        away_offsides,
        home_corners,
        away_corners,
        home_fouls_conceded,
        away_fouls_conceded,
        home_shots,
        away_shots
    FROM matches
) AS matchup_data

GROUP BY
    team_1,
    team_2

-- Keep only matchups with enough history
HAVING COUNT(*) >= 10

-- Sort by most frequent matchups first
ORDER BY total_matches DESC, team_1, team_2;