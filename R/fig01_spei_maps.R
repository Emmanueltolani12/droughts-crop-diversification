# -----------------------------------------------------------------------------
# fig01_spei_maps.R
# Figure 1. Short and long term SPEI in Zambia.
#   Panel A: 6-month SPEI, Panel B: 12-month SPEI, for April 2011, 2014 and
#   2018 (the season before each survey wave), by district (admin level 2).
# Inputs:  data/SPEI6_Admin2_Zambia_2011_2014_2018.xlsx
#          data/SPEI12_Admin2_Zambia_2011_2014_2018.xlsx
#          data/shapefiles/zmb_admbnda_adm2_dmmu_20201124.shp
# Outputs: figures/fig01_panelA_spei6.png/.pdf, figures/fig01_panelB_spei12.png/.pdf
# -----------------------------------------------------------------------------

source("R/00_setup.R")

zambia_admin2 <- st_read(file.path(dir_data, "shapefiles", "zmb_admbnda_adm2_dmmu_20201124.shp"),
                         quiet = TRUE)

spei_map <- function(xlsx, legend_title) {
  spei <- read_excel(file.path(dir_data, xlsx)) |>
    select(ADM2_EN, `2011` = X2011.04.01, `2014` = X2014.04.01, `2018` = X2018.04.01)

  spei_long <- left_join(zambia_admin2, spei, by = "ADM2_EN") |>
    pivot_longer(cols = c(`2011`, `2014`, `2018`), names_to = "Year", values_to = "SPEI") |>
    mutate(Year = as.numeric(Year))

  ggplot(spei_long) +
    geom_sf(aes(fill = SPEI), colour = "white") +
    facet_wrap(~Year) +
    scale_fill_gradient2(low = "#00563B", mid = "#F0FFF0", high = "green", midpoint = 0,
                         space = "Lab", na.value = "grey50", guide = "colourbar") +
    theme_minimal() +
    theme(
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks = element_blank(),
      axis.title.x = element_blank(),
      axis.title.y = element_blank()
    ) +
    labs(title = " ", fill = legend_title)
}

fig1a <- spei_map("SPEI6_Admin2_Zambia_2011_2014_2018.xlsx", "SPEI 6 Values")
fig1b <- spei_map("SPEI12_Admin2_Zambia_2011_2014_2018.xlsx", "SPEI 12 Values")

for (f in list(list(fig1a, "fig01_panelA_spei6"), list(fig1b, "fig01_panelB_spei12"))) {
  ggsave(file.path(dir_figures, paste0(f[[2]], ".png")), f[[1]],
         width = 10, height = 4, units = "in", dpi = 300, bg = "white")
  ggsave(file.path(dir_figures, paste0(f[[2]], ".pdf")), f[[1]],
         width = 10, height = 4, units = "in", device = cairo_pdf, bg = "white")
  message("Saved ", f[[2]])
}
