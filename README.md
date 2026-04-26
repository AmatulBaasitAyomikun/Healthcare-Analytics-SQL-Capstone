# 🏥 Healthcare Patient Outcomes Analytics System

A SQL-based analytics project exploring patient admissions, chronic illness, lifestyle factors, and doctor performance at Faith Specialist Hospital — built as a capstone project for my Healthcare Analytics class at **Zion Tech Hub**.

---

## 📌 Project Overview

This project involved designing and querying a relational PostgreSQL database built from real hospital data. The goal was to uncover meaningful clinical and operational insights across 6 analytical objectives — from patient demographics to doctor performance — using only SQL.

| Metric | Value |
|---|---|
| Total Admissions | 1,478 |
| Doctors | 39 |
| Chronic Conditions Analyzed | 5 |
| Analytical Objectives | 6 |
| Tool Used | PostgreSQL (pgAdmin) |

---

## 🗂️ Database Structure

The database consists of 4 relational tables:

```
patients          — Demographics: age, sex, occupation, marital status
doctors           — Doctor profiles and specializations
admission_details — Clinical outcomes per admission (DAMA, mortality, chronic illness)
risk_factors      — Lifestyle history: alcohol, tobacco, NSAID use
```

**Entity Relationships:**
- `patients` → `admission_details` (via `pt_id`)
- `doctors` → `admission_details` (via `doctor_id`)
- `patients` → `risk_factors` (via `pt_id`)

---

## ⚠️ Data Quality Findings

Real-world data is messy — and this project was no exception. Before any analysis, a data quality audit was conducted across all four tables.

| Issue | Detail | Action Taken |
|---|---|---|
| Orphaned Record | 1 admission (pt_id 105) had no matching patient record | Foreign key constraint dropped; record retained but excluded from demographic analysis |
| Patient ID Mismatch | `risk_factors` and `admission_details` pt_id ranges did not fully align | Lifestyle analysis limited to 961 matched records (65% of total) |
| Missing Education Data | 936 of 1,478 patients (63%) had no education level recorded | Education excluded from demographic analysis |
| Erroneous Sex Entry | 1 patient record had numeric value '84' in the sex column | Treated as unknown sex |
| Small Age Groups | Only 2 adolescent patients and 5 with unknown age | Excluded from mortality rate conclusions |

> These findings are documented transparently and referenced where relevant throughout the analysis.

---

## 🎯 Analytical Objectives & Key Findings

### Objective 1 — Patient Demographics

- The hospital predominantly serves **middle-aged (36.2%) and senior (32.3%) patients**, pointing to a need for age-focused care strategies.
- **Elderly patients (71+) had the highest mortality rate at 26.2%**, while males and females had virtually identical rates (22.1% vs 22.0%) — suggesting sex alone is not a mortality predictor.
- Female patients had higher stroke prevalence (24.9% vs 23.0%), while males had higher CKD rates (23.4% vs 21.6%).

---

### Objective 2 — DAMA Analysis (Discharge Against Medical Advice)

- **277 patients (18.7%) left against medical advice** — a significant patient retention challenge.
- **Financial constraint was the #1 reason**, accounting for 224 DAMA cases — a clinical problem with a non-clinical solution.
- Middle-aged patients had the highest DAMA count (65), likely due to work and family obligations competing with treatment compliance.
- Emergency Medicine recorded the highest DAMA count by specialization (82), consistent with the nature of acute admissions.

---

### Objective 3 — Chronic Illness Analysis

- **Stroke (23.5%) and CKD (21.9%)** were the most prevalent chronic conditions, each affecting over 1 in 5 patients.
- **Cancer had the highest mortality rate at 53.1%** (17 deaths out of 32 patients), despite being the least prevalent condition.
- Diabetes was the leading cause of CKD (121 cases), reinforcing their well-documented clinical relationship.
- Of 324 CKD patients, only 19 (5.9%) required dialysis, averaging 4.1 sessions per patient.

| Condition | Total Patients | Deaths | Mortality Rate |
|---|---|---|---|
| Cancer | 32 | 17 | 53.1% |
| Diabetes Mellitus | 166 | 51 | 30.7% |
| CKD | 324 | 74 | 22.8% |
| Stroke | 347 | 76 | 21.9% |
| Peptic Ulcer Disease | 168 | 20 | 11.9% |

---

### Objective 4 — Lifestyle Factors & Outcomes

> ⚠️ Due to the patient ID mismatch, this analysis is based on **961 matched records** (65% of admissions).

- **NSAID users had a noticeably higher PUD prevalence (13.8% vs 9.5%)**, consistent with clinical literature on gastric mucosal damage.
- Neither alcohol nor tobacco history showed a strong independent association with mortality — suggesting chronic illness severity and age are stronger predictors.

---

### Objective 5 — Doctor Performance

- Patient workload was **unevenly distributed**, with the top doctor handling 210 admissions vs others handling fewer than 90.
- High-volume doctors were concentrated in **Emergency Medicine, Cardiology, and Nephrology**.
- **Dr Mahmoud (General Surgery) had the highest mortality rate at 80.0%** — but based on only 15 patients, limiting reliability. Context matters before drawing conclusions.
- **Orthopedics had the longest average admission duration** (15.6 days), followed by Cardiology (14.7 days) and Dermatology (13.9 days).

---

## 🛠️ SQL Skills Demonstrated

| Skill | Used For |
|---|---|
| `CREATE TABLE` + `ALTER TABLE` | Database schema design and modification |
| `COPY` | Bulk data loading from CSV files |
| `INNER JOIN` / `LEFT JOIN` | Multi-table queries |
| `CASE WHEN` | Age group bucketing |
| `CTEs (WITH)` | Reusing calculated columns across queries |
| `Window Functions` | `COUNT() OVER (PARTITION BY...)` for doctor performance |
| `FILTER (WHERE...)` | Conditional aggregation |
| `UNION ALL` | Stacking chronic illness results into one output |
| `COALESCE` | Handling NULL values cleanly |
| `NULLIF` | Preventing division by zero errors |
| `ROUND` + `CAST` | Formatting percentages |
| `AVG`, `COUNT`, `SUM` | Core aggregations throughout |

---

## 📁 Repository Structure

```
📂 healthcare-analytics
├── 📄 README.md
├── 📂 queries/
│   ├── 01_create_tables.sql
│   ├── 02_objective1_demographics.sql
│   ├── 03_objective2_dama.sql
│   ├── 04_objective3_chronic_illness.sql
│   ├── 05_objective4_lifestyle_factors.sql
│   └── 06_objective5_doctor_performance.sql
├── 📂 data/
│   ├── patient_details.csv
│   ├── admission_details.csv
│   ├── doctors.csv
│   └── risk_factors.csv
└── 📄 written_insights.docx
```

---

## 🚀 How to Run This Project

1. Install [PostgreSQL](https://www.postgresql.org/download/) and [pgAdmin](https://www.pgadmin.org/)
2. Create a new database in pgAdmin
3. Run `01_create_tables.sql` to set up the schema
4. Use pgAdmin's import tool to load each CSV into the corresponding table
5. Run each query file in order to reproduce the analysis

---

## 💡 Key Takeaways

This project taught me that data analytics in healthcare is as much about **asking the right questions** as it is about writing the right queries. A few things that stood out:

- Real data is messy — document everything
- Always verify row counts after imports
- Numbers without context can mislead (a doctor's high mortality rate may reflect case complexity, not poor care)
- Correlation is not causation — tobacco and alcohol history didn't predict mortality, but that's a finding worth reporting too

---

## 👤 Author
AmatulBaasit Ghazal

LinkedIn: https://www.linkedin.com/in/amatulbaasitghazal

Built as a capstone project for the **Healthcare Analytics class at Zion Tech Hub**

---

*Feel free to fork this repo, explore the queries, or reach out if you have questions!*
