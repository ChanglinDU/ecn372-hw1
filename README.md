# ecn372-hw1

## Repo structure

- **`README.md`**: overview of the project, structure, and replication instructions
- **`scripts/`**: all code to prepare data and reproduce figures
  - **`00_setup.R`**: shared package imports + small helper functions (directory creation, saving PDFs)
  - **`01_data_prep.R`**: data prep functions used by the plotting script (filtering/reshaping/summaries)
  - **`02_make_figures.R`**: main entrypoint that generates both required outputs
- **`output/`**: generated deliverables
  - **`figure-1.pdf`**
  - **`figure-2.pdf`**
- **`AI_USAGE.md`**: disclosure log of AI assistance (prompt, what was suggested, what was used, verification)

## Exact replication instructions

### 1) Install requirements (one-time)

You need **R** installed (and available as `Rscript`). Then install the required R packages:

```r
install.packages(c(
  "gapminder", "dplyr", "tidyr", "ggplot2", "scales", "forcats"
))
```

(`grid` is part of base R and does not need installation.)

### 2) Reproduce all outputs

From the repo root, run:

```bash
Rscript scripts/02_make_figures.R
```

This will create (or overwrite) the two PDFs in `output/`:

- `output/figure-1.pdf`
- `output/figure-2.pdf`

## Reverse‑engineering process (how the figures were replicated)

I started by reading the existing figure scripts and treating them like a “spec” for the visuals: which dataset/year is used, what each aesthetic mapping is (x/y variables, color and size mappings), what geoms appear (points, fitted lines, reference lines; and for the second figure, dumbbell segments + endpoints + text labels), and what non-default scales/themes are required (log-scaled GDP axis with dollar labels, population-scaled point area, and left-positioned facet strips).

Then I refactored the work into a reproducible pipeline while keeping the plot logic unchanged: shared libraries/helpers live in `scripts/00_setup.R`, all data wrangling and summary statistics are isolated in `scripts/01_data_prep.R`, and the single entrypoint `scripts/02_make_figures.R` sources both and writes the final PDFs to the top-level `output/` directory. This makes reproduction deterministic (one command) and keeps each step (setup, prep, plotting) easy to inspect and debug.