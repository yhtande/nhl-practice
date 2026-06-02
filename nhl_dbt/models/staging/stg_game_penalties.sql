SELECT
    play_id                                         AS play_id,
    CAST(penaltySeverity AS VARCHAR)                AS penalty_severity,
    CAST(penaltyMinutes AS integer)                 AS penalty_minutes
FROM {{ source('raw', 'game_penalties') }}