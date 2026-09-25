-- ============================================================
-- 03_create_analytics_view.sql
-- Emergency Department Triage Quality Improvement Analysis
-- Purpose: Create an analysis-ready SQL view for Power BI
-- ============================================================


CREATE SCHEMA IF NOT EXISTS analytics;


CREATE OR REPLACE VIEW analytics.triage_analysis AS

SELECT
    -- Original identifier
    group_id,

    -- Sex
    CASE
        WHEN TRIM(sex) = '1' THEN 'Female'
        WHEN TRIM(sex) = '2' THEN 'Male'
        ELSE 'Unknown'
    END AS sex,

    -- Age
    age::int AS age,

    CASE
        WHEN age::int BETWEEN 18 AND 29 THEN '18-29'
        WHEN age::int BETWEEN 30 AND 44 THEN '30-44'
        WHEN age::int BETWEEN 45 AND 59 THEN '45-59'
        WHEN age::int BETWEEN 60 AND 74 THEN '60-74'
        ELSE '75+'
    END AS age_group,

    -- Arrival mode
    CASE
        WHEN TRIM(arrival_mode) = '1' THEN 'Walking'
        WHEN TRIM(arrival_mode) = '2' THEN 'Public Ambulance'
        WHEN TRIM(arrival_mode) = '3' THEN 'Private Vehicle'
        WHEN TRIM(arrival_mode) = '4' THEN 'Private Ambulance'
        WHEN TRIM(arrival_mode) IN ('5', '6', '7') THEN 'Other'
        ELSE 'Unknown'
    END AS arrival_mode,

    injury,

    -- Standardized chief complaint
    CASE
        WHEN TRIM(LOWER(chief_complaint))
             IN ('abd. pain', 'abd pain', 'abdomen pain')
            THEN 'Abdominal pain'

        WHEN TRIM(LOWER(chief_complaint))
             IN ('left chest pain', 'pain, chest', 'ant. chest pain')
            THEN 'Chest pain'

        ELSE TRIM(chief_complaint)
    END AS chief_complaint,

    mental,
    pain,

    -- Numeric NRS pain score
    CASE
        WHEN TRIM(nrs_pain) ~ '^[0-9]+([.][0-9]+)?$'
            THEN nrs_pain::numeric
        ELSE NULL
    END AS nrs_pain,

    -- Pain severity
    CASE
        WHEN TRIM(nrs_pain) ~ '^[0-9]+([.][0-9]+)?$'
             AND nrs_pain::numeric BETWEEN 1 AND 3
            THEN 'Mild'

        WHEN TRIM(nrs_pain) ~ '^[0-9]+([.][0-9]+)?$'
             AND nrs_pain::numeric BETWEEN 4 AND 6
            THEN 'Moderate'

        WHEN TRIM(nrs_pain) ~ '^[0-9]+([.][0-9]+)?$'
             AND nrs_pain::numeric BETWEEN 7 AND 10
            THEN 'Severe'

        ELSE NULL
    END AS pain_severity,

    -- Clinical measurements
    sbp,
    dbp,
    hr,
    rr,
    bt,
    saturation,

    -- KTAS levels
    ktas_rn::int AS ktas_rn,
    ktas_expert::int AS ktas_expert,

    diagnosis_in_ed,
    disposition,

    -- Triage outcome
    CASE
        WHEN TRIM(mistriage) = '0' THEN 'Accurate'
        WHEN TRIM(mistriage) = '1' THEN 'Over-triage'
        WHEN TRIM(mistriage) = '2' THEN 'Under-triage'
        ELSE 'Unknown'
    END AS triage_status,

    -- Binary flag for Power BI measures
    CASE
        WHEN TRIM(mistriage) = '0' THEN 0
        WHEN TRIM(mistriage) IN ('1', '2') THEN 1
        ELSE NULL
    END AS mistriage_flag,

    error_group,
    length_of_stay_min,
    ktas_duration_min

FROM raw.triage_raw;


-- ============================================================
-- Validation
-- ============================================================

SELECT COUNT(*) AS total_records
FROM analytics.triage_analysis;


SELECT *
FROM analytics.triage_analysis
LIMIT 10;
