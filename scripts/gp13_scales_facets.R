# Guided Project: Scales and Facets ----------------------------------------
# CIS-3901 · Module 13
# Script: scripts/gp13_scales_facets.R
# Report: reports/gp13_report.qmd   Slides: presentations/gp13_slides.qmd
#
# Edit the code in the script. The report and the slides only read it.
# Your words (findings, headlines, limits) live in the report and the slides.
#
# How to work
# - Run section by section: select a task's lines, then Ctrl/Cmd + Enter.
# - Each task ends with a check: it prints PASS or TO DO, with what to fix.
# - The script runs as is from day one. Unfinished plots are NULL and show
#   "Not done yet.", so your report and slides render before you start.
# - Lines marked "YOUR TURN" are the ones you change.
# - If R restarted and an object is "not found": run the script from the top
#   (Ctrl/Cmd + Shift + Enter).
# - Keep the "## ---- name ----" lines as they are: the report and the
#   slides read the code by those names.
# - Keep the code chunks in the report and the slides empty. On render, each
#   one runs this script's code: code typed into them is ignored.
# - Your data files: data/fairness.csv and data/sports.csv (Section 0 moves
#   them there if they are still where Module 12 kept them).

## ---- setup ----
library(tidyverse)

# Colors that color-blind viewers can tell apart (Session 1)
options(
  ggplot2.discrete.fill = function() scale_fill_viridis_d(end = 0.8),
  ggplot2.discrete.colour = function() scale_color_viridis_d(end = 0.8)
)


# 0 · Setup (run first) -----------------------------------------------------
# Prepared helpers: run them, no need to change or read them.

## ---- helpers ----
# Your two data files must be at data/fairness.csv and data/sports.csv
# (Guided Project page). If one is still where the Module 12 Guided Project
# kept it (data/tidy/ or data/sports/), in the top folder, or renamed by a
# download (e.g. "fairness (1).csv"), this moves it into data/ and says so.
put_in_place <- function(file) {
  target <- file.path("data", file)
  if (file.exists(target)) return(invisible(TRUE))
  stem <- sub(".csv", "", file, fixed = TRUE)
  renamed <- list.files(c(".", "data", "data/tidy", "data/sports"),
                        pattern = paste0("^", stem, " ?\\([0-9]+\\)\\.csv$"),
                        full.names = TRUE)
  found <- c(file.path(c("data/tidy", "data/sports"), file), file, renamed)
  found <- found[file.exists(found)]
  if (length(found) > 0) {
    dir.create("data", showWarnings = FALSE)
    file.rename(found[1], target)
    message("Moved ", sub("^\\./", "", found[1]), " to ", target, ".")
    return(invisible(TRUE))
  }
  stop("Can't find ", target, ". In the Files pane, open the data folder, ",
       "click Upload, and choose your file; it must be named exactly ",
       file, " (Guided Project page).", call. = FALSE)
}
# A file saved again by a spreadsheet app can end up with each whole row in
# the first column and the other columns mostly empty. If so, get a fresh
# copy instead of fixing it by hand.
looks_damaged <- function(d) {
  ncol(d) < 3 ||
    (mean(grepl(",", d[[1]], fixed = TRUE)) > 0.5 &&
       mean(is.na(d[[ncol(d)]])) > 0.5)
}

# Each task ends by showing its result with show_plot(): a plot, or
# "Not done yet."
show_plot <- function(p) {
  if (inherits(p, "ggplot")) p else cat("Not done yet.\n")
}

# Your columns: name, type, how many different values, how many missing.
# No values are printed: your report is public, and some data files have
# people's names in them.
show_columns <- function(d) {
  tibble(
    column = names(d),
    type = map_chr(d, function(x) class(x)[1]),
    values = map_int(d, n_distinct),
    missing = map_int(d, function(x) sum(is.na(x)))
  ) %>%
    print(n = Inf)
}

# A0's ready plot uses your first Fairness column with 2 to 10 groups.
pick_a_column <- function(d) {
  few <- names(d)[map_lgl(d, function(x) {
    (is.character(x) || is.factor(x) || is.logical(x)) &&
      n_distinct(x) >= 2 && n_distinct(x) <= 10
  })]
  if (length(few) > 0) few[1] else names(d)[1]
}

# color_check(): can every reader tell your colors apart? We simulate how
# the plotted colors look to readers with three types of color blindness,
# then measure how far apart the two closest colors are (delta E, CIELAB).
# Bigger is easier to tell apart; 20 is the course's line for clearly
# different. Simulation: Machado, Oliveira & Fernandes (2009), severity 1.
# The red-green simulations come from a validated model; the blue-yellow
# one is an approximation.
cvd_matrices <- list(
  "Red-green (deuteranopia)" = matrix(c(
    0.367322, 0.860646, -0.227968,
    0.280085, 0.672501, 0.047413,
    -0.011820, 0.042940, 0.968881), 3, byrow = TRUE),
  "Red-green (protanopia)" = matrix(c(
    0.152286, 1.052583, -0.204868,
    0.114503, 0.786281, 0.099216,
    -0.003882, -0.048116, 1.051998), 3, byrow = TRUE),
  "Blue-yellow (approximate)" = matrix(c(
    1.255528, -0.076749, -0.178779,
    -0.078411, 0.930809, 0.147602,
    0.004733, 0.691367, 0.303900), 3, byrow = TRUE)
)
to_linear <- function(x) {
  ifelse(x <= 0.04045, x / 12.92, ((x + 0.055) / 1.055)^2.4)
}
to_srgb <- function(x) {
  x <- pmin(pmax(x, 0), 1)
  ifelse(x <= 0.0031308, 12.92 * x, 1.055 * x^(1 / 2.4) - 0.055)
}
# The simulated colors (one row per color, red, green and blue from 0 to 1)
simulate_colors <- function(colors, cvd) {
  rgb <- t(grDevices::col2rgb(colors)) / 255
  to_srgb(to_linear(rgb) %*% t(cvd))
}
min_delta_e <- function(colors, cvd) {
  lab <- grDevices::convertColor(simulate_colors(colors, cvd),
                                 from = "sRGB", to = "Lab")
  min(dist(lab))
}
# The colors a plot draws for its categories (color or fill)
color_aes <- standardise_aes_names(c("color", "fill"))
plotted_colors <- function(p) {
  if (!inherits(p, "ggplot")) return(character(0))
  scales_used <- ggplot_build(p)$plot$scales
  out <- character(0)
  for (aes_name in color_aes) {
    sc <- scales_used$get_scales(aes_name)
    if (!is.null(sc) && inherits(sc, "ScaleDiscrete")) {
      mapped <- sc$map(sc$get_limits())
      # Missing values are drawn in the scale's na.value, if it has one
      mapped[is.na(mapped)] <- sc$na.value
      out <- c(out, mapped)
    }
  }
  unique(out[!is.na(out)])
}
color_check <- function(p) {
  colors <- plotted_colors(p)
  if (length(colors) < 2) {
    cat("Not done yet: map a column with a few categories to color or",
        "fill,\nwith a different color for each.\n")
    return(invisible(NULL))
  }
  result <- tibble(
    view = names(cvd_matrices),
    smallest_difference = map_dbl(cvd_matrices, function(m) {
      min_delta_e(colors, m)
    }),
    at_least_20 = if_else(smallest_difference >= 20, "Yes", "No")
  ) %>%
    mutate(smallest_difference = round(smallest_difference, 1))
  cat(length(colors), "colors. The red-green simulations come from a",
      "validated model;\nthe blue-yellow one is an approximation.\n")
  if (any(result$at_least_20 == "No")) {
    cat("Below 20: choose a column with fewer categories, group rare ones",
        "with care\n(keep small groups visible and say so), or use",
        "panels.\n")
  }
  result
}

# simulate_plot(p, view): your plot redrawn with each color replaced by the
# same simulated color color_check() measures, so you can see it, not only
# read the numbers. view is one of the three rows of color_check().
simulate_plot <- function(p, view = "Red-green (deuteranopia)") {
  if (!inherits(p, "ggplot")) return(NULL)
  view <- match.arg(view, names(cvd_matrices))
  built <- ggplot_build(p)$plot$scales
  out <- p
  for (aes_name in color_aes) {
    sc <- built$get_scales(aes_name)
    if (is.null(sc) || !inherits(sc, "ScaleDiscrete")) next
    limits <- sc$get_limits()
    limits <- limits[!is.na(limits)]
    simulated <- grDevices::rgb(simulate_colors(sc$map(limits),
                                                cvd_matrices[[view]]))
    new_scale <- sc$clone()
    new_scale$palette <- local({
      values <- set_names(simulated, limits)
      function(n) values
    })
    new_scale$palette.cache <- NULL
    new_scale$n.breaks.cache <- NULL
    if (!is.na(sc$na.value)) {
      new_scale$na.value <- grDevices::rgb(
        simulate_colors(sc$na.value, cvd_matrices[[view]]))
    }
    out <- suppressMessages(out + new_scale)
  }
  out + labs(caption = paste("Simulated:", view))
}

# make_clouds(data, group, value): the uncertainty clouds (Session 2). For
# each group, its individual values and 200 resampled means (each the mean
# of the group's values drawn again with replacement). Returns three
# columns: group, value and kind ("Individual values" or "Resampled means").
make_clouds <- function(data, group, value) {
  values <- data %>%
    transmute(group = as.character({{ group }}), value = {{ value }}) %>%
    drop_na()
  set.seed(3901)
  means <- values %>%
    group_by(group) %>%
    summarize(value = list(replicate(200, mean(sample(value,
                                                       replace = TRUE)))),
              .groups = "drop") %>%
    unnest(value)
  bind_rows(
    mutate(values, kind = "Individual values"),
    mutate(means, kind = "Resampled means")
  )
}

# The checks: each task records PASS or TO DO here; the report prints them.
checks <- list()
check <- function(task, problems) {
  problems <- tryCatch(problems, error = function(e) {
    "finish the task's code first (it gives an error)."
  })
  passed <- length(problems) == 0
  checks[[task]] <<- if (passed) "PASS" else "TO DO"
  if (passed) {
    message("PASS: ", task)
  } else {
    message("TO DO: ", task, ": ", paste(problems, collapse = " "))
  }
  invisible(passed)
}
is_blank <- function(x) {
  !is.character(x) || length(x) != 1 || is.na(x) ||
    trimws(x) %in% c("", "___")
}
todo_plot <- function(p, name) {
  if (inherits(p, "ggplot")) character(0) else
    paste0(name, " is still NULL: make it a ggplot.")
}
todo_reason <- function(reason, name) {
  if (is_blank(reason)) paste0("write one sentence in ", name, ".") else
    character(0)
}
# Title, subtitle, x and y: present, not "___", not a column name
todo_labels <- function(p, name, columns) {
  if (!inherits(p, "ggplot")) return(character(0))
  labels <- get_labs(p)
  bad <- keep(c("title", "subtitle", "x", "y"), function(l) {
    value <- labels[[l]]
    is.null(value) || isTRUE(attr(value, "fallback")) ||
      !is.character(value) || is_blank(value) || value %in% columns
  })
  if (length(bad) == 0) return(character(0))
  paste0("in ", name, "'s labs(), write ", paste(bad, collapse = ", "),
         " for a reader (not ___ and not a column name).")
}
axis_scales <- function(p) {
  s <- layer_scales(p)
  keep(list(x = s$x, y = s$y), function(sc) {
    inherits(sc, "ScaleContinuous")
  })
}
has_percent <- function(p) {
  any(map_lgl(axis_scales(p), function(sc) {
    any(grepl("%", sc$get_labels(), fixed = TRUE))
  }))
}
todo_percent <- function(p, name) {
  if (!inherits(p, "ggplot") || has_percent(p)) return(character(0))
  paste0("add percent labels to ", name, "'s rate axis: ",
         "scale_x_continuous(labels = scales::percent) (or scale_y_).")
}
log_axes <- function(p) {
  names(keep(axis_scales(p), function(sc) {
    sc$get_transformation()$name == "log-10"
  }))
}
# Values of 0 or below on a log axis are dropped by ggplot2
dropped_by_log <- function(p, axis) {
  mapping <- p$mapping[[axis]]
  for (l in p$layers) {
    if (!is.null(l$mapping[[axis]])) mapping <- l$mapping[[axis]]
  }
  if (is.null(mapping)) return(0)
  values <- rlang::eval_tidy(mapping, p$data)
  sum(is.finite(values) & values <= 0)
}
todo_scale <- function(p, name) {
  if (!inherits(p, "ggplot")) return(character(0))
  logs <- log_axes(p)
  if (length(logs) == 0 && !has_percent(p)) {
    return(paste0("give ", name, " a scale choice: scale_x_log10() or ",
                  "scale_y_log10() for a skewed column, or percent ",
                  "labels for a share."))
  }
  dropped <- sum(map_dbl(logs, function(a) dropped_by_log(p, a)))
  if (dropped > 0) {
    return(paste0(dropped, if (dropped == 1) " row has" else " rows have",
                  " 0 or a negative value, which a ",
                  "log scale drops without a word. Keep only values above ",
                  "0 first (filter(column > 0)) and say how many in your ",
                  "report."))
  }
  character(0)
}
# Panels, and how many y scales they use: one when fixed, one per panel
# (or per row) when free. Read from the built plot's layout.
panel_layout <- function(p) {
  ggplot_build(p)$layout$layout
}
shows_n <- function(p) {
  b <- ggplot_build(p)
  facet_values <- b$layout$layout %>%
    select(-any_of(c("PANEL", "ROW", "COL", "SCALE_X", "SCALE_Y",
                     "COORD"))) %>%
    unlist() %>%
    as.character()
  layer_labels <- unlist(map(b$data, function(d) as.character(d$label)))
  any(grepl("n\\s*=\\s*[0-9]", c(facet_values, layer_labels)))
}
todo_facets <- function(fixed, free, choice, reason, prefix) {
  out <- c(todo_plot(fixed, paste0(prefix, "_fixed")),
           todo_plot(free, paste0(prefix, "_free")))
  if (length(out) == 0) {
    fixed_layout <- panel_layout(fixed)
    free_layout <- panel_layout(free)
    if (nrow(fixed_layout) < 2 || nrow(free_layout) < 2) {
      out <- c(out, paste0("facet both plots by a second column with ",
                           "2 or more values (more than one panel)."))
    } else {
      if (n_distinct(fixed_layout$SCALE_Y) > 1) {
        out <- c(out, paste0(prefix, "_fixed: keep the y-axis the same ",
                             "in every panel (no scales = ...)."))
      }
      if (n_distinct(free_layout$SCALE_Y) < 2) {
        out <- c(out, paste0(prefix, "_free: add scales = \"free_y\" ",
                             "to facet_wrap()."))
      }
      if (!shows_n(fixed)) {
        out <- c(out, paste0("show each panel's n in its label, e.g. ",
                             "\"Group (n = 1,234)\"."))
      }
    }
  }
  if (!isTRUE(choice %in% c("fixed", "free_y"))) {
    out <- c(out, paste0("set ", prefix, "_choice to \"fixed\" or ",
                         "\"free_y\"."))
  }
  c(out, todo_reason(reason, paste0(prefix, "_reason")))
}
# The clouds: panels by kind, the same axes in both, exactly two groups
count_groups <- function(p) {
  s <- layer_scales(p)
  discrete <- keep(list(s$x, s$y), function(sc) {
    inherits(sc, "ScaleDiscrete")
  })
  if (length(discrete) > 0) {
    limits <- discrete[[1]]$get_limits()
    return(sum(!is.na(limits)))
  }
  if ("group" %in% names(p$data)) n_distinct(p$data$group, na.rm = TRUE) else 0
}
todo_clouds <- function(p, name) {
  if (!inherits(p, "ggplot")) return(character(0))
  out <- character(0)
  if (!("kind" %in% p$facet$vars())) {
    out <- c(out, paste0("make one panel per kind: facet_wrap(~ kind) on ",
                         "the result of make_clouds()."))
  } else {
    layout <- panel_layout(p)
    if (n_distinct(layout$SCALE_X) > 1 || n_distinct(layout$SCALE_Y) > 1) {
      out <- c(out, paste0(name, ": keep the same axes in both panels (no ",
                           "scales = ...): the means are compared to the ",
                           "individual values."))
    }
  }
  groups <- count_groups(p)
  if (groups != 2) {
    out <- c(out, paste0(name, " shows ", groups, " groups: keep exactly ",
                         "two, e.g. filter(group %in% c(\"...\", \"...\")) ",
                         "before make_clouds(), and put them on x."))
  }
  out
}
all_mappings <- function(p) {
  maps <- c(list(p$mapping), map(p$layers, function(l) l$mapping))
  out <- list()
  for (m in maps) {
    for (a in names(m)) out[[a]] <- c(out[[a]], rlang::as_label(m[[a]]))
  }
  out
}
todo_colors <- function(p, name) {
  if (!inherits(p, "ggplot")) return(character(0))
  colors <- plotted_colors(p)
  scales_used <- ggplot_build(p)$plot$scales
  n_categories <- sum(map_dbl(color_aes, function(a) {
    sc <- scales_used$get_scales(a)
    if (!is.null(sc) && inherits(sc, "ScaleDiscrete")) {
      mapped <- sc$map(sc$get_limits())
      mapped[is.na(mapped)] <- sc$na.value
      sum(!is.na(mapped))
    } else {
      0
    }
  }))
  if (n_categories < 2) {
    return(paste0("map a column with a few categories (2 to 4) to color ",
                  "or fill in ", name, "."))
  }
  maps <- all_mappings(p)
  color_columns <- unique(unlist(maps[color_aes]))
  if (length(colors) < 2 ||
      (length(colors) < n_categories && n_distinct(color_columns) == 1)) {
    return("two or more categories share a color: give each its own.")
  }
  out <- character(0)
  smallest <- map_dbl(cvd_matrices, function(m) {
    min_delta_e(colors, m)
  })
  if (any(smallest < 20)) {
    out <- c(out, paste0("color_check(", name, ") is below 20: choose a ",
                         "column with fewer categories, group rare ones ",
                         "with care (keep small groups visible and say so), ",
                         "or use panels."))
  }
  geoms <- map_chr(p$layers, function(l) class(l$geom)[1])
  has_labels <- any(geoms %in% c("GeomText", "GeomLabel"))
  has_panels <- !inherits(p$facet, "FacetNull")
  on_axis <- any(color_columns %in% c(maps$x, maps$y))
  if (!(has_labels || has_panels || on_axis)) {
    out <- c(out, paste0("color is never the only cue: add direct labels ",
                         "(geom_text() or geom_label()), panels, or put the ",
                         "same column on x or y."))
  }
  out
}

## ---- data ----
put_in_place("fairness.csv")
put_in_place("sports.csv")

fairness <- read_csv("data/fairness.csv", show_col_types = FALSE)
sports <- read_csv("data/sports.csv", show_col_types = FALSE)

if (looks_damaged(fairness) || looks_damaged(sports)) {
  stop("One of your data files looks damaged (each row in one column): it ",
       "may have been re-saved by a spreadsheet app. Ask your instructor ",
       "for a fresh copy.", call. = FALSE)
}

# Your columns ("values" = how many different values: 2 to 4 suits
# task 5). Never put a column of people's names in a plot.
show_columns(fairness)
show_columns(sports)


# PART A · FAIRNESS ==========================================================

# A0 · See it update ---------------------------------------------------------
# A ready count plot of one of your Fairness columns. Nothing to code.
# YOUR TURN (kickoff): change one word in the title, then render the report
# and the slides, and find your word on both pages.
## ---- a0 ----
a0_column <- pick_a_column(fairness)

a0 <- ggplot(fairness, aes(y = .data[[a0_column]])) +
  geom_bar() +
  labs(title = "My Fairness plot", x = "Count", y = a0_column)

show_plot(a0)

## ---- a0-check ----
# Check (don't change): prints a reminder.
checks[["A0"]] <- "see the reminder"
message("A0: Change the title, render the report and the slides, and look ",
        "for it on both pages.")


# A1 · Label it -----------------------------------------------------------
# Session 1: can a reader understand this plot without you there?
# YOUR TURN 1: open scripts/gp12_stats_coords.R (Files pane, scripts/).
#   Copy your A0 lines (a_data <- ...) over the a_data lines below. Then
#   copy your A1 plot (a1 <- ggplot(...) ...) over "a1_base <- NULL" and
#   rename it a1_base.
# YOUR TURN 2: replace each ___ in labs(): a title that states what the
#   plot shows, a subtitle (the data and its n), axis titles with units,
#   and a legend title. A rate is a share: percent labels on its axis. Your
#   Module 12 A1 has the rate on x; if yours has it on y, use
#   scale_y_continuous(labels = scales::percent).
## ---- a1 ----
a_data <- fairness %>%
  mutate(
    group = "replace me",
    has_outcome = FALSE
  )

a1_base <- NULL

a1 <- a1_base +
  labs(
    title = "___",
    subtitle = "___",
    x = "___",
    y = "___",
    fill = "___"
  ) +
  scale_x_continuous(labels = scales::percent)

show_plot(a1)

## ---- a1-check ----
# Check (don't change): prints PASS or TO DO with a hint.
check("A1", c(
  todo_plot(a1_base, "a1_base (your Module 12 A1 plot)"),
  todo_labels(a1, "a1", names(a_data)),
  todo_percent(a1, "a1")
))


# A2 · Choose a scale --------------------------------------------------------
# Session 1: which scale fits the data? Pick one of your numeric columns:
# - skewed (most values small, a few very large): scale_x_log10() on a
#   histogram, or scale_y_log10() on a scatter plot;
# - a share (0 to 1): percent labels, labels = scales::percent.
# A log scale can't show 0 or negative values: ggplot2 drops them. If the
# check finds any, keep only the values above 0 first and say so in your
# report.
## ---- a2 ----
a2 <- NULL
# YOUR TURN: remove the # signs below, then replace each ___.
# a2 <- fairness %>%
#   filter(___ > 0) %>%
#   ggplot(aes(x = ___)) +
#   geom_histogram(bins = 30) +
#   scale_x_log10(labels = scales::comma) +
#   labs(title = "___", x = "___ (units, log scale)", y = "Count")

# YOUR TURN: one sentence. Why this scale for this column?
a2_reason <- "___"

show_plot(a2)

## ---- a2-check ----
# Check (don't change): prints PASS or TO DO with a hint.
check("A2", c(
  todo_plot(a2, "a2"),
  todo_scale(a2, "a2"),
  todo_reason(a2_reason, "a2_reason")
))


# A3 · Facet it: fixed or free ------------------------------------------------
# Session 2: one plot or many? Your A1 rates, one panel per value of a
# second column (a sensitive attribute or another group), with each
# panel's n in its label.
# How a rate and its n are made (Module 12): group_by() the groups, then
# summarize(n = n(), rate = mean(has_outcome)).
# Many groups and the labels overlap? Stack the panels,
# facet_wrap(vars(panel), ncol = 1), and wrap the labels,
# scale_x_discrete(labels = scales::label_wrap(10)). Panel labels cut off?
# Add labeller = label_wrap_gen(20) inside facet_wrap().
## ---- a3 ----
# YOUR TURN 1: replace "replace me" with your second column (no quotes).
a3_rates <- a_data %>%
  mutate(panel = "replace me") %>%
  drop_na(has_outcome) %>%
  add_count(panel, name = "panel_n") %>%
  mutate(panel = paste0(panel, " (n = ", scales::comma(panel_n), ")")) %>%
  group_by(panel, group) %>%
  summarize(n = n(), rate = mean(has_outcome), .groups = "drop")

a3_fixed <- NULL
a3_free <- NULL
# YOUR TURN 2: remove the # signs below, then replace each ___.
# a3_fixed <- ggplot(a3_rates, aes(x = group, y = rate)) +
#   geom_col() +
#   facet_wrap(vars(panel)) +
#   scale_y_continuous(labels = scales::percent) +
#   labs(title = "___", x = "___", y = "___ (%)")
# a3_free <- a3_fixed +
#   facet_wrap(vars(panel), scales = "free_y")

# YOUR TURN 3: which one would you publish, "fixed" or "free_y"? Why?
a3_choice <- "___"
a3_reason <- "___"

show_plot(a3_fixed)
show_plot(a3_free)

## ---- a3-chosen ----
# The version you chose (a3_choice). Your slides show this one.
a3 <- if (identical(a3_choice, "free_y")) a3_free else a3_fixed
show_plot(a3)

## ---- a3-check ----
# Check (don't change): prints PASS or TO DO with a hint.
check("A3", todo_facets(a3_fixed, a3_free, a3_choice, a3_reason, "a3"))


# A4 · Compared to what? ------------------------------------------------------
# Session 2: is a difference between two groups large or small? Compared to
# what? The left panel shows each group's individual values; the right one,
# 200 resampled means: how far the group mean could move with a new sample.
# The same y-axis in both panels, so you can compare them.
# make_clouds(data, group, value) (prepared in Section 0) does the
# resampling. It returns three columns: group, value, and kind
# ("Individual values" or "Resampled means").
# Choose a numeric column (e.g. hours per week, age, number of
# medications), not the yes/no outcome, and two groups.
# geom_jitter(width = 0.15, height = 0) spreads the points sideways only,
# so every value stays at its true height.
## ---- a4 ----
a4_clouds <- NULL
# YOUR TURN 1: remove the # signs below, then replace each ___: the column
# with your groups, two of its values, and your numeric column.
# a4_clouds <- a_data %>%
#   filter(___ %in% c("___", "___")) %>%
#   make_clouds(___, ___)

a4 <- NULL
# YOUR TURN 2: remove the # signs below, then replace each ___.
# a4 <- ggplot(a4_clouds, aes(x = group, y = value)) +
#   geom_jitter(width = 0.15, height = 0, alpha = 0.2) +
#   facet_wrap(~ kind) +
#   labs(title = "___", x = "___", y = "___ (units)")

show_plot(a4)

## ---- a4-check ----
# Check (don't change): prints PASS or TO DO with a hint.
check("A4", c(todo_plot(a4, "a4"), todo_clouds(a4, "a4")))


# A5 · Color for every reader --------------------------------------------------
# Session 1: can everyone read the colors? Four steps:
# 1. Map a column with few categories (2 to 4) to color or fill.
# 2. Use scale_fill_viridis_d(end = 0.8) (or scale_color_viridis_d()).
# 3. Run color_check(a5): at least 20 in all three rows. Then look:
#    simulate_plot(a5) redraws your plot in the simulated colors.
# 4. Never color alone: add a second cue. Direct labels (geom_text() or
#    geom_label()), panels (facet_wrap()), or the same column on x or y.
# Too many categories? Choose another column, or group rare ones with care:
# fct_lump_n(column, n = 3) keeps the 3 largest and puts the rest in
# "Other". Keep small groups visible (their own panel, or their n), and say
# in your report what you combined.
## ---- a5 ----
a5 <- NULL
# YOUR TURN: remove the # signs below, then replace each ___ (the same
# column in both places, so its name is on the axis too).
# a5 <- ggplot(a_data, aes(y = ___, fill = ___)) +
#   geom_bar() +
#   scale_fill_viridis_d(end = 0.8) +
#   labs(title = "___", x = "Count", y = "___", fill = "___")

show_plot(a5)

## ---- a5-colors ----
color_check(a5)

## ---- a5-simulated ----
# See it: your plot as a reader with red-green color blindness might see it.
show_plot(simulate_plot(a5, "Red-green (deuteranopia)"))

## ---- a5-other-views ----
show_plot(simulate_plot(a5, "Red-green (protanopia)"))
show_plot(simulate_plot(a5, "Blue-yellow (approximate)"))

## ---- a5-check ----
# Check (don't change): prints PASS or TO DO with a hint.
check("A5", c(todo_plot(a5, "a5"), todo_colors(a5, "a5")))


# PART B · SPORTS ============================================================
# The same five ideas, with less help. Use Part A as your model.

# B1 · Label it ---------------------------------------------------------------
# YOUR TURN: copy your Module 12 B0 lines (b_data <- ...) over the b_data
# lines below. Then make b1_base: your Module 12 B1 plot or another Sports
# plot of your choice. Then fill in labs(), as in A1.
## ---- b1 ----
b_data <- sports %>%
  mutate(
    group = "replace me",
    has_outcome = FALSE,
    value = NA_real_
  )

b1_base <- NULL

b1 <- b1_base +
  labs(
    title = "___",
    subtitle = "___",
    x = "___",
    y = "___"
  )

show_plot(b1)

## ---- b1-check ----
# Check (don't change): prints PASS or TO DO with a hint.
check("B1", c(
  todo_plot(b1_base, "b1_base (your Module 12 B1 plot, or another)"),
  todo_labels(b1, "b1", names(b_data))
))


# B2 · Choose a scale ----------------------------------------------------------
# YOUR TURN: as in A2, with a Sports column: a log scale for a skewed
# column, or percent labels for a share. Then one sentence: why?
## ---- b2 ----
b2 <- NULL

b2_reason <- "___"

show_plot(b2)

## ---- b2-check ----
# Check (don't change): prints PASS or TO DO with a hint.
check("B2", c(
  todo_plot(b2, "b2"),
  todo_scale(b2, "b2"),
  todo_reason(b2_reason, "b2_reason")
))


# B3 · Facet it: fixed or free ------------------------------------------------
# YOUR TURN: as in A3, one panel per group or per year, each panel's n in
# its label. Make b3_fixed and b3_free, then choose.
# A year from a date column: year(date_column) (lubridate, loaded with the
# tidyverse). From text or a number such as 20190114:
# str_sub(column, 1, 4).
## ---- b3 ----
b3_fixed <- NULL
b3_free <- NULL

b3_choice <- "___"
b3_reason <- "___"

show_plot(b3_fixed)
show_plot(b3_free)

## ---- b3-check ----
# Check (don't change): prints PASS or TO DO with a hint.
check("B3", todo_facets(b3_fixed, b3_free, b3_choice, b3_reason, "b3"))


# B4 · Compared to what? ------------------------------------------------------
# YOUR TURN: as in A4, with a Sports numeric column (your value column, or
# another) and two groups. Make b4_clouds with make_clouds(), then b4.
## ---- b4 ----
b4_clouds <- NULL
b4 <- NULL

show_plot(b4)

## ---- b4-check ----
# Check (don't change): prints PASS or TO DO with a hint.
check("B4", c(todo_plot(b4, "b4"), todo_clouds(b4, "b4")))


# B5 · Color for every reader --------------------------------------------------
# YOUR TURN: as in A5, with a Sports column of 2 to 4 categories (or one
# you make, e.g. with fct_lump_n() or if_else()). Run color_check(b5).
## ---- b5 ----
b5 <- NULL

show_plot(b5)

## ---- b5-colors ----
color_check(b5)

## ---- b5-simulated ----
show_plot(simulate_plot(b5, "Red-green (deuteranopia)"))

## ---- b5-other-views ----
show_plot(simulate_plot(b5, "Red-green (protanopia)"))
show_plot(simulate_plot(b5, "Blue-yellow (approximate)"))

## ---- b5-check ----
# Check (don't change): prints PASS or TO DO with a hint.
check("B5", c(todo_plot(b5, "b5"), todo_colors(b5, "b5")))


# Checks summary (the report prints this table) -------------------------------
## ---- checks-table ----
checks_table <- tibble(
  task = names(checks),
  status = unlist(checks)
)
checks_table
