# -----------------------------------------------------------------------------
# 01_run_all_figures.R
# Draws Figures 1-4 and 6 (Figure 5 is drawn in Stata, 05_robustness.do).
# Called by 00_run_all.do with the package folder as its argument; it can also
# be run on its own from the package folder:
#   Rscript --vanilla R/01_run_all_figures.R
# -----------------------------------------------------------------------------

args <- commandArgs(trailingOnly = TRUE)
if (length(args) >= 1) setwd(args[1])

cat(R.version.string, "\n")

for (f in c("R/fig01_spei_maps.R", "R/fig02_04_06_coefficients.R")) {
  cat("Running", f, "\n")
  source(f, echo = FALSE)
}

for (p in c("ggplot2", "dplyr", "tidyr", "readr", "readxl", "sf", "ggthemes", "ggtext", "patchwork")) {
  cat(sprintf("%-10s %s\n", p, as.character(packageVersion(p))))
}

# Marker for 00_run_all.do: the figures are done
writeLines(format(Sys.time()), file.path("logs", "01_run_all_figures.done"))
