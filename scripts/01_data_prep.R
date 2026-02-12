# scripts/01_data_prep.R
# Purpose:
# - All data prep (filtering, reshaping, summary stats) lives here.
# - Plot scripts stay focused on plotting, not wrangling.
# - This file is sourced by `scripts/02_make_figures.R`.

# Prepare inputs for Figure 1 (Health and wealth across countries, 2007).
# Returns a named list used by the plotting code:
# - df: 2007 gapminder observations
# - x_ref: median GDP per capita in 2007 (for vertical dashed reference line)
# - y_ref: median life expectancy in 2007 (for horizontal dashed reference line)
# - pop_breaks: population legend breakpoints (match style of the reference figure)
prep_fig1_data <- function() {
  # Filter down to the cross-section year shown in the figure.
  df <- gapminder %>% filter(year == 2007)

  list(
    df = df,
    # Reference lines to help interpret “high/low” quadrants.
    x_ref = median(df$gdpPercap, na.rm = TRUE),
    y_ref = median(df$lifeExp, na.rm = TRUE),
    # Pre-chosen legend breaks for a clean, interpretable size scale.
    pop_breaks = c(1e6, 1e7, 1e8, 1e9)
  )
}

# Prepare inputs for Figure 2 (Life expectancy gains, 1952 vs 2007).
# Steps:
# 1) Wide reshape to get lifeExp in 1952 and 2007 on the same row.
# 2) Compute gain = (2007 - 1952).
# 3) Select top 3 gainers per continent.
# 4) Create three small tables for plotting: points, segments, and gain labels.
# Returns a named list:
# - plot_df: long-format points (two points per country, one per year)
# - seg_df: segment endpoints (1952 to 2007 per country)
# - lab_df: text labels placed at the 2007 point showing +gain
prep_fig2_data <- function() {
  # Build wide table: lifeExp in 1952 and 2007, plus gain
  wide <- gapminder %>%
    filter(year %in% c(1952, 2007)) %>%
    select(country, continent, year, lifeExp) %>%
    pivot_wider(names_from = year, values_from = lifeExp, names_prefix = "y") %>%
    mutate(gain = y2007 - y1952)

  # Select top 3 per continent by gain (Oceania will naturally have fewer)
  top <- wide %>%
    group_by(continent) %>%
    slice_max(order_by = gain, n = 3, with_ties = FALSE) %>%
    ungroup()

  # Order countries within each continent for display
  # (arrange within each facet, then preserve that ordering as a factor)
  top <- top %>%
    group_by(continent) %>%
    arrange(gain, .by_group = TRUE) %>%
    ungroup() %>%
    mutate(country = fct_rev(fct_inorder(country)))

  # Long format for points
  # We want one row per (country, year) so ggplot can map year -> color.
  plot_df <- top %>%
    select(country, continent, y1952, y2007, gain) %>%
    pivot_longer(
      cols = c(y1952, y2007),
      names_to = "year",
      values_to = "lifeExp"
    ) %>%
    mutate(
      # Rename y1952/y2007 to "1952"/"2007" for legend readability.
      year = recode(year, y1952 = "1952", y2007 = "2007"),
      # Keep year order consistent (1952 first, then 2007).
      year = factor(year, levels = c("1952", "2007"))
    )

  # Segment data (connecting lines)
  # One row per country; used by geom_segment to connect 1952->2007.
  seg_df <- top %>%
    transmute(continent, country, x1952 = y1952, x2007 = y2007)

  # Label data (gain labels at 2007 point)
  # Place the “+X.Y” label at x = lifeExp_2007 for each country.
  lab_df <- top %>%
    transmute(
      continent,
      country,
      x = y2007,
      label = paste0("+", format(round(gain, 1), nsmall = 1))
    )

  list(plot_df = plot_df, seg_df = seg_df, lab_df = lab_df)
}

