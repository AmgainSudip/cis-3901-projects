# Bank Marketing (Portugal, 2008–2010)

Fairness Data (datasets from Fairlearn) · CIS-3901 Challenge Project: Tidy Data

## 1. Purpose

Use this dataset to investigate which bank clients subscribed to a term deposit after a phone marketing campaign, how that relates to their finances and to how they were contacted, and whether it differs by marital status or age. In the tidy table, **each row is one client**.

## 2. Source and context

- **Source:** Moro, S., Rita, P., & Cortez, P. (2014). *Bank Marketing* [Dataset]. UCI Machine Learning Repository. https://doi.org/10.24432/C5K306. Accessed through Fairlearn (`fetch_bank_marketing`).
- **License:** CC BY 4.0. You may share and adapt the data if you **credit the source above** in your report and slides.
- **Collection:** phone marketing campaigns of a Portuguese bank, 2008–2010. Often a client was called more than once in the same campaign.
- **This sample:** 5,000 of the 45,211 clients, drawn at random within groups defined by subscribed × marital status × age band (stratified, proportional, seed 3901). The groups keep the same shares as in the full data. The original data have **no client identifier**: we treat each row as one client (no row is repeated) and **`client_id` was assigned by us** in random order.
- **Dated or unfamiliar terms:** `balance` is in **euros**. `divorced` means divorced **or widowed**. `admin.` is administrative work. `duration` is only known after the call has ended.

## 3. Files

Read each file with `read_csv()` from its raw URL (works once the course repository is public):

| File | What it holds |
|---|---|
| `clients.csv` | One row per client: age, job, education, marital status and average yearly balance |
| `credit_products_long.csv` | Whether each client has credit in default, a housing loan and a personal loan |
| `contacts_1.csv`, `contacts_2.csv`, `contacts_3.csv` | The campaign contacts, in three batches: contact type, date of the last contact, call duration, contact counts, previous outcome and whether the client subscribed |

```r
url <- "https://raw.githubusercontent.com/acintron-cc/cis-3901-202710/main/data/fairness/bank_marketing/"
# e.g. read_csv(paste0(url, "clients.csv"))
```

Or, in your copy of the course template: `read_csv("data/fairness/bank_marketing/clients.csv")`.

**Problems in this package** (Wickham 2014). Somewhere in these files you will find:
- column headers that are values, not variable names;
- several variables stored in one column;
- variables stored in rows instead of columns;
- one observational unit (clients) spread across several files.

It is your job to diagnose which file has which problem. Your guide is the revised **Tidying Operations answer key**: every fix you need appears there.

**Hint:** in `clients.csv`, the headers `married`, `single` and `divorced` are values of one variable, `marital`.

**Difficulty:** Standard.

## 4. Task

Produce one tidy table, `bank`, with exactly these 18 columns in this order (types as `read_csv()` shows them):

`client_id` <dbl>, `age` <dbl>, `job` <chr>, `marital` <chr>, `education` <chr>, `default` <chr>, `balance` <dbl>, `housing` <chr>, `loan` <chr>, `contact` <chr>, `contact_day` <dbl>, `contact_month` <chr>, `duration` <dbl>, `campaign` <dbl>, `pdays` <dbl>, `previous` <dbl>, `poutcome` <chr>, `subscribed` <chr>

## 5. Codebook

| Column | Meaning | Type, units, codes |
|---|---|---|
| `client_id` | ID of the client (assigned by us) | 1 to 5000 |
| `age` | Age | years (18 to 88 in this sample) |
| `job` | Type of job | 12 levels, e.g. `blue-collar`, `management`, `admin.`, `unknown` |
| `marital` | Marital status | `married`, `single`, `divorced` (divorced or widowed) |
| `education` | Education | `primary`, `secondary`, `tertiary`, `unknown` |
| `default` | Has credit in default? | `yes`, `no` |
| `balance` | Average yearly balance | euros (can be negative) |
| `housing` | Has a housing loan? | `yes`, `no` |
| `loan` | Has a personal loan? | `yes`, `no` |
| `contact` | Type of the last contact | `cellular`, `telephone`, `unknown` |
| `contact_day` | Day of the month of the last contact | 1 to 31 |
| `contact_month` | Month of the last contact | `jan` … `dec` |
| `duration` | Length of the last call | seconds |
| `campaign` | Contacts with this client in this campaign | count (includes the last contact) |
| `pdays` | Days since the client was last contacted in a previous campaign | days; **−1 = not contacted before** |
| `previous` | Contacts with this client before this campaign | count |
| `poutcome` | Outcome of the previous campaign | `success`, `failure`, `other`, `unknown` |
| `subscribed` | Subscribed to a term deposit (the outcome) | `yes`, `no` |

No column has missing values; `unknown` is a level in the source data, not a missing value.

## 6. Imbalance at a glance (this sample)

- **subscribed:** no 88.3% (4,415); yes 11.7% (585)
- **marital:** married 60.2% (3,009); single 28.3% (1,413); divorced 11.6% (578)
- **age:** under 25 1.8% (90); 25–59 94.3% (4,713); 60 and over 3.9% (197)
- **job:** blue-collar 22.1%; management 20.8%; technician 16.9%; admin. 10.7%; services 8.9%; retired 4.9%; entrepreneur 3.6%; self-employed 3.6%; unemployed 2.8%; housemaid 2.7%; student 2.2%; unknown 0.8% (41)

These shares mirror the full dataset **on purpose**: the sample was not balanced, so the groups are as unequal as in the original data.

## 7. Limitations

No level of `marital`, age band or `job` has fewer than 30 clients in this sample. Small groups can still appear when you cross variables (for example, subscribers under 25): if a group has fewer than 30 rows, do not compare it on its own without saying so in your report.

Differences between groups in this data describe this sample at this time and place; they do not show that a group membership causes an outcome.

## 8. Checks to run yourself

```r
stopifnot(
  nrow(bank) == 5000,                           # one row per client
  n_distinct(bank$client_id) == nrow(bank),     # every ID appears exactly once
  ncol(bank) == 18
)
```
