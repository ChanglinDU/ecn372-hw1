# scripts/02_make_figures.R
# Recreate: "Life expectancy gains (1952 ... 2007)"
# - compare: lifeExp in 1952 vs 2007 (gapminder)
# - compute: gain = lifeExp_2007 - lifeExp_1952
# - select: top 3 countries per continent by gain (Oceania may have fewer)
# - plot type: dumbbell chart (two points + connecting segment per country)
# - aesthetics:
#   * points colored by year (1952 vs 2007)
#   * grey line connects each country’s 1952 and 2007 values
#   * text label at 2007 point shows "+<years gained>"
# - layout: facet by continent with labels on the LEFT (like the reference)
# - output: PDF saved to output/figure-2.pdf (no manual editing)

suppressPackageStartupMessages({
  library(gapminder)
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(forcats)
  library(grid)   # for unit()
})

if (!dir.exists("output")) dir.create("output", recursive = TRUE)

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
top <- top %>%
  group_by(continent) %>%
  arrange(gain, .by_group = TRUE) %>%
  ungroup() %>%
  mutate(country = fct_rev(fct_inorder(country)))

# Long format for points
plot_df <- top %>%
  select(country, continent, y1952, y2007, gain) %>%
  pivot_longer(cols = c(y1952, y2007),
               names_to = "year",
               values_to = "lifeExp") %>%
  mutate(
    year = recode(year, y1952 = "1952", y2007 = "2007"),
    year = factor(year, levels = c("1952", "2007"))
  )

# Segment data (connecting lines)
seg_df <- top %>%
  transmute(continent, country, x1952 = y1952, x2007 = y2007)

# Label data (gain labels at 2007 point)
lab_df <- top %>%
  transmute(
    continent, country,
    x = y2007,
    label = paste0("+", format(round(gain, 1), nsmall = 1))
  )

p <- ggplot() +
  geom_segment(
    data = seg_df,
    aes(x = x1952, xend = x2007, y = country, yend = country),
    color = "grey70",
    linewidth = 1.0
  ) +
  geom_point(
    data = plot_df,
    aes(x = lifeExp, y = country, color = year),
    size = 3
  ) +
  geom_text(
    data = lab_df,
    aes(x = x, y = country, label = label),
    hjust = -0.15,
    size = 3.5
  ) +
  # switch = "y" moves the facet strip to the LEFT
  facet_grid(continent ~ ., scales = "free_y", space = "free_y", switch = "y") +
  scale_color_manual(values = c("1952" = "#2C7FB8", "2007" = "#D95F02")) +
  scale_x_continuous(limits = c(20, 90), breaks = seq(20, 90, by = 10)) +
  labs(
    title = "Life expectancy gains (1952 ... 2007)",
    subtitle = "Top 3 countries per continent by life expectancy increase; labels show years gained",
    x = "Life expectancy (years)",
    y = NULL,
    color = "Year",
    caption = "Data: gapminder package"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    legend.position = "top",
    panel.grid.minor = element_blank(),

    # Put facet labels on the LEFT and outside the panel
    strip.placement = "outside",
    strip.text.y.left = element_text(face = "bold", angle = 0),
    strip.background = element_blank(),
    strip.switch.pad.grid = unit(0.2, "cm"),

    plot.title = element_text(face = "bold", size = 18),
    plot.subtitle = element_text(size = 12),
    axis.title.x = element_text(face = "bold", size = 14),
    plot.caption = element_text(hjust = 1)
  ) +
  coord_cartesian(clip = "off")

ggsave(
  filename = "output/figure-2.pdf",
  plot = p,
  width = 12.5,
  height = 8.5,
  units = "in"
)
