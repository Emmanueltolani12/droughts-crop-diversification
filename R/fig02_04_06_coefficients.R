# -----------------------------------------------------------------------------
# fig02_04_06_coefficients.R
# Figure 2. Droughts and crop yields of some major crops (Table A2)
# Figure 3. Fixed effect estimates of the impact of droughts on climate-resilient
#           crop varieties (Table A4)
# Figure 4. Droughts and cropland expansion of some major crops (Table A6)
# Figure 6. Conley standard errors and bootstrapping approaches (Tables A12, A13)
# Input:  plot_data/figure_estimates.csv (written by the Stata do-files)
# Output: figures/fig02_crop_yields, fig03_resilient_seeds,
#         fig04_acreage_shares, fig06_standard_errors (.png and .pdf)
# -----------------------------------------------------------------------------

source("R/00_setup.R")

est <- read_estimates()

# Figure 2: estimates and 95% intervals
fig2 <- plot_coefficients(filter(est, figure == "fig02"))
save_figure(fig2, "fig02_crop_yields", width = 12, height = 10)

# Figure 3: with columns
fig3 <- plot_coefficients(filter(est, figure == "fig03"), bars = TRUE)
save_figure(fig3, "fig03_resilient_seeds", width = 12, height = 10)

# Figure 4: estimates and 95% intervals
fig4 <- plot_coefficients(filter(est, figure == "fig04"))
save_figure(fig4, "fig04_acreage_shares", width = 12, height = 10)

# Figure 6: Conley standard errors (left) and other approaches (right), with columns
fig6a <- plot_coefficients(filter(est, figure == "fig06"), bars = TRUE)
fig6b <- plot_coefficients(filter(est, figure == "fig06b"), bars = TRUE) + labs(y = "")
fig6 <- fig6a + fig6b
save_figure(fig6, "fig06_standard_errors", width = 12, height = 10)
