## AI Usage Log

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
