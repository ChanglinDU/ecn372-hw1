# scripts/02_make_figures.R
# Required: produces BOTH output files
# - output/figure-1.pdf (Health and wealth across countries, 2007)
# - output/figure-2.pdf (Life expectancy gains, 1952 ... 2007)
# How to run:
# - From the repo root:   Rscript scripts/02_make_figures.R
# - From the scripts dir: Rscript 02_make_figures.R
# This script is written to be robust to the current working directory by:
# - finding the project root
# - sourcing `scripts/00_setup.R` + `scripts/01_data_prep.R` using absolute paths
# - writing outputs to <project-root>/output/

# Helper: when executed with `Rscript path/to/script.R`, R exposes the script path
# via a `--file=` command argument. We use that to locate the scripts folder.
get_script_dir <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg) == 0) return(NULL)
  script_path <- sub("^--file=", "", file_arg[1])
  dirname(normalizePath(script_path))
}

# Helper: find the project root directory by walking upward from a start directory.
# We stop when we see either:
# - a `.git` directory (typical repo marker), OR
# - both `scripts/` and a marker file like `AI_USAGE.md` or `README.md`
# This prevents outputs from ending up in the wrong place when `getwd()` differs.
find_project_root <- function(start_dir = getwd(), max_up = 10) {
  d <- normalizePath(start_dir)
  for (i in 0:max_up) {
    has_git <- dir.exists(file.path(d, ".git"))
    has_scripts <- dir.exists(file.path(d, "scripts"))
    has_markers <- file.exists(file.path(d, "AI_USAGE.md")) || file.exists(file.path(d, "README.md"))
    if (has_git || (has_scripts && has_markers)) return(d)
    parent <- dirname(d)
    if (parent == d) break
    d <- parent
  }
  normalizePath(start_dir)
}

script_dir <- get_script_dir()
if (!is.null(script_dir)) {
  # If run as `Rscript scripts/02_make_figures.R`, we can reliably treat the
  # parent of the scripts directory as the project root.
  root_dir <- normalizePath(file.path(script_dir, ".."))
} else {
  # If sourced / run without `--file=` info, fall back to searching upward
  # from the current working directory.
  root_dir <- find_project_root(getwd())
}

# Source shared setup + data prep using project-root-relative paths.
setup_path <- file.path(root_dir, "scripts", "00_setup.R")
prep_path <- file.path(root_dir, "scripts", "01_data_prep.R")

source(setup_path)
source(prep_path)

# Output directory is always the repo-level `output/`.
output_dir <- file.path(root_dir, "output")
ensure_dir(output_dir)

## Figure 1 --------------------------------------------------------------------
# Recreate: "Health and wealth across countries (2007)"
# - points: area ~ population
# - colors: continent
# - lines: fitted trends (overall + within continent)
# - x-axis: GDP per person (log scale) with $ labels
fig1 <- prep_fig1_data()
df <- fig1$df
x_ref <- fig1$x_ref
y_ref <- fig1$y_ref
pop_breaks <- fig1$pop_breaks

p1 <- ggplot(df, aes(x = gdpPercap, y = lifeExp)) +
  # points (size is area-based via scale_size_area)
  geom_point(aes(size = pop, color = continent), alpha = 0.85) +
  # within-continent fitted lines
  geom_smooth(aes(color = continent), method = "lm", se = FALSE, linewidth = 0.9) +
  # overall fitted line (black)
  geom_smooth(method = "lm", se = FALSE, color = "black", linewidth = 1.1) +
  # dashed reference lines
  geom_vline(xintercept = x_ref, linetype = "dashed", color = "grey55", linewidth = 0.6) +
  geom_hline(yintercept = y_ref, linetype = "dashed", color = "grey55", linewidth = 0.6) +
  # log x-axis with dollar formatting
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
  labs(
    title = "Health and wealth across countries (2007)",
    subtitle = "Point area ... population; lines are fitted trends (overall + within continent)",
    x = "GDP per person (log scale)",
    y = "Life expectancy (years)",
    caption = "Data: gapminder package",
    color = NULL
  ) +
  theme_minimal(base_size = 13) +
  theme(
    # Match a clean “publication-like” layout (legend on top, minimal grid).
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
    # Slightly enlarge legend keys for readability.
    color = guide_legend(override.aes = list(size = 3)),
    size = guide_legend(title.position = "left")
  )

# Save the required deliverable PDF.
save_pdf(
  plot = p1,
  filename = file.path(output_dir, "figure-1.pdf"),
  width = 12.5,
  height = 7.2
)

## Figure 2 --------------------------------------------------------------------
# Recreate: "Life expectancy gains (1952 ... 2007)"
# - compute: gain = lifeExp_2007 - lifeExp_1952
# - select: top 3 countries per continent by gain
# - plot type: dumbbell chart (segment + two points)
# - annotate: label at 2007 point with "+<years gained>"
fig2 <- prep_fig2_data()
plot_df <- fig2$plot_df
seg_df <- fig2$seg_df
lab_df <- fig2$lab_df

p2 <- ggplot() +
  # Connecting segment from 1952 to 2007 for each country.
  geom_segment(
    data = seg_df,
    aes(x = x1952, xend = x2007, y = country, yend = country),
    color = "grey70",
    linewidth = 1.0
  ) +
  # Points for 1952 and 2007 (colored by year).
  geom_point(
    data = plot_df,
    aes(x = lifeExp, y = country, color = year),
    size = 3
  ) +
  # Gain labels printed slightly to the right of the 2007 point.
  geom_text(
    data = lab_df,
    aes(x = x, y = country, label = label),
    hjust = -0.15,
    size = 3.5
  ) +
  # switch = "y" moves the facet strip to the LEFT
  facet_grid(continent ~ ., scales = "free_y", space = "free_y", switch = "y") +
  scale_color_manual(values = c("1952" = "#2C7FB8", "2007" = "#D95F02")) +
  # Fixed x-axis range to match the reference style and prevent label clipping.
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
  # Allow text to extend past the plotting panel (needed for right-side gain labels).
  coord_cartesian(clip = "off")

# Save the required deliverable PDF.
save_pdf(
  plot = p2,
  filename = file.path(output_dir, "figure-2.pdf"),
  width = 12.5,
  height = 8.5
)
