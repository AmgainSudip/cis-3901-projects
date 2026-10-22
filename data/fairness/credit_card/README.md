# Credit Card clients (Taiwan, 2005)

Fairness Data (datasets from Fairlearn) · CIS-3901 Challenge Project: Tidy Data

## 1. Purpose

Use this dataset to investigate which credit card clients default on their payment the next month, how bills and payments change over six months, and whether patterns differ by sex, education, marital status or age. The tidy result has **two tables**: in `clients`, **each row is one client**; in `client_months`, **each row is one client in one month**.

## 2. Source and context

- **Source:** Yeh, I. (2009). *Default of Credit Card Clients* [Dataset]. UCI Machine Learning Repository. https://doi.org/10.24432/C55S3H. Accessed through Fairlearn (`fetch_credit_card`). Original study: Yeh, I. C., & Lien, C. H. (2009), *Expert Systems with Applications*, 36(2), 2473–2480.
- **License:** CC BY 4.0. You may share and adapt the data if you **credit the source above** in your report and slides.
- **Collection:** clients of a bank in Taiwan, with monthly records from April to September 2005 and whether they defaulted on the next payment.
- **This sample:** 5,000 of the 30,000 clients, drawn at random within groups defined by default × sex × education code (stratified, proportional, seed 3901). The groups keep the same shares as in the full data. `client_id` was assigned by us in random order; it is not in the original data.
- **Dated or unfamiliar terms:** money is in **New Taiwan dollars (NT$)**, 2005 values. A bill amount can be negative (the client had a credit balance). Education codes 0, 5 and 6 and marriage code 0 appear in the data but **are not defined in the original documentation**; their labels say so (`undocumented (0)`, `unknown`).

## 3. Files

Read each file with `read_csv()` from its raw URL (works once the course repository is public):

| File | What it holds |
|---|---|
| `credit_wide.csv` | One row per client: credit limit, sex, education and marriage codes, age, default, and 18 monthly columns (repayment status, bill amount, amount paid, Apr to Sep 2005) |
| `education_codes.csv` | What each education code means |
| `marriage_codes.csv` | What each marriage code means |

```r
url <- "https://raw.githubusercontent.com/acintron-cc/cis-3901-202710/main/data/fairness/credit_card/"
# e.g. read_csv(paste0(url, "credit_wide.csv"))
```

Or, in your copy of the course template: `read_csv("data/fairness/credit_card/credit_wide.csv")`.

**Problems in this package** (Wickham 2014). Somewhere in these files you will find:
- column headers that are values, not variable names;
- several variables stored in one column name;
- variables stored in both rows and columns;
- two types of observational unit (clients, and clients in months) in one table;
- one table's information split across several files (codes in one, their labels in others).

It is your job to diagnose which file has which problem. Your guide is the revised **Tidying Operations answer key**: every fix you need appears there.

**Difficulty:** **Challenging**. This package has two observational units, so the result is two tables, not one. Look at how the `billboard` example becomes `songs` and `ranks`.

## 4. Task

Produce two tidy tables with exactly these columns in this order (types as `read_csv()` shows them):

- `clients` (5,000 rows): `client_id` <dbl>, `limit_bal` <dbl>, `sex` <chr>, `education` <chr>, `marriage` <chr>, `age` <dbl>, `default_next_month` <chr>
- `client_months` (30,000 rows): `client_id` <dbl>, `month` <chr>, `pay_status` <dbl>, `bill_amt` <dbl>, `pay_amt` <dbl>

## 5. Codebook

**`clients`**

| Column | Meaning | Type, units, codes |
|---|---|---|
| `client_id` | ID of the client (assigned by us); links the two tables | 1 to 5000 |
| `limit_bal` | Amount of credit given (the client's and family's cards) | NT$ |
| `sex` | Sex | `male`, `female` |
| `education` | Education | `graduate school`, `university`, `high school`, `others`, `unknown` (codes 5 and 6), `undocumented (0)` |
| `marriage` | Marital status | `married`, `single`, `others`, `undocumented (0)` |
| `age` | Age | years (21 to 79) |
| `default_next_month` | Defaulted on the next payment (the outcome) | `yes`, `no` |

**`client_months`**

| Column | Meaning | Type, units, codes |
|---|---|---|
| `client_id` | ID of the client | links to `clients` |
| `month` | Month of the record | `"2005-04"` to `"2005-09"` (text, year-month) |
| `pay_status` | Repayment status that month | −1 = paid on time; 1 to 8 = payment delayed that many months (9 = nine months or more; none in this sample); −2 and 0 appear but are **not defined** in the original documentation |
| `bill_amt` | Amount on the bill statement | NT$ (can be negative) |
| `pay_amt` | Amount paid | NT$ |

No column has missing values.

## 6. Imbalance at a glance (this sample, `clients`)

- **default_next_month:** no 77.9% (3,893); yes 22.1% (1,107)
- **sex:** female 60.4% (3,018); male 39.6% (1,982)
- **education:** university 46.7% (2,337); graduate school 35.3% (1,764); high school 16.4% (820); unknown 1.1% (56); others 0.4% (21); undocumented (0) 0.04% (2)
- **marriage:** single 52.3% (2,614); married 46.2% (2,311); others 1.2% (60); undocumented (0) 0.3% (15)
- **age:** 21–29 32.5%; 30–39 37.9%; 40–49 20.8%; 50–59 7.9%; 60–69 0.9%; 70–79 0.1%

These shares mirror the full dataset **on purpose**: the sample was not balanced, so the groups are as unequal as in the original data.

## 7. Limitations

Groups with **fewer than 30 clients** in this sample:
- **education:** `others` (21), `undocumented (0)` (2)
- **marriage:** `undocumented (0)` (15)
- **age:** 70–79 (3)

A group with fewer than 30 rows should not be compared on its own without saying so in your report; combine groups or state the small count. The undocumented codes cannot be interpreted; say so if you show them.

Differences between groups in this data describe this sample at this time and place; they do not show that a group membership causes an outcome.

## 8. Checks to run yourself

```r
stopifnot(
  nrow(clients) == 5000,                                  # one row per client
  n_distinct(clients$client_id) == nrow(clients),         # every ID appears exactly once
  nrow(client_months) == 30000,                           # 5,000 clients x 6 months
  nrow(distinct(client_months, client_id, month)) == nrow(client_months)
)
```
