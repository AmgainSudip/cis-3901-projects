# Guided Project: Statistical Transformations and Coordinate Systems --------
# CIS-3901 · Module 12
# Script: scripts/gp12_stats_coords.R   Report: reports/gp12_report.qmd
#
# How to work
# - Run one task at a time: select its lines, then Ctrl/Cmd + Enter.
# - Each task ends with a check. You'll see "PASS: A1" or "TO DO: A1: ..."
#   with what to fix. Nothing stops the script: unfinished tasks show TO DO.
# - The script runs as is, before you change anything. That's on purpose:
#   your report renders from day one, and the checks table in the report
#   shows what is done.
# - Lines marked "YOUR TURN" are the ones you change. Read the rest first
#   (PRIMM: predict, run, investigate, modify).
# - If R restarted and an object is "not found": run the script from the top
#   (Ctrl/Cmd + Shift + Enter).
# - Keep the "## ---- name ----" lines as they are. They mark the pieces of
#   code your report shows, each with its output.

## ---- setup ----
library(tidyverse)

# Colors that color-blind viewers can tell apart (more in Module 13)
options(
  ggplot2.discrete.fill = function() scale_fill_viridis_d(end = 0.8),
  ggplot2.discrete.colour = function() scale_color_viridis_d(end = 0.8)
)


# 0 · Setup (run first) -----------------------------------------------------

## ---- helpers ----
# Your two data files must be at data/tidy/fairness.csv and
# data/sports/sports.csv (Guided Project page, step 1). If you uploaded one
# to the top folder or to data/, this moves it to the right place for you.
put_in_place <- function(file, folder) {
  target <- file.path(folder, file)
  if (file.exists(target)) return(invisible(TRUE))
  found <- c(file, file.path("data", file))
  found <- found[file.exists(found)]
  if (length(found) > 0) {
    dir.create(folder, recursive = TRUE, showWarnings = FALSE)
    file.rename(found[1], target)
    message("Moved ", found[1], " to ", target, ".")
    return(invisible(TRUE))
  }
  stop("Can't find ", target, ". Upload your file into ", folder,
       "/ and name it exactly ", file, " (Guided Project page, step 1). ",
       "A download may have been renamed, e.g. '", sub(".csv", " (1).csv",
       file, fixed = TRUE), "': rename it in the Files pane.",
       call. = FALSE)
}
# A file saved again by a spreadsheet app can end up with each whole row in
# the first column and the other columns mostly empty. If so, get a fresh
# copy instead of fixing it by hand.
looks_damaged <- function(d) {
  ncol(d) < 3 ||
    (mean(grepl(",", d[[1]], fixed = TRUE)) > 0.5 &&
       mean(is.na(d[[ncol(d)]])) > 0.5)
}
# The checks: each task records PASS or TO DO here; the report prints them.
checks <- list()
check <- function(task, ok, fix) {
  passed <- tryCatch(isTRUE(ok), error = function(e) FALSE)
  checks[[task]] <<- if (passed) "PASS" else "TO DO"
  if (passed) {
    message("PASS: ", task)
  } else {
    message("TO DO: ", task, ": ", fix)
  }
  invisible(passed)
}

# Each task ends by showing its result with show_plot(): a plot, or
# "Not done yet."
show_plot <- function(p) {
  if (inherits(p, "ggplot")) p else cat("Not done yet.\n")
}

## ---- data ----
put_in_place("fairness.csv", "data/tidy")
put_in_place("sports.csv", "data/sports")

fairness <- read_csv("data/tidy/fairness.csv", show_col_types = FALSE)
sports <- read_csv("data/sports/sports.csv", show_col_types = FALSE)

if (looks_damaged(fairness) || looks_damaged(sports)) {
  stop("One of your data files looks damaged (each row in one column): it ",
       "may have been re-saved by a spreadsheet app. Ask your instructor ",
       "for a fresh copy.", call. = FALSE)
}

# Your columns
glimpse(fairness)
glimpse(sports)

## ---- a0-instructions ----
# PART A · FAIRNESS ==========================================================
# A0 · Your group and your outcome ------------------------------------------
# Session 1, slide 17: "My outcome is ___. My group is ___."
# YOUR TURN: replace "replace me" with your group column (no quotes), and
# FALSE with a TRUE/FALSE condition for your outcome. Examples (use YOUR
# columns; the Guided Project page lists them for every class dataset):
#   group = sex,           has_outcome = income == ">50K"
#   group = age,           has_outcome = readmit_30_days == 1
## ---- a0 ----
a_data <- fairness %>%
  mutate(
    group = sex,
    has_outcome = income == ">50K"
  )

a_data %>%
  count(group, has_outcome) %>%
  print(n = Inf)

## ---- a0-check ----
# Check (don't change): prints PASS or TO DO with a hint.
check("A0",
  n_distinct(a_data$group) > 1 &&
    is.logical(a_data$has_outcome) &&
    any(a_data$has_outcome, na.rm = TRUE) &&
    !all(a_data$has_outcome, na.rm = TRUE),
  paste("set group to a column with 2 or more groups, and has_outcome to",
        "a condition that is TRUE for some rows and FALSE for others."))


# A1 · Question A: the rate within each group -------------------------------
# Session 1, slides 10 and 17. geom_bar(position = "fill") counts, then
# divides by each group's total: every bar is one group, from 0 to 1.
# PREDICT (write it in your report): which group has the highest rate?
## ---- a1 ----
a1 <- ggplot(a_data, aes(y = group, fill = has_outcome)) +
  geom_bar(position = "fill") +
  labs(x = "Share of the group", y = NULL, fill = "Income >50K")

show_plot(a1)

## ---- a1-check ----
# Check (don't change): prints PASS or TO DO with a hint.
check("A1",
  inherits(a1$layers[[1]]$position, "PositionFill") &&
    rlang::as_label(a1$mapping$fill) == "has_outcome" &&
    n_distinct(a_data$group) > 1,
  "keep geom_bar(position = \"fill\") with fill = has_outcome; finish A0.")


# A2 · Rates with their standard error --------------------------------------
# Session 1, slides 13–16: a summary carries its n and its spread.
# The se of a rate is sqrt(rate * (1 - rate) / n).
# YOUR TURN: replace NA_real_ with that formula.
## ---- a2 ----
a2_rates <- a_data %>%
  drop_na(has_outcome) %>%
  group_by(group) %>%
  summarize(
    n = n(),
    rate = mean(has_outcome),
    se = sqrt(rate * (1 - rate) / n)
  )

a2_rates

a2 <- ggplot(a2_rates,
             aes(x = rate, y = group,
                 xmin = rate - se,
                 xmax = rate + se)) +
  geom_pointrange() +
  # Many groups, and the labels touch the points? Keep every group, and use
  # vjust = -0.8, size = 3 instead of nudge_y = 0.3.
  geom_text(aes(label = paste("n =", n)), nudge_y = 0.3) +
  labs(x = "Rate (share of the group with the outcome)", y = NULL)

show_plot(a2)

## ---- a2-check ----
# Check (don't change): prints PASS or TO DO with a hint.
check("A2",
  all(is.finite(a2_rates$se)) &&
    isTRUE(all.equal(a2_rates$se,
                     sqrt(a2_rates$rate * (1 - a2_rates$rate) / a2_rates$n))),
  "se = sqrt(rate * (1 - rate) / n), inside summarize().")


# A3 · Zoom or filter? -------------------------------------------------------
# Session 2, slides 4–7. Counts per group as sideways bars, then the same
# plot zoomed (coord_cartesian) and filtered (scale limits).
# YOUR TURN: set a3_start to a number above 0 and below your smallest group's
# count (try about half of it). Look at a3_table to choose.
## ---- a3 ----
a3_table <- a_data %>%
  count(group) %>%
  arrange(desc(n))
a3_table

a3_start <- 800

a3_counts <- ggplot(a_data, aes(y = group)) +
  geom_bar() +
  labs(x = "Count", y = NULL)

a3_zoom <- a3_counts +
  coord_cartesian(xlim = c(a3_start, max(a3_table$n)), expand = FALSE)

# A warning about removed rows here is expected (Session 2, slide 5).
a3_filter <- a3_counts +
  scale_x_continuous(limits = c(a3_start, max(a3_table$n)))

# Lie Factor (Tufte, 2001, p. 57) of the zoomed plot, largest vs smallest
# group: how many times the picture exaggerates the difference.
a3_largest <- max(a3_table$n)
a3_smallest <- min(a3_table$n)
a3_lie_factor <-
  ((a3_largest - a3_start) / (a3_smallest - a3_start)) /
  (a3_largest / a3_smallest)
a3_lie_factor

show_plot(a3_counts)
show_plot(a3_zoom)
show_plot(a3_filter)

## ---- a3-check ----
# Check (don't change): prints PASS or TO DO with a hint.
check("A3",
  a3_start > 0 && a3_start < a3_smallest && a3_lie_factor > 1,
  "set a3_start above 0 and below your smallest group's count.")


# A4 · Question B: each group's share of everyone with the outcome ------------
# Session 1, slide 17: a different total (everyone with the outcome).
# Session 2, slide 9: groups down the side.
## ---- a4 ----
a4_shares <- a_data %>%
  filter(has_outcome) %>%
  count(group) %>%
  mutate(share = n / sum(n))

a4 <- ggplot(a4_shares, aes(x = share, y = group)) +
  geom_col() +
  labs(x = "Share of everyone with the outcome", y = NULL)

show_plot(a4)

## ---- a4-check ----
# Check (don't change): prints PASS or TO DO with a hint.
check("A4",
  nrow(a4_shares) > 1 && isTRUE(all.equal(sum(a4_shares$share), 1)),
  paste("share = n / sum(n), so the shares add up to 1; you also need at",
        "least two groups with the outcome (A0)."))
# In your report: do A1/A2 (question A) and A4 (question B) point in the
# same direction? Why or why not?
#=> A1/A2 and A4 point in the same direction because men have a higher rate of earning above $50,000 (30.4%) than women (10.9%). 
#Similarly, men make up 84.9% of everyone earning above $50,000, while women make up 15.1%. 
#Both comparisons show a higher representation of men, although they use different denominators.

# PART B · SPORTS ============================================================
# Same four ideas, less scaffolding. Use your own Sports columns.

# B0 · Your group, outcome and value ------------------------------------------
# YOUR TURN: a group column, a TRUE/FALSE outcome, and a numeric value for B2.
# Examples (use YOUR columns; the Guided Project page has ideas for every
# class dataset):
#   group = position, has_outcome = Round %in% 1, value = forty
## ---- b0 ----
b_data <- sports %>%
  mutate(
    group = surface,
    has_outcome = minutes > 120,
    value = minutes
  )

b_data %>%
  count(group, has_outcome) %>%
  print(n = Inf)

summary(b_data$value)

## ---- b0-check ----
# Check (don't change): prints PASS or TO DO with a hint.
check("B0",
  n_distinct(b_data$group) > 1 &&
    is.logical(b_data$has_outcome) &&
    any(b_data$has_outcome, na.rm = TRUE) &&
    !all(b_data$has_outcome, na.rm = TRUE) &&
    is.numeric(b_data$value) && sum(!is.na(b_data$value)) > 1,
  paste("set group (2 or more groups), has_outcome (TRUE for some rows),",
        "and value (a numeric column)."))


# B1 · Question A: the rate within each group -------------------------------
# YOUR TURN: replace NULL with a ggplot like A1 (geom_bar with
# position = "fill", groups down the side).
## ---- b1 ----
b1 <-  ggplot(b_data, aes(y = group, fill = has_outcome)) +
  geom_bar(position = "fill") +
  labs(x = "Share of the group", y = NULL, fill = "Match over 120 minutes")

show_plot(b1)

## ---- b1-check ----
# Check (don't change): prints PASS or TO DO with a hint.
check("B1",
  inherits(b1, "ggplot") &&
    inherits(b1$layers[[1]]$position, "PositionFill"),
  "make b1 a ggplot with geom_bar(position = \"fill\"), like A1.")


# B2 · A mean with its two spreads --------------------------------------------
# Session 1, slides 13–16 and Session 2, slide 7: center, sd and se.
# YOUR TURN: finish the summary (mean, sd, se of value per group), then
# replace NULL with a plot of mean +/- se (geom_pointrange, n labels).
## ---- b2 ----
b2_summary <- b_data %>%
  drop_na(value) %>%
  group_by(group) %>%
  summarize(
    n = n(),
    mean = mean(value),
    sd = sd(value),
    se = sd / sqrt(n)
  )

b2_summary

b2 <- ggplot(b2_summary,
             aes(x = mean, y = group,
                 xmin = mean - se,
                 xmax = mean + se)) +
  geom_pointrange() +
  # Many groups, and the labels touch the points? Keep every group, and use
  # vjust = -0.8, size = 3 instead of nudge_y = 0.3.
  geom_text(aes(label = paste("n =", n)), nudge_y = 0.3) +
  labs(x = "Mean match duration (minutes)", y = NULL)

show_plot(b2)

## ---- b2-check ----
# Check (don't change): prints PASS or TO DO with a hint.
check("B2",
  inherits(b2, "ggplot") &&
    all(is.finite(b2_summary$mean)) &&
    isTRUE(all.equal(b2_summary$se, b2_summary$sd / sqrt(b2_summary$n))),
  paste("mean = mean(value), sd = sd(value), se = sd / sqrt(n); then make",
        "b2 a geom_pointrange() plot of mean +/- se."))
# In your report: is the gap between two groups' means big compared to the
# se? Compared to the sd? (Session 2, slide 7)


# B3 · Zoom or filter? -------------------------------------------------------
# YOUR TURN: as in A3, with your Sports groups. Set b3_start, then make
# b3_zoom (coord_cartesian) and b3_filter (scale limits) from b3_counts.
## ---- b3 ----
b3_table <- b_data %>%
  count(group) %>%
  arrange(desc(n))
b3_table

b3_start <- 250

b3_counts <- ggplot(b_data, aes(y = group)) +
  geom_bar() +
  labs(x = "Count", y = NULL)

b3_zoom <- b3_counts + 
  coord_cartesian(xlim = c(b3_start, max(b3_table$n)),expand = FALSE
)

b3_filter <- b3_counts +
  scale_x_continuous(limits = c(b3_start, max(b3_table$n)))

b3_lie_factor <-
  ((max(b3_table$n) - b3_start) / (min(b3_table$n) - b3_start)) /
  (max(b3_table$n) / min(b3_table$n))
b3_lie_factor

show_plot(b3_zoom)
show_plot(b3_filter)

## ---- b3-check ----
# Check (don't change): prints PASS or TO DO with a hint.
check("B3",
  inherits(b3_zoom, "ggplot") && inherits(b3_filter, "ggplot") &&
    !is.null(b3_zoom$coordinates$limits$x) &&
    b3_filter$scales$has_scale("x") &&
    b3_start > 0 && b3_start < min(b3_table$n),
  paste("set b3_start; b3_zoom adds coord_cartesian(xlim = ...), b3_filter",
        "adds scale_x_continuous(limits = ...), both from b3_counts (A3)."))


# B4 · Question B: each group's share of everyone with the outcome ------------
# YOUR TURN: replace NULL with the B version of a4_shares and a4.
## ---- b4 ----
b4_shares <- b_data %>%
  filter(has_outcome) %>%
  count(group) %>%
  mutate(share = n / sum(n))

b4_shares

b4 <- ggplot(b4_shares, aes(x = share, y = group)) +
  geom_col() +
  labs(x = "Share of every surface with the outcome", y = NULL)

show_plot(b4)

## ---- b4-check ----
# Check (don't change): prints PASS or TO DO with a hint.
check("B4",
  inherits(b4, "ggplot") &&
    isTRUE(all.equal(sum(b4_shares$share), 1)),
  "make b4_shares (filter, count, share = n / sum(n)) and plot b4 like A4.")


# Checks summary (the report prints this table) -------------------------------
## ---- checks-table ----
checks_table <- tibble(
  task = names(checks),
  status = unlist(checks)
)
checks_table
