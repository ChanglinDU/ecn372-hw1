# scripts/00_setup.R
# Purpose:
# - Centralize shared package imports and tiny helper utilities.
# - This file is sourced by `scripts/02_make_figures.R`.
# Notes:
# - Keeping all libraries here avoids repeating `library(...)` blocks across scripts.
# - Helpers are deliberately small and generic (directory creation + PDF saving).

suppressPackageStartupMessages({
  library(gapminder) # dataset used for both figures
  library(dplyr)     # data manipulation (filter/mutate/group_by/...)
  library(tidyr)     # reshaping (pivot_longer/pivot_wider)
  library(ggplot2)   # plotting
  library(scales)    # axis/legend formatting (dollar_format, comma_format)
  library(forcats)   # factor ordering helpers for Figure 2
  library(grid)      # for unit() used in ggplot theme settings
})

# Ensure a directory exists (no error if it already exists).
# Returns the path invisibly so it can be used in pipelines if desired.
ensure_dir <- function(path) {
  if (!dir.exists(path)) dir.create(path, recursive = TRUE)
  invisible(path)
}

# Wrapper around `ggsave()` with inches as the default unit.
# Inputs:
# - plot: ggplot object
# - filename: output path (e.g., "output/figure-1.pdf")
# - width/height: dimensions in inches
# - ...: forwarded to ggsave (e.g., dpi, device)
save_pdf <- function(plot, filename, width, height, ...) {
  ggsave(
    filename = filename,
    plot = plot,
    width = width,
    height = height,
    units = "in",
    ...
  )
}

