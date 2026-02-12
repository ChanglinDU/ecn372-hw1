## AI Usage Log

### 2026-02-11 — Figure 1: Health and wealth across countries (2007)
- Tool: Cursor Agent (chat)
- Prompt: "Write an R script to reproduce the Gapminder 2007 'Health and wealth across countries' plot (log GDP per capita, life expectancy, point area = population, continent colors, overall + within-continent fitted lines), and save as a PDF to output/."
- Output summary: Provided a full R script using gapminder + ggplot2 that filters to 2007, plots lifeExp vs gdpPercap (log scale), scales point area by population, colors by continent, adds overall and per-continent linear trend lines, adds dashed reference lines, and saves a PDF into `output/`.
- What I used:
  - `scripts/01_make_figures.R`: pasted the generated script to build the Figure 1 plot and save `output/figure-1.pdf`
  - Used project-relative paths (no `/Users/...`) and `dir.create("output", ...)` to ensure the folder exists
- Verification: Ran `Rscript scripts/01_make_figures.R` and confirmed `output/figure-1.pdf` was created and matched the reference.

### 2026-02-11 — Figure 2: Life expectancy gains (1952 … 2007)
- Tool: Cursor Agent (chat)
- Prompt: "Write an R script to reproduce the 'Life expectancy gains (1952 … 2007)' dumbbell chart: top 3 countries per continent by life expectancy increase; show 1952 and 2007 points, connect with a line, and label years gained; save to output/ as a PDF."
- Output summary: Provided a full R script that pivots gapminder to wide (1952 vs 2007), computes gains, selects top 3 per continent, reshapes to long for plotting, draws dumbbell segments and points colored by year, adds gain labels at 2007, facets by continent, and saves a PDF.
- What I used:
  - `scripts/02_make_figures.R`: pasted the generated script to build the Figure 2 plot and save `output/figure-2.pdf`
  - Updated facet settings to place continent labels on the **left** using `facet_grid(..., switch = "y")` and `strip.placement = "outside"`
- Verification: Ran `Rscript scripts/02_make_figures.R` and confirmed `output/figure-2.pdf` was created and matched the reference (including continent labels on the left).

### 2026-02-11 — Repo organization: Fix nested scripts folder
- Tool: Cursor Chat
- Prompt: "I accidentally created scripts/scripts. How do I move 02_make_figures.R out so both scripts are directly under scripts/ ?"
- Output summary: Suggested using drag-and-drop in the file explorer or terminal commands (`mv` then `rmdir`) to move scripts up one level and delete the extra folder.
- What I used:
  - Moved `scripts/scripts/02_make_figures.R` → `scripts/02_make_figures.R`
  - Removed the empty `scripts/scripts/` directory
- Verification: Confirmed the repo tree shows only one `scripts/` folder and re-ran both scripts successfully.

### 2026-02-11 — Figure 1: Health and wealth across countries (2007)
- Tool: Cursor Agent (chat)
- Prompt: "for scripts: @scripts/01_make_figures.R and @scripts/02_make_figures.R Please split them into three files: 00_setup.R # optional: setup helpers, 01_data_prep.R # optional: cleaning/summaries, 02_make_figures.R # required: produces your two output files"
- Output summary: Refactor the original figure scripts into a 3-file pipeline: (1) shared library/setup helpers, (2) data prep functions for each figure, (3) a single make-figures script that sources the first two and writes the PDFs to `output/`.
- What I used: Implemented the pipeline and moved the Figure 1 logic into it:
  - `scripts/00_setup.R`: centralized package loads and added helpers `ensure_dir()` and `save_pdf()`
  - `scripts/01_data_prep.R`: added `prep_fig1_data()` to filter 2007 data and compute medians/breaks
  - `scripts/02_make_figures.R`: builds the Figure 1 ggplot and saves `output/figure-1.pdf`
  - Removed the old `scripts/01_make_figures.R` after migration
- Verification: Ran `Rscript scripts/02_make_figures.R` and confirmed `output/figure-1.pdf` was created.

### 2026-02-11 — Figure 2: Life expectancy gains (1952 ... 2007)
- Tool: Cursor Agent (chat)
- Prompt: "for scripts: @scripts/01_make_figures.R and @scripts/02_make_figures.R Please split them into three files: 00_setup.R # optional: setup helpers, 01_data_prep.R # optional: cleaning/summaries, 02_make_figures.R # required: produces your two output files"
- Output summary: Extract the Figure 2 reshaping/top-3 selection into a data-prep function and generate the dumbbell chart from the unified make-figures script, saving `output/figure-2.pdf`.
- What I used: Implemented Figure 2 inside the same pipeline:
  - `scripts/01_data_prep.R`: added `prep_fig2_data()` that returns `plot_df`, `seg_df`, and `lab_df`
  - `scripts/02_make_figures.R`: builds the Figure 2 dumbbell chart and saves `output/figure-2.pdf`
  - Updated `scripts/02_make_figures.R` project-root detection so outputs go to the repo-level `output/` even when run from different working directories
- Verification: Ran both:
  - `Rscript scripts/02_make_figures.R` (from repo root) and confirmed `output/figure-2.pdf` exists
  - `Rscript 02_make_figures.R` (from `scripts/`) and confirmed `../output/figure-2.pdf` exists
