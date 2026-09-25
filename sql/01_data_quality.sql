-- ============================================================
-- 01_data_quality.sql
-- Emergency Department Triage Quality Improvement Analysis
-- Purpose: Perform practical data quality checks before analysis
-- ============================================================


-- 1. Confirm total number of imported records
SELECT
    COUNT(*) AS total_records
FROM raw.triage_raw;


-- 2. Check missing values in key analytical fields
SELECT
    COUNT(*) AS total_records,

    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(age), '') IS NULL
    ) AS missing_age,

    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(nrs_pain), '') IS NULL
    ) AS missing_nrs_pain,

    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(rr), '') IS NULL
    ) AS missing_rr,

    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(saturation), '') IS NULL
    ) AS missing_saturation,

    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(diagnosis_in_ed), '') IS NULL
    ) AS missing_diagnosis,

    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(ktas_rn), '') IS NULL
    ) AS missing_ktas_rn,

    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(ktas_expert), '') IS NULL
    ) AS missing_ktas_expert

FROM raw.triage_raw;


-- 3. Check for exact duplicate records
SELECT
    COUNT(*) AS total_rows,

    COUNT(
        DISTINCT ROW(
            group_id,
            sex,
            age,
            patients_per_hour,
            arrival_mode,
            injury,
            chief_complaint,
            mental,
            pain,
            nrs_pain,
            sbp,
            dbp,
            hr,
            rr,
            bt,
            saturation,
            ktas_rn,
            diagnosis_in_ed,
            disposition,
            ktas_expert,
            error_group,
            length_of_stay_min,
            ktas_duration_min,
            mistriage
        )
    ) AS unique_rows

FROM raw.triage_raw;


-- 4. Identify unexpected non-numeric values in Age
-- This check was also used to detect an accidentally imported CSV header row.
SELECT
    ctid,
    *
FROM raw.triage_raw
WHERE TRIM(age) !~ '^[0-9]+$';


-- 5. Remove accidental CSV header row if present
DELETE FROM raw.triage_raw
WHERE TRIM(sex) = 'Sex'
  AND TRIM(age) = 'Age';


-- 6. Final record-count validation
SELECT
    COUNT(*) AS final_record_count
FROM raw.triage_raw;
