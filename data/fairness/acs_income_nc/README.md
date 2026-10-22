# ACS Income, North Carolina (2018)

Fairness Data (datasets from Fairlearn) · CIS-3901 Challenge Project: Tidy Data

## 1. Purpose

Use this dataset to investigate how income of working adults in North Carolina relates to age, education, type of employer and hours worked, and whether that relationship differs by sex or race. In the tidy table, **each row is one person**.

## 2. Source and context

- **Source:** US Census Bureau, 2018 American Community Survey (ACS) Public Use Microdata Sample (PUMS), as prepared in the ACSIncome dataset by Ding, F., Hardt, M., Miller, J., & Schmidt, L. (2021), *Retiring Adult: New Datasets for Fair Machine Learning* (folktables). Accessed through Fairlearn (`fetch_acs_income`, North Carolina only).
- **License:** ACS PUMS are public data from the US Census Bureau. **Credit the source above** in your report and slides.
- **Collection:** the ACS is a yearly survey of US households. These records are North Carolina residents in 2018. Everyone in the data is 17 or older, usually worked at least 1 hour a week and had income above $100.
- **This sample:** 5,000 of the 52,067 North Carolina people, drawn at random within groups defined by income above $50,000 × sex × race (stratified, proportional, seed 3901). The groups keep the same shares as in the full North Carolina data. `person_id` was assigned by us in random order.
- **Dated or unfamiliar terms:** labels are the **official wording of the 2018 PUMS data dictionary**. In race labels, "alone" means the person reported only one race. `Never married or under 15 years old` is one Census category (no one here is under 17). Incomes are 2018 dollars, not adjusted for inflation.

## 3. Files

Read each file with `read_csv()` from its raw URL (works once the course repository is public):

| File | What it holds |
|---|---|
| `pums_nc_part_a.csv`, `pums_nc_part_b.csv` | People, in two parts: age and sex code, race code, class of worker, education, and hours worked per week |
| `sex_codes.csv` | What each sex code means |
| `race_codes.csv` | What each race code means |
| `work_long.csv` | Income and three numeric codes (occupation, birthplace, relationship) for each person |

```r
url <- "https://raw.githubusercontent.com/acintron-cc/cis-3901-202710/main/data/fairness/acs_income_nc/"
# e.g. read_csv(paste0(url, "sex_codes.csv"))
```

Or, in your copy of the course template: `read_csv("data/fairness/acs_income_nc/sex_codes.csv")`.

**Problems in this package** (Wickham 2014). Somewhere in these files you will find:
- column headers that are values, not variable names (some have spaces: use backticks, as in `relig_income`);
- several variables stored in one column;
- variables stored in rows instead of columns;
- one observational unit (people) spread across several files, with codes explained in separate tables.

It is your job to diagnose which file has which problem. Your guide is the revised **Tidying Operations answer key**: every fix you need appears there.

**Hint:** the marital-status columns (`Married` … `Never married or under 15 years old`) are values, like the income brackets in `relig_income`.

**Difficulty:** Standard.

## 4. Task

Produce one tidy table, `acs`, with exactly these 12 columns in this order (types as `read_csv()` shows them):

`person_id` <dbl>, `age` <dbl>, `sex` <chr>, `race` <chr>, `marital_status` <chr>, `class_of_worker` <chr>, `education` <chr>, `occupation_code` <dbl>, `birthplace_code` <dbl>, `relationship_code` <dbl>, `hours_per_week` <dbl>, `income` <dbl>

## 5. Codebook

| Column | Meaning | Type, units, codes |
|---|---|---|
| `person_id` | ID of the person (assigned by us) | 1 to 5000 |
| `age` | Age | years (17 to 94) |
| `sex` | Sex | `Male`, `Female` |
| `race` | Race | 9 official labels, e.g. `White alone`, `Black or African American alone`, `Two or More Races` |
| `marital_status` | Marital status | `Married`, `Widowed`, `Divorced`, `Separated`, `Never married or under 15 years old` |
| `class_of_worker` | Type of employer | 8 official labels, e.g. `State government employee` |
| `education` | Educational attainment | 24 official labels, from `No schooling completed` to `Doctorate degree` |
| `occupation_code` | Occupation | numeric code (2018 Census occupation codes) |
| `birthplace_code` | Place of birth | numeric code: 1 to 56 are US states and DC (37 = North Carolina); 60 to 78 are US territories (72 = Puerto Rico); 100 and above are other countries (e.g. 303 = Mexico) |
| `relationship_code` | Relationship to the householder | numeric code: 0 = reference person, 1 = husband/wife, 2 = biological son or daughter, … |
| `hours_per_week` | Usual hours worked per week, past 12 months | hours (1 to 99; 99 = 99 or more) |
| `income` | Total person's income (the outcome) | dollars per year (2018). Very high incomes may be top-coded (capped) by the Census Bureau for privacy. |

The three `_code` columns stay numeric. Their meanings are in the 2018 PUMS data dictionary (https://www2.census.gov/programs-surveys/acs/tech_docs/pums/data_dict/). No column has missing values.

**Long labels.** We kept the official labels exactly (for example, one `class_of_worker` label is "Employee of a private for-profit company or business, or of an individual, for wages, salary, or commissions"). Do not shorten them in the tidy table. On plots you can shorten them in Module 12 with `scale_*_discrete(labels = …)`.

## 6. Imbalance at a glance (this sample)

- **income above $50,000:** no 67.3% (3,367); yes 32.7% (1,633)
- **sex:** Male 51.4% (2,570); Female 48.6% (2,430)
- **race:** White alone 74.8% (3,742); Black or African American alone 16.5% (823); Asian alone 3.0% (152); Some Other Race alone 2.4% (119); Two or More Races 2.0% (98); American Indian alone 1.1% (53); American Indian and Alaska Native tribes specified (…) 0.2% (8); Native Hawaiian and Other Pacific Islander alone 0.1% (4); Alaska Native alone 0.02% (1)
- **age:** 17–19 4.5%; 20–29 19.0%; 30–39 19.9%; 40–49 18.7%; 50–59 21.7%; 60–69 12.8%; 70–79 2.9%; 80–89 0.4%; 90–94 0.04%

These shares mirror the full North Carolina data **on purpose**: the sample was not balanced, so the groups are as unequal as in the original data.

## 7. Limitations

Groups with **fewer than 30 people** in this sample:
- **race:** `Alaska Native alone` (1), `Native Hawaiian and Other Pacific Islander alone` (4), `American Indian and Alaska Native tribes specified; or American Indian or Alaska Native, not specified and no other races` (8)
- **age:** 80–89 (22), 90–94 (2)

A group with fewer than 30 rows should not be compared on its own without saying so in your report; combine groups or state the small count.

The Census uses survey weights to estimate population figures; this dataset does not include them, so shares and averages describe the people in the survey, not the whole population of North Carolina.

Differences between groups in this data describe this sample at this time and place; they do not show that a group membership causes an outcome.

## 8. Checks to run yourself

```r
stopifnot(
  nrow(acs) == 5000,                          # one row per person
  n_distinct(acs$person_id) == nrow(acs),     # every ID appears exactly once
  ncol(acs) == 12
)
```
