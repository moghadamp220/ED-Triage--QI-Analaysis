-- ============================================================
-- 02_exploratory_analysis.sql
-- Emergency Department Triage Quality Improvement Analysis
-- Purpose: Explore mistriage patterns and identify QI priorities
-- ============================================================


-- ============================================================
-- 1. BASELINE TRIAGE OUTCOMES
-- ============================================================

SELECT
    CASE
        WHEN mistriage = '0' THEN 'Accurate'
        WHEN mistriage = '1' THEN 'Over-triage'
        WHEN mistriage = '2' THEN 'Under-triage'
    END AS triage_status,

    COUNT(*) AS cases,

    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage

FROM raw.triage_raw
GROUP BY mistriage
ORDER BY cases DESC;


-- ============================================================
-- 2. MISTRIAGE RATE BY KTAS LEVEL
-- ============================================================

SELECT
    ktas_rn,
    COUNT(*) AS total_cases,

    COUNT(*) FILTER (
        WHERE mistriage <> '0'
    ) AS mistriage_cases,

    ROUND(
        COUNT(*) FILTER (WHERE mistriage <> '0') * 100.0
        / COUNT(*),
        2
    ) AS mistriage_rate

FROM raw.triage_raw
GROUP BY ktas_rn
ORDER BY ktas_rn;


-- ============================================================
-- 3. UNDER-TRIAGE VS OVER-TRIAGE BY KTAS LEVEL
-- ============================================================

SELECT
    ktas_rn,

    COUNT(*) FILTER (
        WHERE mistriage = '2'
    ) AS under_triage,

    COUNT(*) FILTER (
        WHERE mistriage = '1'
    ) AS over_triage,

    COUNT(*) AS total_cases

FROM raw.triage_raw
GROUP BY ktas_rn
ORDER BY ktas_rn;


-- ============================================================
-- 4. ERROR GROUP FREQUENCY
-- ============================================================

SELECT
    error_group,
    COUNT(*) AS cases

FROM raw.triage_raw

GROUP BY error_group
ORDER BY cases DESC;


-- ============================================================
-- 5. PARETO ANALYSIS OF MISTRIAGE ERROR GROUPS
-- ============================================================

WITH errors AS (

    SELECT
        error_group,
        COUNT(*) AS error_cases

    FROM raw.triage_raw

    WHERE mistriage <> '0'

    GROUP BY error_group
)

SELECT
    error_group,
    error_cases,

    ROUND(
        error_cases * 100.0
        / SUM(error_cases) OVER (),
        2
    ) AS error_percent,

    ROUND(
        SUM(error_cases) OVER (
            ORDER BY error_cases DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) * 100.0
        / SUM(error_cases) OVER (),
        2
    ) AS cumulative_percent

FROM errors
ORDER BY error_cases DESC;


-- ============================================================
-- 6. PAIN PRESENCE AND MISTRIAGE
-- ============================================================

SELECT
    pain,
    COUNT(*) AS total_cases,

    COUNT(*) FILTER (
        WHERE mistriage <> '0'
    ) AS mistriage_cases,

    ROUND(
        COUNT(*) FILTER (WHERE mistriage <> '0') * 100.0
        / COUNT(*),
        2
    ) AS mistriage_rate

FROM raw.triage_raw
GROUP BY pain
ORDER BY pain;


-- ============================================================
-- 7. PAIN SEVERITY AND MISTRIAGE
-- ============================================================

WITH pain_groups AS (

    SELECT
        CASE
            WHEN nrs_pain::numeric BETWEEN 1 AND 3 THEN 'Mild'
            WHEN nrs_pain::numeric BETWEEN 4 AND 6 THEN 'Moderate'
            WHEN nrs_pain::numeric BETWEEN 7 AND 10 THEN 'Severe'
        END AS pain_severity,

        mistriage

    FROM raw.triage_raw

    WHERE TRIM(nrs_pain) ~ '^[0-9]+([.][0-9]+)?$'
)

SELECT
    pain_severity,
    COUNT(*) AS total_cases,

    COUNT(*) FILTER (
        WHERE mistriage <> '0'
    ) AS mistriage_cases,

    ROUND(
        COUNT(*) FILTER (WHERE mistriage <> '0') * 100.0
        / COUNT(*),
        2
    ) AS mistriage_rate

FROM pain_groups

GROUP BY pain_severity

ORDER BY
    CASE
        WHEN pain_severity = 'Mild' THEN 1
        WHEN pain_severity = 'Moderate' THEN 2
        WHEN pain_severity = 'Severe' THEN 3
    END;


-- ============================================================
-- 8. UNDER-TRIAGE VS OVER-TRIAGE BY PAIN SEVERITY
-- ============================================================

WITH pain_groups AS (

    SELECT
        CASE
            WHEN nrs_pain::numeric BETWEEN 1 AND 3 THEN 'Mild'
            WHEN nrs_pain::numeric BETWEEN 4 AND 6 THEN 'Moderate'
            WHEN nrs_pain::numeric BETWEEN 7 AND 10 THEN 'Severe'
        END AS pain_severity,

        mistriage

    FROM raw.triage_raw

    WHERE TRIM(nrs_pain) ~ '^[0-9]+([.][0-9]+)?$'
)

SELECT
    pain_severity,
    COUNT(*) AS total_cases,

    COUNT(*) FILTER (
        WHERE mistriage = '2'
    ) AS under_triage,

    COUNT(*) FILTER (
        WHERE mistriage = '1'
    ) AS over_triage,

    ROUND(
        COUNT(*) FILTER (WHERE mistriage = '2') * 100.0
        / COUNT(*),
        2
    ) AS under_triage_rate,

    ROUND(
        COUNT(*) FILTER (WHERE mistriage = '1') * 100.0
        / COUNT(*),
        2
    ) AS over_triage_rate

FROM pain_groups

GROUP BY pain_severity

ORDER BY
    CASE
        WHEN pain_severity = 'Mild' THEN 1
        WHEN pain_severity = 'Moderate' THEN 2
        WHEN pain_severity = 'Severe' THEN 3
    END;


-- ============================================================
-- 9. MISTRIAGE RATE BY ARRIVAL MODE
-- ============================================================

SELECT
    arrival_mode,
    COUNT(*) AS total_cases,

    COUNT(*) FILTER (
        WHERE mistriage <> '0'
    ) AS mistriage_cases,

    ROUND(
        COUNT(*) FILTER (WHERE mistriage <> '0') * 100.0
        / COUNT(*),
        2
    ) AS mistriage_rate

FROM raw.triage_raw

GROUP BY arrival_mode
ORDER BY mistriage_rate DESC;


-- ============================================================
-- 10. MISTRIAGE RATE BY AGE GROUP
-- ============================================================

WITH age_groups AS (

    SELECT
        CASE
            WHEN age::int BETWEEN 18 AND 29 THEN '18-29'
            WHEN age::int BETWEEN 30 AND 44 THEN '30-44'
            WHEN age::int BETWEEN 45 AND 59 THEN '45-59'
            WHEN age::int BETWEEN 60 AND 74 THEN '60-74'
            ELSE '75+'
        END AS age_group,

        mistriage

    FROM raw.triage_raw

    WHERE TRIM(age) ~ '^[0-9]+$'
)

SELECT
    age_group,
    COUNT(*) AS total_cases,

    COUNT(*) FILTER (
        WHERE mistriage <> '0'
    ) AS mistriage_cases,

    ROUND(
        COUNT(*) FILTER (WHERE mistriage <> '0') * 100.0
        / COUNT(*),
        2
    ) AS mistriage_rate

FROM age_groups

GROUP BY age_group

ORDER BY
    CASE
        WHEN age_group = '18-29' THEN 1
        WHEN age_group = '30-44' THEN 2
        WHEN age_group = '45-59' THEN 3
        WHEN age_group = '60-74' THEN 4
        WHEN age_group = '75+' THEN 5
    END;


-- ============================================================
-- 11. STANDARDIZE CHIEF COMPLAINT LABELS
--     AND CALCULATE MISTRIAGE RATE
-- ============================================================

WITH standardized_complaints AS (

    SELECT
        CASE
            WHEN TRIM(LOWER(chief_complaint))
                 IN ('abd. pain', 'abd pain', 'abdomen pain')
                THEN 'Abdominal pain'

            WHEN TRIM(LOWER(chief_complaint))
                 IN ('left chest pain', 'pain, chest', 'ant. chest pain')
                THEN 'Chest pain'

            ELSE TRIM(chief_complaint)

        END AS complaint_group,

        mistriage

    FROM raw.triage_raw
)

SELECT
    complaint_group,
    COUNT(*) AS total_cases,

    COUNT(*) FILTER (
        WHERE mistriage <> '0'
    ) AS mistriage_cases,

    ROUND(
        COUNT(*) FILTER (WHERE mistriage <> '0') * 100.0
        / COUNT(*),
        2
    ) AS mistriage_rate

FROM standardized_complaints

GROUP BY complaint_group

HAVING COUNT(*) >= 10

ORDER BY mistriage_rate DESC;


-- ============================================================
-- 12. MISTRIAGE RATE BY SEX
-- ============================================================

SELECT
    sex,
    COUNT(*) AS total_cases,

    COUNT(*) FILTER (
        WHERE mistriage <> '0'
    ) AS mistriage_cases,

    ROUND(
        COUNT(*) FILTER (WHERE mistriage <> '0') * 100.0
        / COUNT(*),
        2
    ) AS mistriage_rate

FROM raw.triage_raw

GROUP BY sex
ORDER BY mistriage_rate DESC;
