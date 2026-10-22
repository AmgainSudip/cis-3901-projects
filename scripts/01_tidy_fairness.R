# 01_tidy_fairness.R: tidy my Fairness Data package (Challenge Project: Tidy Data)
# Purpose: turn the messy CSV files of one Fairness Data package into tidy table(s).
# Input:   data/fairness/<your_dataset>/*.csv (read your dataset card, README.md, first)
# Output:  data/tidy/<your_dataset>.csv
# Run from the project root (the folder that contains data/), e.g. in Posit Cloud.

library(tidyverse)

# ---- Read ---------------------------------------------------------------------
# folder <- "data/fairness/your_dataset"
# my_file <- read_csv(file.path(folder, "your_file.csv"))

# ---- Your tidying steps here (melt, separate, cast, normalize, join, stack) ----
# Use the revised Tidying Operations answer key as your guide.
# Check row counts before and after each step, and finish with stopifnot() checks.

# ---- Write --------------------------------------------------------------------
# write_csv(my_tidy_table, "data/tidy/your_dataset.csv")
