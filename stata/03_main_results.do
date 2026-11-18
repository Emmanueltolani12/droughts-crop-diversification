/*------------------------------------------------------------------------------
  03_main_results.do
  Household fixed-effects regressions with year fixed effects; standard errors
  clustered at the enumeration area (cluster).

  Figure 2, Table A2   Droughts (12 months, contemporaneous) and log crop yields
  Table 2,  Table A3   Previous droughts and crop diversification (crop counts)
  Figure 3, Table A4   Previous droughts and climate-resilient crop varieties
  Table 3,  Table A5   Previous droughts and cropland expansion
  Figure 4, Table A6   Previous droughts and crop acreage shares
  Table 4,  Table A7   Previous droughts, crop HHI and SDI

  Input : data/analysis_data.dta
  Output: tables/Table2-4*.doc/.txt, tables/TableA2-A7*.doc/.txt; the estimates
          of Figures 2-4 go to plot_data/figure_estimates.csv (00_run_all.do)
  Run from 00_run_all.do.
------------------------------------------------------------------------------*/

use "$ANALYSIS", clear
xtset panelid Panel

* Rows below the estimates, as in the paper
local nc  addtext(Additional controls, No, Year FE, Yes)
local wc  addtext(Additional controls, Yes, Year FE, Yes)
* Previous droughts (t-1) for 12 and 6 months; the main tables show these and the constant
local prev drought_shock12m_t_1 drought_shock6m_t_1

*------------------------------------------------------------------------------
* Figure 2 and Table A2: droughts and crop yields (log kg/ha)
*------------------------------------------------------------------------------
local file "$TABLES/TableA2_crop_yields.doc"
local opt replace
foreach var in maize sun sorghum beans cow soy gnut {
    xtreg log`var' drought_shock12m_t i.Panel $controls, fe vce(cluster cluster)
    fig_post, figure(fig02) panel("Droughts and crop yields") ///
        label("`: variable label log`var''") coef(drought_shock12m_t)
    outreg2 using "`file'", `opt' ctitle("`: variable label log`var''") dec(3) ///
        drop(i.Panel) lab `wc'
    local opt append
}

*------------------------------------------------------------------------------
* Table 2 and Table A3: droughts and crop diversification (number of crops)
*------------------------------------------------------------------------------
local opt replace
foreach d in drought_shock12m_t_1 drought_shock6m_t_1 {
    foreach c in nc wc {
        if "`c'" == "nc" xtreg crops `d' i.Panel, fe vce(cluster cluster)
        else             xtreg crops `d' i.Panel $controls, fe vce(cluster cluster)
        outreg2 using "$TABLES/Table2_crop_diversification.doc", `opt' ///
            ctitle("Diversification") dec(3) keep(`prev') lab ``c''
        outreg2 using "$TABLES/TableA3_crop_diversification.doc", `opt' ///
            ctitle("Diversification") dec(3) drop(i.Panel) lab ``c''
        local opt append
    }
}

*------------------------------------------------------------------------------
* Figure 3 and Table A4: droughts and climate-resilient crop varieties (1/0)
*------------------------------------------------------------------------------
local opt replace
foreach d in drought_shock12m_t_1 drought_shock6m_t_1 {
    local m = cond("`d'" == "drought_shock12m_t_1", "12months", "6months")
    foreach c in nc wc {
        if "`c'" == "nc" xtreg Improve_Seed `d' i.Panel, fe vce(cluster cluster)
        else             xtreg Improve_Seed `d' i.Panel $controls, fe vce(cluster cluster)
        local tag = cond("`c'" == "nc", "NC", "C")
        fig_post, figure(fig03) panel("Droughts and climate-resilient crop varieties") ///
            label("Drought<br>(`m' - `tag')") coef(`d')
        outreg2 using "$TABLES/TableA4_resilient_seeds.doc", `opt' ///
            ctitle("Resilient seeds") dec(3) drop(i.Panel) lab ``c''
        local opt append
    }
}

*------------------------------------------------------------------------------
* Table 3 and Table A5: droughts and cropland expansion (hectares)
*------------------------------------------------------------------------------
local opt replace
foreach d in drought_shock12m_t_1 drought_shock6m_t_1 {
    foreach c in nc wc {
        if "`c'" == "nc" xtreg area `d' i.Panel, fe vce(cluster cluster)
        else             xtreg area `d' i.Panel $controls, fe vce(cluster cluster)
        outreg2 using "$TABLES/Table3_cropland_expansion.doc", `opt' ///
            ctitle("Cropland") dec(3) keep(`prev') lab ``c''
        outreg2 using "$TABLES/TableA5_cropland_expansion.doc", `opt' ///
            ctitle("Cropland") dec(3) drop(i.Panel) lab ``c''
        local opt append
    }
}

*------------------------------------------------------------------------------
* Figure 4 and Table A6: droughts and crop acreage shares. The soybean and
* sunflower shares count households without cropland as 0 (19,878
* observations); the other five shares are missing for them (19,111).
*------------------------------------------------------------------------------
local opt replace
foreach crop in Groundnuts Maize Sorghum Mixed_Beans Soyabeans Sunflower Cowpeas {
    local y ha_plant`crop'_area
    if inlist("`crop'", "Soyabeans", "Sunflower") local y ha_plant`crop'_area0
    xtreg `y' drought_shock12m_t_1 i.Panel $controls, fe vce(cluster cluster)
    local lab : variable label `y'
    local lab = subinstr("`lab'", " acreage share", "", 1)
    fig_post, figure(fig04) panel("Droughts and cropland expansion") ///
        label("`lab'") coef(drought_shock12m_t_1)
    outreg2 using "$TABLES/TableA6_acreage_shares.doc", `opt' ctitle("`lab'") ///
        dec(3) drop(i.Panel) lab `wc'
    local opt append
}

*------------------------------------------------------------------------------
* Table 4 and Table A7: droughts, crop HHI and SDI
*------------------------------------------------------------------------------
local opt replace
foreach y in hhi sdi {
    foreach d in drought_shock12m_t_1 drought_shock6m_t_1 {
        xtreg `y' `d' i.Panel $controls, fe vce(cluster cluster)
        local ct = upper("`y'")
        outreg2 using "$TABLES/Table4_hhi_sdi.doc", `opt' ctitle("`ct'") dec(3) ///
            keep(`prev') lab `wc'
        outreg2 using "$TABLES/TableA7_hhi_sdi.doc", `opt' ctitle("`ct'") dec(3) ///
            drop(i.Panel) lab `wc'
        local opt append
    }
}
