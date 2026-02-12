# scripts/01_make_figures.R
# Recreate: "Health and wealth across countries (2007)"
# - points: area ~ population
# - colors: continent
# - lines: fitted trends (overall + within continent)
# - x-axis: GDP per person (log scale) with $ labels
# - output: PDF in output/

suppressPackageStartupMessages({
  library(gapminder)
  library(dplyr)
  library(ggplot2)
  library(scales)
})

# Ensure output folder exists (project-relative path)
if (!dir.exists("output")) dir.create("output", recursive = TRUE)

# Data for 2007
df <- gapminder %>% filter(year == 2007)

# Reference lines (median GDP and median life expectancy in 2007)
x_ref <- median(df$gdpPercap, na.rm = TRUE)
y_ref <- median(df$lifeExp, na.rm = TRUE)

# Population legend breaks (match the figure's style)
pop_breaks <- c(1e6, 1e7, 1e8, 1e9)

p <- ggplot(df, aes(x = gdpPercap, y = lifeExp)) +
  # points (size is area-based via scale_size_area)
  geom_point(aes(size = pop, color = continent), alpha = 0.85) +

  # within-continent fitted lines
  geom_smooth(aes(color = continent), method = "lm", se = FALSE, linewidth = 0.9) +

  # overall fitted line (black)
  geom_smooth(method = "lm", se = FALSE, color = "black", linewidth = 1.1) +

  # dashed reference lines
  geom_vline(xintercept = x_ref, linetype = "dashed", color = "grey55", linewidth = 0.6) +
  geom_hline(yintercept = y_ref, linetype = "dashed", color = "grey55", linewidth = 0.6) +

  # log x-axis with dollar formatting (ticks similar to the screenshot)
  scale_x_log10(
    breaks = c(500, 1000, 2000, 5000, 10000, 20000, 50000),
    labels = dollar_format(accuracy = 1)
  ) +

  # size legend as area
  scale_size_area(
    name = "Population",
    breaks = pop_breaks,
    labels = comma_format(accuracy = 1),
    max_size = 18
  ) +

  # labels / title / subtitle / caption
  labs(
    title = "Health and wealth across countries (2007)",
    subtitle = "Point area ... population; lines are fitted trends (overall + within continent)",
    x = "GDP per person (log scale)",
    y = "Life expectancy (years)",
    caption = "Data: gapminder package",
    color = NULL
  ) +

  # theme to match the clean ggplot look
  theme_minimal(base_size = 13) +
  theme(
    legend.position = "top",
    legend.direction = "horizontal",
    legend.box = "vertical",
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold", size = 18),
    plot.subtitle = element_text(size = 12),
    axis.title.x = element_text(face = "bold", size = 14),
    axis.title.y = element_text(face = "bold", size = 14),
    plot.caption = element_text(hjust = 1),
    legend.title = element_text(face = "bold"),
    legend.text = element_text(size = 11)
  ) +
  guides(
    color = guide_legend(override.aes = list(size = 3)),
    size = guide_legend(title.position = "left")
  )

# Save to PDF (required deliverable)
ggsave(
  filename = "output/figure-1.pdf",
  plot = p,
  width = 12.5,
  height = 7.2,
  units = "in"
)
