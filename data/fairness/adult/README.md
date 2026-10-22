# Adult (1994 US Census income)

Fairness Data (datasets from Fairlearn) · CIS-3901 Challenge Project: Tidy Data

## 1. Purpose

Use this dataset to investigate how income above $50,000 a year relates to age, education, work and family, and whether that relationship differs by sex, race or country of birth. In the tidy table, **each row is one person**.

## 2. Source and context

- **Source:** Becker, B. & Kohavi, R. (1996). *Adult* [Dataset]. UCI Machine Learning Repository. https://doi.org/10.24432/C5XW20. Accessed through Fairlearn (`fetch_adult`).
- **License:** CC BY 4.0. You may share and adapt the data if you **credit the source above** in your report and slides.
- **Collection:** extracted by Barry Becker from the 1994 US Census Bureau Current Population Survey. Only adults (older than 16) with some income and some working hours were kept.
- **This sample:** 5,000 of the 48,842 people, drawn at random within groups defined by income × sex × race (stratified, proportional, seed 3901). The groups keep the same shares as in the full data. `person_id` was assigned by us in random order; it is not in the original data. The census sampling weight `fnlwgt` was removed.
- **Dated or unfamiliar terms:** the race categories are the 1994 census wording (e.g. `Amer-Indian-Eskimo`, `Asian-Pac-Islander`); today the Census Bureau uses different categories. `Married-AF-spouse` means a spouse in the Armed Forces. Some country labels are abbreviated in the source (`Hong` is Hong Kong; `South` is not explained). Dollar amounts are 1994 dollars.

## 3. Files

Read each file with `read_csv()` from its raw URL (works once the course repository is public):

| File | What it holds |
|---|---|
| `adult_batch_1.csv`, `adult_batch_2.csv`, `adult_batch_3.csv` | People, in three batches: demographics, education, work, hours worked and income class |
| `adult_money_long.csv` | Capital gains and capital losses for each person |

```r
url <- "https://raw.githubusercontent.com/acintron-cc/cis-3901-202710/main/data/fairness/adult/"
# e.g. read_csv(paste0(url, "adult_money_long.csv"))
```

Or, in your copy of the course template: `read_csv("data/fairness/adult/adult_money_long.csv")`.

**Problems in this package** (Wickham 2014). Somewhere in these files you will find:
- column headers that are values, not variable names;
- several variables stored in one column;
- variables stored in rows instead of columns;
- one observational unit (people) spread across several files.

It is your job to diagnose which file has which problem. Your guide is the revised **Tidying Operations answer key**: every fix you need appears there.

**Difficulty:** Standard.

## 4. Task

Produce one tidy table, `adult`, with exactly these 15 columns in this order (types as `read_csv()` shows them):

`person_id` <dbl>, `age` <dbl>, `workclass` <chr>, `education` <chr>, `education_num` <dbl>, `marital_status` <chr>, `occupation` <chr>, `relationship` <chr>, `race` <chr>, `sex` <chr>, `capital_gain` <dbl>, `capital_loss` <dbl>, `hours_per_week` <dbl>, `native_country` <chr>, `income` <chr>

## 5. Codebook

| Column | Meaning | Type, units, codes |
|---|---|---|
| `person_id` | ID of the person (assigned by us) | 1 to 5000 |
| `age` | Age | years (17 to 90) |
| `workclass` | Type of employer | e.g. `Private`, `Self-emp-not-inc`, `Local-gov`; **NA** = missing |
| `education` | Highest education level | 16 levels, e.g. `HS-grad`, `Bachelors`, `Doctorate` |
| `education_num` | Education level as a number | 1 (`Preschool`) to 16 (`Doctorate`); matches `education` one to one |
| `marital_status` | Marital status | 7 levels, e.g. `Married-civ-spouse`, `Never-married` |
| `occupation` | Occupation group | 14 levels, e.g. `Prof-specialty`; **NA** = missing |
| `relationship` | Role in the household | `Husband`, `Wife`, `Own-child`, `Not-in-family`, `Unmarried`, `Other-relative` |
| `race` | Race (1994 categories) | `White`, `Black`, `Asian-Pac-Islander`, `Amer-Indian-Eskimo`, `Other` |
| `sex` | Sex | `Female`, `Male` |
| `capital_gain` | Capital gains in the year | dollars (1994) |
| `capital_loss` | Capital losses in the year | dollars (1994) |
| `hours_per_week` | Usual hours worked per week | hours |
| `native_country` | Country of birth | 41 countries in the full data (40 in this sample); **NA** = missing |
| `income` | Income class (the outcome) | `>50K` or `<=50K` dollars per year |

**Missing values.** `workclass` (290 rows), `occupation` (290) and `native_country` (93) have real missing values (`NA`). Keep them. `values_drop_na = TRUE` only removes the empty cells in `Female`/`Male`; the real missing values (e.g. in `native_country`) stay `NA`, as they should.

## 6. Imbalance at a glance (this sample)

- **income:** `<=50K` 76.1% (3,805); `>50K` 23.9% (1,195)
- **sex:** Male 66.9% (3,343); Female 33.1% (1,657)
- **race:** White 85.5% (4,276); Black 9.6% (479); Asian-Pac-Islander 3.1% (156); Amer-Indian-Eskimo 0.9% (47); Other 0.8% (42)
- **age:** 17–19 4.6%; 20–29 24.1%; 30–39 28.0%; 40–49 22.2%; 50–59 13.0%; 60–69 6.2%; 70–79 1.5%; 80–89 0.3%; 90 0.1%
- **native_country:** United-States 89.5% (4,474); Mexico 2.0% (101); missing 1.9% (93); Philippines 0.7% (35); 37 other countries 5.9% (297)

These shares mirror the full dataset **on purpose**: the sample was not balanced, so the groups are as unequal as in the original data.

## 7. Limitations

Groups with **fewer than 30 people** in this sample:
- **age:** 80–89 (16), 90 (5)
- **native_country:** 37 of the 40 countries in the sample, every one except United-States, Mexico and Philippines (from Canada, 20, down to Cambodia, Laos and Yugoslavia, 1 each). `Holand-Netherlands` (1 person in the full data) is not in the sample.

A group with fewer than 30 rows should not be compared on its own without saying so in your report; combine groups or state the small count.

The Census uses survey weights to estimate population figures; this dataset does not include them, so shares and averages describe the people in the survey, not the whole population of the United States.

Differences between groups in this data describe this sample at this time and place; they do not show that a group membership causes an outcome.

## 8. Checks to run yourself

```r
stopifnot(
  nrow(adult) == 5000,                          # one row per person
  n_distinct(adult$person_id) == nrow(adult),   # every ID appears exactly once
  ncol(adult) == 15
)
```
