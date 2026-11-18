# Replication package

**Rolling back the tides: Impact of droughts on crop diversification and cropland expansion**
Martin Paul Jr. Tabe-Ojong, Emmanuel Tolani, Ernest L. Molua
*Journal of Environmental Economics and Management* 136 (2026) 103260. [https://doi.org/10.1016/j.jeem.2025.103260](https://doi.org/10.1016/j.jeem.2025.103260)

This package produces all tables and figures of the paper and of its supplementary material (Tables 1–7, Figures 1–6, Tables A1–A13) from the data. One command runs everything.

## Data availability

The analysis uses the Rural Agricultural Livelihoods Survey (RALS), a three-wave panel of smallholder farm households in Zambia (2012, 2015 and 2019), run by the Indaba Agricultural Policy Research Institute (IAPRI) with the Ministry of Agriculture and the Zambia Statistics Agency. Droughts are measured with the Standardized Precipitation Evapotranspiration Index (SPEI) from the SPEI Global Drought Monitor.

**The data are not included in this package.** The RALS is household-level microdata that cannot be redistributed, so the package holds the code only. To run it, save the files listed in [`data/README.md`](data/README.md) in the `data/` folder:

| File in `data/` | Content |
|---|---|
| `RALS_data.dta` | Household panel, 6,626 households in 2012, 2015 and 2019 (19,878 observations), with the SPEI drought indicators merged at the household's location |
| `SPEI6_Admin2_Zambia_2011_2014_2018.xlsx`, `SPEI12_Admin2_Zambia_2011_2014_2018.xlsx` | 6- and 12-month SPEI by district in April 2011, 2014 and 2018 (Figure 1) |
| `shapefiles/zmb_admbnda_adm2_dmmu_20201124.*` | District boundaries of Zambia (Figure 1) |

The RALS can be requested from IAPRI ([iapri.org.zm](https://www.iapri.org.zm)). The SPEI is public ([spei.csic.es](https://spei.csic.es)), and so are the boundaries ([OCHA HDX](https://data.humdata.org/dataset/cod-ab-zmb)).

## Software

- **Stata 18** (SE or MP). The user-written packages are bundled in `stata/ado/plus` and put first on the ado-path while the package runs, so nothing needs installing and your own Stata installation is not changed:

  | Package | Version | Used for |
  |---|---|---|
  | `outreg2` | 2.3.2 | regression tables |
  | `shufflevar` | SSC, 2026 copy | permutation test (Figure 5) |
  | `fillmissing` | SSC, 2026 copy | household locations in 2019 (Table A12) |
  | `acreg` | 1.1.0 | Conley standard errors (Table A12) |
  | `hdfe` (reghdfe 3.2.9), `ivreg2` 4.1.12, `ranktest` 2.0.04 | | required by `acreg` |
  | `boottest` | 4.5.5 | wild cluster bootstrap test (Table A13) |

  `wildbootstrap` and `jackknife` (Table A13) are part of Stata 18.
- **R 4.5** with `ggplot2`, `dplyr`, `tidyr`, `readr`, `readxl`, `sf`, `ggthemes`, `ggtext` and `patchwork`, for Figures 1–4 and 6. `00_run_all.do` finds `Rscript` in `C:/Program Files/R` or in `%LOCALAPPDATA%/Programs/R`; elsewhere, set the global `RSCRIPT` at the top of `00_run_all.do`.

## How to run

Open Stata, `cd` to this folder and type:

```
do 00_run_all.do
```

This runs, in order:

| Step | File | What it does |
|---|---|---|
| 1 | `stata/01_prepare_data.do` | Builds the outcomes (yields, crop counts, cropland, acreage shares, HHI, SDI) and saves `data/analysis_data.dta` |
| 2 | `stata/02_descriptives.do` | Table 1, Table A1 |
| 3 | `stata/03_main_results.do` | Tables 2–4, Figures 2–4 (estimates), Tables A2–A7 |
| 4 | `stata/04_additional_results.do` | Tables 5 and 6, Tables A8 and A9 |
| 5 | `stata/05_robustness.do` | Figure 5, Table 7, Figure 6 (estimates), Tables A10–A13 |
| 6 | `R/01_run_all_figures.R` | Draws Figures 1–4 and 6 |

To draw Figures 1–4 and 6 again without Stata, from this folder:

```
Rscript --vanilla R/01_run_all_figures.R
```

**Run time.** The full run took 18 minutes on a laptop with an AMD Ryzen AI 5 PRO 340, 32 GB of RAM and Windows 11. Almost all of it is `05_robustness.do` (17 minutes), mostly the 2 × 1,000 regressions of the permutation test for Figure 5; the other do-files take under a minute together, and the figures in R about 10 seconds.

## Exhibits and their files

| Exhibit | Code | Output |
|---|---|---|
| Table 1 | `02_descriptives.do` | `tables/Table1_summary_statistics.docx`, `.csv` |
| Table 2 | `03_main_results.do` | `tables/Table2_crop_diversification.doc` |
| Table 3 | `03_main_results.do` | `tables/Table3_cropland_expansion.doc` |
| Table 4 | `03_main_results.do` | `tables/Table4_hhi_sdi.doc` |
| Table 5 | `04_additional_results.do` | `tables/Table5_self_reported_droughts.doc` |
| Table 6 | `04_additional_results.do` | `tables/Table6_mundlak_chamberlain.doc` |
| Table 7 | `05_robustness.do` | `tables/Table7_enumeration_area_fe.doc` |
| Figure 1 | `R/fig01_spei_maps.R` | `figures/fig01_panelA_spei6`, `figures/fig01_panelB_spei12` |
| Figure 2 | `03_main_results.do`, `R/fig02_04_06_coefficients.R` | `figures/fig02_crop_yields` |
| Figure 3 | `03_main_results.do`, `R/fig02_04_06_coefficients.R` | `figures/fig03_resilient_seeds` |
| Figure 4 | `03_main_results.do`, `R/fig02_04_06_coefficients.R` | `figures/fig04_acreage_shares` |
| Figure 5 | `05_robustness.do` | `figures/fig05_placebo`; the 1,000 placebo estimates in `plot_data/fig05_placebo_cropland.csv`, `fig05_placebo_seeds.csv` |
| Figure 6 | `05_robustness.do`, `R/fig02_04_06_coefficients.R` | `figures/fig06_standard_errors` |
| Table A1 | `02_descriptives.do` | `tables/TableA1_between_within_sd.docx`, `.csv` |
| Table A2 | `03_main_results.do` | `tables/TableA2_crop_yields.doc` (full models of Figure 2) |
| Table A3 | `03_main_results.do` | `tables/TableA3_crop_diversification.doc` (full models of Table 2) |
| Table A4 | `03_main_results.do` | `tables/TableA4_resilient_seeds.doc` (full models of Figure 3) |
| Table A5 | `03_main_results.do` | `tables/TableA5_cropland_expansion.doc` (full models of Table 3) |
| Table A6 | `03_main_results.do` | `tables/TableA6_acreage_shares.doc` (full models of Figure 4) |
| Table A7 | `03_main_results.do` | `tables/TableA7_hhi_sdi.doc` (full models of Table 4) |
| Table A8 | `04_additional_results.do` | `tables/TableA8_self_reported_droughts.doc` (full models of Table 5) |
| Table A9 | `04_additional_results.do` | `tables/TableA9_2sls_self_reported.doc` |
| Table A10 | `05_robustness.do` | `tables/TableA10_contemporaneous_droughts.doc` |
| Table A11 | `05_robustness.do` | `tables/TableA11_lpm_fractional_logit.doc` |
| Table A12 | `05_robustness.do` | `tables/TableA12_conley_se.doc` (Figure 6, left) |
| Table A13 | `05_robustness.do` | `tables/TableA13_other_clustering.doc` (Figure 6, right) |

- Regression tables are written by `outreg2` as `.doc` (opens in Word) with a tab-separated `.txt` copy.
- Figures are saved as PNG (300 dpi) and PDF.
- The estimates and 95% intervals plotted in Figures 2, 3, 4 and 6 are in `plot_data/figure_estimates.csv`, one row per point or bar.
- Logs of the last run are in `logs/`.

## Models

- **Yields** (Figure 2): log of harvest per hectare planted of maize, groundnuts, beans, soybeans, cowpea, sorghum and sunflower, on the contemporaneous 12-month drought.
- **Adaptation outcomes** (Tables 2–4, Figures 3–4): number of crops grown, adoption of improved (climate-resilient) seeds (1/0), total cropland (hectares), acreage shares of the seven crops, crop HHI (sum of the squared acreage shares of the seven crops) and SDI (1 − HHI), on the previous season's drought.
- **Acreage shares** (Figure 4, Table A6): area planted to the crop divided by the total cropland. Households without cropland have no share (19,111 observations), except for soybeans and sunflower, where their share is counted as 0 (19,878 observations).
- **Droughts.** Drought = 1 if the SPEI in April is −1 or lower: the 12-month SPEI (main measure) or the 6-month SPEI. Contemporaneous: April of the survey year; previous: April of the year before.
- **Estimator.** Household fixed effects with year fixed effects (`xtreg, fe`), standard errors clustered by enumeration area (`cluster`). Controls: the head's sex, education and age, household size, credit access, market participation, FISP participation and the asset index.
- **Table 6:** random effects with the household means of the time-varying controls (Mundlak–Chamberlain), standard errors clustered on `hh`.
- **Table A9:** 2SLS with household fixed effects (`xtivreg, fe`); the self-reported drought is instrumented by the contemporaneous 12-month drought indicator or by the 12-month SPEI.
- **Table A12:** `acreg` (Conley standard errors) with fixed effects for `hh` and the year, `id(hh)` with a 100 km cut-off (household columns) or `id(cluster)` with a 150 km cut-off (enumeration-area columns), and three lags. Households keep their 2015 location in 2019, which has no coordinates.
- **Table A13 and Figure 6 (right):** the main maize-yield model with the wild cluster bootstrap test of `boottest` (999 replications; interval from `boottest`), Stata's `wildbootstrap` (1,000 replications) and the jackknife.
- **Random numbers.** The permutation test sets the seed 20250504 before each set of 1,000 draws; `wildbootstrap` uses `rseed(1234)`; `boottest` draws its random numbers after the permutation test, so `00_run_all.do` runs the do-files in one session and in this order. Stata's `sort` breaks ties in an order that changes between sessions; `00_run_all.do` fixes it with `set sortseed 20250504`, and sets it again before each permutation test and each `acreg` call (`hh` repeats across enumeration areas, so `acreg` sorts on ties). Two runs give identical results.
- **`boottest`.** The Mata library on SSC (4.5.5) is compiled by Stata 19.5 and does not load in Stata 18; the bundled `lboottest.mlib` was compiled under Stata 18 from the package's own `boottest.mata` and runs in Stata 18 and later.

## Variables used from `RALS_data.dta`

| Variable | Description |
|---|---|
| `panelid` | Household identifier (panel) |
| `Panel` | Survey wave (2012, 2015, 2019) |
| `cluster` | Enumeration area |
| `hh` | Household number within the enumeration area |
| `latitude`, `longitude` | Household location (decimal degrees, south and east); not recorded in 2019 |
| `Sex_HH` | Head is male (1/0) |
| `Education_HH` | Education of the head (years) |
| `age` | Age of the head (years) |
| `hhsize` | Household size |
| `Access_Credit` | Credit access (1/0) |
| `Market_Participation` | Market participation (1/0) |
| `FISP_participation` | Farmer Input Support Programme participation (1/0) |
| `asset_index` | Asset index |
| `drought` | Self-reported drought (1/0) |
| `SPEI12` | 12-month SPEI |
| `drought_shock12m_t`, `drought_shock6m_t` | Drought (SPEI ≤ −1) in April of the survey year, 12- and 6-month SPEI |
| `drought_shock12m_t_1`, `drought_shock6m_t_1` | Drought (SPEI ≤ −1) in April of the previous year, 12- and 6-month SPEI |
| `Improve_Seed` | Used improved seed varieties (1/0) |
| `crop*` | Grew the crop (1/0), 25 crops |
| `ha_plant*` | Area planted to the crop (hectares), 28 crops |
| `totharv*` | Quantity harvested (kg), for the seven crops of Figure 2 |

## Folder layout

```
00_run_all.do          runs everything
data/                  data (not included; see data/README.md)
stata/                 01-05 do-files; ado/ (fig_post.ado and the bundled packages in ado/plus)
R/                     00_setup.R, 01_run_all_figures.R and the figure scripts
tables/                Tables 1-7 and A1-A13 (created by the run)
figures/               Figures 1-6 (created by the run)
plot_data/             estimates behind Figures 2-6 (created by the run)
logs/                  logs of the run
```
