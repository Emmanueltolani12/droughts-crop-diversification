/*==============================================================================
  Rolling back the tides: Impact of droughts on crop diversification and
  cropland expansion
  Martin Paul Jr. Tabe-Ojong, Emmanuel Tolani, Ernest L. Molua
  Journal of Environmental Economics and Management 136 (2026) 103260
  https://doi.org/10.1016/j.jeem.2025.103260

  00_run_all.do runs the whole analysis, from the data to the tables and figures:

    stata/01_prepare_data.do        outcomes and variables of the analysis
    stata/02_descriptives.do        Table 1, Table A1
    stata/03_main_results.do        Tables 2-4, Figures 2-4, Tables A2-A7
    stata/04_additional_results.do  Tables 5-6, Tables A8-A9
    stata/05_robustness.do          Table 7, Figures 5-6, Tables A10-A13
    R/01_run_all_figures.R          Figures 1-4 and 6

  How to run
    Open Stata 18 (SE or MP), cd to this folder and type:  do 00_run_all.do

  Software: Stata 18; the user-written packages are bundled in stata/ado/plus.
  R 4.5 with ggplot2, dplyr, tidyr, readr, readxl, sf, ggthemes, ggtext and
  patchwork.
==============================================================================*/

version 18
clear all
set more off
set linesize 120
* sort breaks ties in a random order that changes between Stata sessions; a fixed
* sortseed makes repeated runs give identical results
set sortseed 20250504

*------------------------------------------------------------------------------
* 1. Paths. Leave ROOT empty to use the current working directory.
*------------------------------------------------------------------------------
global ROOT ""
if "$ROOT" == "" global ROOT = subinstr("`c(pwd)'", "\", "/", .)
capture confirm file "$ROOT/00_run_all.do"
if _rc {
    display as error "Cannot find 00_run_all.do under $ROOT."
    display as error "cd to this folder or set the global ROOT in 00_run_all.do."
    exit 601
}

global DATA       "$ROOT/data"
global RAW_DATA   "$DATA/RALS_data.dta"
global ANALYSIS   "$DATA/analysis_data.dta"
global STATA      "$ROOT/stata"
global PLOT_DATA  "$ROOT/plot_data"
global TABLES     "$ROOT/tables"
global FIGURES    "$ROOT/figures"
global LOGS       "$ROOT/logs"

* Rscript. Leave empty to look in the standard Windows locations.
global RSCRIPT ""

foreach path in "$PLOT_DATA" "$TABLES" "$FIGURES" "$LOGS" {
    capture mkdir "`path'"
}

* The data are not part of the package (README.md, 'Data availability')
foreach f in "$RAW_DATA" "$DATA/SPEI6_Admin2_Zambia_2011_2014_2018.xlsx" ///
    "$DATA/SPEI12_Admin2_Zambia_2011_2014_2018.xlsx" ///
    "$DATA/shapefiles/zmb_admbnda_adm2_dmmu_20201124.shp" {
    capture confirm file "`f'"
    if _rc {
        display as error "Data file not found: `f'"
        display as error "See README.md, 'Data availability'."
        exit 601
    }
}

* The bundled packages come first on the ado-path; your own Stata installation
* is not changed.
adopath ++ "$STATA/ado/plus"
adopath ++ "$STATA/ado"
mata: mata mlib index

*------------------------------------------------------------------------------
* 2. Specification
*------------------------------------------------------------------------------
* Household controls
global controls  Sex_HH Education_HH age hhsize Access_Credit Market_Participation ///
                 FISP_participation asset_index
* Household means of the time-varying controls (Mundlak-Chamberlain, Table 6)
global tcontrols Education_HHbar agebar hhsizebar Access_Creditbar ///
                 Market_Participationbar FISP_participationbar asset_indexbar
* Area planted to each crop (hectares); their sum is the cropland area
global areasum   ha_plantBambara_nuts ha_plantBlack_Sunhemp ha_plantBurley_Tobacco ///
                 ha_plantCashew_nut ha_plantCowpeas ha_plantGreen_Gram ha_plantGroundnuts ///
                 ha_plantIrish_Potatoes ha_plantMaize ha_plantMillet ha_plantMixed_Beans ///
                 ha_plantPaprika ha_plantPigeon_peas ha_plantPopcorn ha_plantRed_Sunhemp ///
                 ha_plantRice ha_plantSeed_Cotton ha_plantSesame_seeds ha_plantSorghum ///
                 ha_plantSoyabeans ha_plantSugar_Cane ha_plantSunflower ///
                 ha_plantSweet_Potato_orange_fle ha_plantSweet_Potato_white_fle ///
                 ha_plantVelvet_Beans ha_plantVirginia_Tobacco ha_plantOther_crop ha_plantCassava

*------------------------------------------------------------------------------
* 3. Log and software versions
*------------------------------------------------------------------------------
capture log close _all
log using "$LOGS/00_run_all.log", replace text name(master)
display as text "Folder: $ROOT"
display as text "Stata/" c(edition_real) " " c(stata_version) " (update of " c(born_date) "), " ///
    c(os) ", started " c(current_date) " " c(current_time)
foreach p in outreg2 shufflevar fillmissing acreg boottest {
    which `p'
}

*------------------------------------------------------------------------------
* 4. Analysis in Stata. The do-files run in this order in one session: the
*    bootstrap of Table A13 draws its random numbers after the placebo test of
*    Figure 5 (both in 05_robustness.do).
*------------------------------------------------------------------------------
capture frame drop fig_estimates
timer clear
local step = 0
foreach f in 01_prepare_data 02_descriptives 03_main_results 04_additional_results ///
    05_robustness {
    local ++step
    timer on `step'
    display as text _n "{hline 78}" _n "Running `f'.do" _n "{hline 78}"
    do "$STATA/`f'.do"
    timer off `step'
}

* Estimates behind Figures 2, 3, 4 and 6
frame fig_estimates {
    sort figure order, stable
    export delimited using "$PLOT_DATA/figure_estimates.csv", replace
}

*------------------------------------------------------------------------------
* 5. Figures in R. The script writes a marker file when it has finished, because
*    shell does not return the exit code of the program it runs.
*------------------------------------------------------------------------------
if "$RSCRIPT" == "" {
    foreach base in "C:/Program Files/R" "`: environment LOCALAPPDATA'/Programs/R" {
        local base = subinstr("`base'", "\", "/", .)
        local rdirs : dir "`base'" dirs "R-*"
        foreach d of local rdirs {
            capture confirm file "`base'/`d'/bin/Rscript.exe"
            if !_rc global RSCRIPT "`base'/`d'/bin/Rscript.exe"
        }
    }
}
if "$RSCRIPT" == "" & c(os) != "Windows" global RSCRIPT "Rscript"
if c(os) == "Windows" {
    capture confirm file "$RSCRIPT"
    if _rc {
        display as error "Rscript not found. Set the global RSCRIPT in 00_run_all.do."
        exit 601
    }
}
local f 01_run_all_figures
timer on 20
display as text _n "{hline 78}" _n "Running R/`f'.R" _n "{hline 78}"
capture erase "$LOGS/`f'.done"
capture erase "$LOGS/`f'.log"
* The command goes through a small script, because cmd.exe mangles a command line
* that starts with a quoted path and contains other quoted paths.
local script "$LOGS/`f'.cmd"
tempname h
file open `h' using "`script'", write replace
if c(os) == "Windows" file write `h' "chcp 65001 >nul" _n
file write `h' `""$RSCRIPT" --vanilla "$ROOT/R/`f'.R" "$ROOT" > "$LOGS/`f'.log" 2>&1"' _n
file close `h'
if c(os) == "Windows" shell "`script'"
else                  shell sh "`script'"
erase "`script'"
timer off 20
capture confirm file "$LOGS/`f'.done"
if _rc {
    display as error "`f'.R did not finish; see $LOGS/`f'.log"
    exit 9
}
erase "$LOGS/`f'.done"

timer list
display as text _n "Finished " c(current_date) " " c(current_time)
log close master
