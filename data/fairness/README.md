# Fairness Data (datasets from Fairlearn)

CIS-3901 Data Visualization and Presentation · used in Module 9 (dataset selection), the **Challenge Project: Tidy Data** and the **Challenge Project: Fairness Data**.

Each folder holds one dataset as a set of **messy CSV files** plus a `README.md` (the dataset card). Every package is a 5,000-row sample of a dataset that Fairlearn makes available. The samples keep the groups as unequal as in the full data **on purpose**, because how outcomes differ across groups is what you will investigate.

## The five packages

| Package | Each tidy row is | Outcome (rate in sample) | Sensitive attributes | Files | Difficulty |
|---|---|---|---|---|---|
| [`adult/`](adult/) | a person, US 1994 | income `>50K` (23.9%) | sex, race, age, country of birth | 4 | Standard |
| [`acs_income_nc/`](acs_income_nc/) | a person, North Carolina 2018 | income in dollars (32.7% above $50,000) | sex, race, age | 5 | Standard |
| [`bank_marketing/`](bank_marketing/) | a bank client, Portugal 2008–2010 | subscribed to a term deposit (11.7%) | marital status, age | 5 | Standard |
| [`credit_card/`](credit_card/) | a client, **and** a client in a month, Taiwan 2005 | default next month (22.1%) | sex, education, marital status, age | 3 | **Challenging** (two tables) |
| [`diabetes_hospital/`](diabetes_hospital/) | a hospital encounter, US 1999–2008 | readmitted (11.2% within 30 days; 46.1% at any time) | race, gender, age | 3 | Standard |

## How to choose

1. **Start from a question you care about**: income and work (Adult, ACS), marketing (Bank), credit and debt (Credit Card), or health care (Diabetes). Read the Purpose section of each card.
2. **Check the groups you want to compare.** Each card lists the share of every group and the groups with fewer than 30 rows; very small groups cannot be compared on their own.
3. **Check the difficulty.** The four Standard packages each become one tidy table. Credit Card becomes two tables (clients and client-months); choose it if you want a challenge.
4. **Look at the files.** Open one or two CSVs and the card's Task section: it lists the exact columns your tidy table must have.

## Tidying

Every fix you need appears in the revised **Tidying Operations answer key**. The cards say which of Wickham's (2014) five problems occur in each package, not which file needs which fix: diagnosing that is part of the project. After grading, you will receive the verified tidy version of your own dataset with your feedback, so everyone starts the Fairness Data project from the same correct data.

Read a file from its raw URL, for example:

```r
library(tidyverse)
url <- "https://raw.githubusercontent.com/acintron-cc/cis-3901-202710/main/data/fairness/"
clients <- read_csv(paste0(url, "bank_marketing/clients.csv"))
```

## Sources and licenses

Credit the source of your dataset in your report and slides; each card gives the full citation.

- Adult, Bank Marketing, Credit Card and Diabetes Hospital: UCI Machine Learning Repository, **CC BY 4.0** (attribution required).
- ACS Income: US Census Bureau, 2018 American Community Survey PUMS (public data), as prepared by folktables (Ding et al., 2021).
- All five were accessed through Fairlearn (`fairlearn.datasets`). Sampling: stratified by outcome and sensitive attributes, proportional allocation, seed 3901.
