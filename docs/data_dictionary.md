# Data Dictionary

This document describes the main fields used in the Emergency Department Triage Quality Improvement Analysis.

The original dataset was imported into PostgreSQL as `raw.triage_raw`.  
An analysis-ready view, `analytics.triage_analysis`, was then created for Power BI reporting.

---

## Analysis-Ready Fields

| Field | Description |
|---|---|
| `group_id` | Source patient/group identifier from the dataset |
| `sex` | Patient sex, converted from source codes to Female or Male |
| `age` | Patient age in years |
| `age_group` | Age category: 18–29, 30–44, 45–59, 60–74, or 75+ |
| `arrival_mode` | Mode of arrival to the emergency department |
| `injury` | Indicates whether the patient presented with an injury |
| `chief_complaint` | Primary reason for the ED visit; selected labels were standardized before analysis |
| `mental` | Mental-status indicator from the source dataset |
| `pain` | Indicates whether pain was present |
| `nrs_pain` | Numeric Rating Scale pain score |
| `pain_severity` | Pain category derived from NRS: Mild, Moderate, or Severe |
| `sbp` | Systolic blood pressure |
| `dbp` | Diastolic blood pressure |
| `hr` | Heart rate |
| `rr` | Respiratory rate |
| `bt` | Body temperature |
| `saturation` | Oxygen saturation |
| `ktas_rn` | KTAS level assigned by the triage nurse |
| `ktas_expert` | KTAS level assigned through expert assessment |
| `diagnosis_in_ed` | Diagnosis recorded in the emergency department |
| `disposition` | Patient disposition after ED assessment |
| `triage_status` | Final classification: Accurate, Over-triage, or Under-triage |
| `mistriage_flag` | Binary analytical flag: 0 = accurate, 1 = mistriage |
| `error_group` | Source-coded category describing the type/cause of triage error |
| `length_of_stay_min` | Emergency department length of stay in minutes |
| `ktas_duration_min` | Duration related to KTAS assessment/process in minutes |

---

## Derived Variables

### Age Group

```text
18–29
30–44
45–59
60–74
75+
