# Diabetes Hospital encounters (US, 1999–2008)

Fairness Data (datasets from Fairlearn) · CIS-3901 Challenge Project: Tidy Data

## 1. Purpose

Use this dataset to investigate which hospital patients with diabetes are readmitted, how readmission relates to the hospital stay, lab tests and medications, and whether it differs by race, gender or age. In the tidy table, **each row is one hospital encounter** (one stay).

## 2. Source and context

- **Source:** Clore, J., Cios, K., DeShazo, J., & Strack, B. (2014). *Diabetes 130-US Hospitals for Years 1999-2008* [Dataset]. UCI Machine Learning Repository. https://doi.org/10.24432/C5230J. This version was prepared by the Fairlearn team for the SciPy 2021 tutorial *Fairness in AI Systems* and accessed through Fairlearn (`fetch_diabetes_hospital`).
- **License:** CC BY 4.0. You may share and adapt the data if you **credit the source above** in your report and slides.
- **Collection:** 10 years of hospital records (1999–2008) from 130 US hospitals and networks: patients diagnosed with diabetes, with stays of 1 to 14 days. The Fairlearn version groups some categories (age bands, diagnosis groups) and has no patient identifier, so one patient may have several encounters.
- **This sample:** 5,000 of the 101,766 encounters, drawn at random within groups defined by readmission (no, within 30 days, after 30 days) × race × gender (stratified, proportional, seed 3901). The groups keep the same shares as in the full data. `encounter_id` was assigned by us in random order.
- **Dated or unfamiliar terms:** labels are as recorded in the source (e.g. `AfricanAmerican`; gender `Unknown/Invalid`). The A1C test measures average blood sugar over the past few months; `max_glu_serum` is a blood glucose test. In both, `None` means **the test was not done** (a text level, not a missing value).

## 3. Files

Read each file with `read_csv()` from its raw URL (works once the course repository is public):

| File | What it holds |
|---|---|
| `encounters_part_1.csv`, `encounters_part_2.csv` | Encounters, in two parts: patient profile, length of stay, procedures, diagnoses, insurance, prior visits, readmission, and number of medications by insulin status |
| `lab_results_long.csv` | The two lab test results for each encounter |

```r
url <- "https://raw.githubusercontent.com/acintron-cc/cis-3901-202710/main/data/fairness/diabetes_hospital/"
# e.g. read_csv(paste0(url, "lab_results_long.csv"))
```

Or, in your copy of the course template: `read_csv("data/fairness/diabetes_hospital/lab_results_long.csv")`.

**Problems in this package** (Wickham 2014). Somewhere in these files you will find:
- column headers that are values, not variable names;
- several variables stored in one column;
- variables stored in rows instead of columns;
- one observational unit (encounters) spread across several files.

It is your job to diagnose which file has which problem. Your guide is the revised **Tidying Operations answer key**: every fix you need appears there.

**Hint:** the `insulin_` columns work like the `wk` columns of `billboard`: use `names_prefix`.

**Difficulty:** Standard.

## 4. Task

Produce one tidy table, `encounters`, with exactly these 22 columns in this order (types as `read_csv()` shows them):

`encounter_id` <dbl>, `race` <chr>, `gender` <chr>, `age` <chr>, `time_in_hospital` <dbl>, `num_lab_procedures` <dbl>, `num_procedures` <dbl>, `num_medications` <dbl>, `number_diagnoses` <dbl>, `primary_diagnosis` <chr>, `max_glu_serum` <chr>, `A1Cresult` <chr>, `insulin` <chr>, `change` <chr>, `diabetesMed` <chr>, `medicare` <lgl>, `medicaid` <lgl>, `had_emergency` <lgl>, `had_inpatient_days` <lgl>, `had_outpatient_days` <lgl>, `readmitted` <chr>, `readmit_30_days` <dbl>

## 5. Codebook

| Column | Meaning | Type, units, codes |
|---|---|---|
| `encounter_id` | ID of the encounter (assigned by us) | 1 to 5000 |
| `race` | Race, as recorded | `Caucasian`, `AfricanAmerican`, `Hispanic`, `Asian`, `Other`, `Unknown` |
| `gender` | Gender, as recorded | `Female`, `Male`, `Unknown/Invalid` |
| `age` | Age group | `30 years or younger`, `30-60 years`, `Over 60 years` |
| `time_in_hospital` | Length of stay | days (1 to 14) |
| `num_lab_procedures` | Lab tests during the stay | count |
| `num_procedures` | Procedures other than lab tests | count |
| `num_medications` | Distinct medications given during the stay | count |
| `number_diagnoses` | Diagnoses entered | count |
| `primary_diagnosis` | Main diagnosis group | `Diabetes`, `Respiratory Issues`, `Genitourinary Issues`, `Musculoskeletal Issues`, `Other` |
| `max_glu_serum` | Glucose serum test result | `>300`, `>200`, `Norm`, `None` (not done) |
| `A1Cresult` | A1C test result | `>8`, `>7`, `Norm`, `None` (not done) |
| `insulin` | Insulin during the stay | `No`, `Steady`, `Up` (dose increased), `Down` (dose decreased) |
| `change` | Diabetes medications changed? | `Ch` (changed), `No` |
| `diabetesMed` | Diabetes medication prescribed? | `Yes`, `No` |
| `medicare` | Insured by Medicare? | `TRUE`, `FALSE` |
| `medicaid` | Insured by Medicaid? | `TRUE`, `FALSE` |
| `had_emergency` | Any emergency visit in the year before? | `TRUE`, `FALSE` |
| `had_inpatient_days` | Any inpatient stay in the year before? | `TRUE`, `FALSE` |
| `had_outpatient_days` | Any outpatient visit in the year before? | `TRUE`, `FALSE` |
| `readmitted` | Readmitted after this stay (the outcome) | `NO`, `<30` (within 30 days), `>30` (after 30 days) |
| `readmit_30_days` | Readmitted within 30 days | 1 = yes (`<30`), 0 = no |

No column has missing values.

## 6. Imbalance at a glance (this sample)

- **readmitted:** NO 53.9% (2,695); >30 34.9% (1,747); <30 11.2% (558)
- **race:** Caucasian 74.7% (3,737); AfricanAmerican 18.9% (944); Unknown 2.3% (113); Hispanic 2.0% (100); Other 1.5% (75); Asian 0.6% (31)
- **gender:** Female 53.7% (2,685); Male 46.3% (2,313); Unknown/Invalid 0.04% (2)
- **age:** Over 60 years 67.0% (3,348); 30-60 years 30.2% (1,511); 30 years or younger 2.8% (141)

These shares mirror the full dataset **on purpose**: the sample was not balanced, so the groups are as unequal as in the original data.

## 7. Limitations

Groups with **fewer than 30 encounters** in this sample:
- **gender:** `Unknown/Invalid` (2). Kept so that no group in the full data disappears; do not analyze it on its own.

`Asian` (31) is just above 30. A group with fewer than 30 rows should not be compared on its own without saying so in your report; combine groups or state the small count. Because one patient can have several encounters, rows are not fully independent people.

Differences between groups in this data describe this sample at this time and place; they do not show that a group membership causes an outcome.

## 8. Checks to run yourself

```r
stopifnot(
  nrow(encounters) == 5000,                                # one row per encounter
  n_distinct(encounters$encounter_id) == nrow(encounters), # every ID appears exactly once
  ncol(encounters) == 22
)
```
