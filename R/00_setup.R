# -----------------------------------------------------------------------------
# 00_setup.R
# Shared settings for the figures: packages, folders, and the coefficient plot
# used for Figures 2, 3, 4 and 6. Sourced by the fig*.R scripts.
# -----------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  library(readr)
  library(readxl)
  library(sf)
  library(ggthemes)
  library(ggtext)
  library(patchwork)
})

# Folders, relative to the package root (the R scripts are run from there)
dir_data    <- "data"
dir_plot    <- "plot_data"
dir_figures <- "figures"
dir.create(dir_figures, showWarnings = FALSE)

my_font <- "Arial"

# Estimates exported by the Stata do-files (one row per point or bar)
read_estimates <- function() {
  read_csv(file.path(dir_plot, "figure_estimates.csv"), show_col_types = FALSE) |>
    mutate(stars = coalesce(stars, ""),
           p.label = paste0(round(coef, 3), stars))
}

# Coefficient plot: point estimate (red square), 95% interval, the estimate
# with its stars as a label, one panel titled by `panel`. With bars = TRUE the
# estimate is also drawn as a coloured column (Figures 3 and 6).
plot_coefficients <- function(df, bars = FALSE) {
  p <- ggplot(df, aes(x = var_name, y = coef, fill = var_name))
  if (bars) p <- p + geom_col(position = "dodge", width = 0.5)
  p +
    geom_errorbar(aes(ymin = ci_low, ymax = ci_high),
                  position = position_dodge(0.4), width = 0.035, linewidth = 0.6) +
    geom_hline(yintercept = 0, linewidth = 0.3, colour = "grey") +
    geom_point(position = position_dodge(0.3), size = 3, shape = 15, colour = "#FF0000") +
    geom_text(aes(label = p.label), position = position_dodge(0.9),
              vjust = 0.5 * -1.5, hjust = -0.2, show.legend = FALSE,
              size = 4, family = my_font) +
    scale_fill_manual(values = c("#FEFFA7", "#B6FFA1", "#FFE700", "#00FF9C",
                                 "white", "white", "white", "white", "#ACE1AF")) +
    facet_wrap(~panel, scales = "free_y") +
    labs(y = "Estimates (95% Robust CI)", x = "") +
    ggthemes::theme_base() +
    theme(
      legend.position = "none",
      text = element_text(family = my_font, size = 14),
      panel.background = element_rect(fill = "white", colour = NA),
      strip.background = element_rect(fill = "white", colour = "black"),
      panel.border = element_rect(colour = "black", fill = NA),
      axis.text.x = ggtext::element_markdown(),
      strip.text = element_text(family = my_font, size = 14, colour = "#4D4D4D"),
      plot.background = element_rect(fill = "white", colour = "black")
    )
}

# Save a figure as PNG (300 dpi) and PDF
save_figure <- function(plot, name, width, height) {
  ggsave(file.path(dir_figures, paste0(name, ".png")), plot,
         width = width, height = height, units = "in", dpi = 300)
  ggsave(file.path(dir_figures, paste0(name, ".pdf")), plot,
         width = width, height = height, units = "in", device = cairo_pdf)
  message("Saved ", name)
}
