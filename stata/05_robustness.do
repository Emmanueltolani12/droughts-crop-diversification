/*------------------------------------------------------------------------------
  05_robustness.do
  Figure 5           Non-parametric permutation test: 1,000 regressions on
                     scrambled droughts, for cropland and climate-resilient seeds
  Table A11          Linear probability and fractional response models of
                     diversification
  Table A10          Contemporaneous droughts and the adaptation outcomes
  Table 7            Enumeration area fixed effects
  Figure 6, Table A12  Conley standard errors (left panel)
  Figure 6, Table A13  Bootstrap, wild bootstrap and jackknife (right panel)

  The sections run in this order: the bootstrap of Table A13 draws its random
  numbers after the permutation test of Figure 5.

  Input : data/analysis_data.dta; the permutation test reloads data/RALS_data.dta
          in each draw
  Output: figures/fig05_placebo.png/.pdf, plot_data/fig05_placebo_*.csv,
          tables/Table7*.doc, tables/TableA10-A13*.doc (with .txt); the
          estimates of Figure 6 go to plot_data/figure_estimates.csv
  Run from 00_run_all.do.
------------------------------------------------------------------------------*/

use "$ANALYSIS", clear
xtset panelid Panel

local nc  addtext(Additional controls, No, Year FE, Yes)
local wc  addtext(Additional controls, Yes, Year FE, Yes)

*------------------------------------------------------------------------------
* Figure 5: permutation test. Each draw reloads the household data, shuffles
* the previous 12-month drought indicator jointly within enumeration areas
* (shufflevar, joint cluster(cluster)) and re-estimates the main model with the
* scrambled indicator. The red line marks the main estimate.
*------------------------------------------------------------------------------
foreach y in Improve_Seed area {
    preserve
    xtreg `y' drought_shock12m_t_1 i.Panel $controls, fe vce(cluster cluster)
    scalar true_coef = _b[drought_shock12m_t_1]

    set seed 20250504
    set sortseed 20250504
    tempfile placebo_results
    tempname handle
    postfile `handle' coef using "`placebo_results'", replace
    forvalues j = 1/1000 {
        quietly use "$RAW_DATA", clear
        if "`y'" == "area" quietly egen area = rowtotal($areasum)
        shufflevar drought_shock12m_t_1, joint cluster(cluster)
        quietly xtreg `y' drought_shock12m_t_1_shuffled i.Panel $controls, fe vce(cluster cluster)
        post `handle' (_b[drought_shock12m_t_1_shuffled])
    }
    postclose `handle'

    use "`placebo_results'", clear
    rename coef placebo_coef
    gen iteration = _n
    local name = cond("`y'" == "area", "cropland", "seeds")
    export delimited using "$PLOT_DATA/fig05_placebo_`name'.csv", replace

    if "`y'" == "Improve_Seed" {
        * Figure 5, right panel
        histogram placebo_coef, ///
            fraction bin(30) color(gs11) lcolor(purple) ///
            xtitle("Coefficient on Scrambled Droughts") ///
            title("Climate-resilient seeds") ///
            xline(0.15, lcolor(red) lpattern(dash)) ///
            xscale(range(0.05 0.2)) ///
            xlabel(-0.05(0.05)0.2 0.1 "0.1") name(fig05_seeds, replace)
    }
    else {
        * Figure 5, left panel
        histogram placebo_coef, ///
            fraction bin(30) color(gs11) lcolor(purple) ///
            xtitle("Coefficient on Scrambled Droughts") ///
            title("Cropland expansion") ///
            xline(0.15, lcolor(red) lpattern(dash)) ///
            xscale(range(0.05 0.2)) ///
            xlabel(-0.05(0.05)0.2 0.15 "0.29") name(fig05_cropland, replace)
    }

    * Permutation p-value: share of placebo estimates at least as large in absolute value
    quietly count if abs(placebo_coef) >= abs(true_coef)
    display as result "`y': main estimate = " %6.3f true_coef ///
        ", placebo p-value = " r(N) / _N
    restore
}

graph combine fig05_cropland fig05_seeds, name(fig05, replace)
graph export "$FIGURES/fig05_placebo.png", replace width(3000)
graph export "$FIGURES/fig05_placebo.pdf", replace

*------------------------------------------------------------------------------
* Table A11: linear probability model (grows at least one crop, 1/0) and
* fractional logit (crop count / 9, GEE)
*------------------------------------------------------------------------------
gen cropsd = (crops != 0)
gen cropsf = crops / 9

xtreg cropsd drought_shock12m_t_1 i.Panel $controls, fe vce(cluster cluster)
outreg2 using "$TABLES/TableA11_lpm_fractional_logit.doc", replace ctitle("LPM") ///
    dec(3) drop(i.Panel) lab `nc'
xtgee cropsf drought_shock12m_t_1 i.Panel $controls, link(logit) family(binomial)
outreg2 using "$TABLES/TableA11_lpm_fractional_logit.doc", append ///
    ctitle("Fractional Logit") dec(3) drop(i.Panel) lab `nc'

*------------------------------------------------------------------------------
* Table A10: contemporaneous droughts and the adaptation outcomes
*------------------------------------------------------------------------------
local opt replace
foreach y in area crops hhi sdi Improve_Seed {
    local ct = cond("`y'" == "area", "Cropland", cond("`y'" == "crops", "Crops", ///
               cond("`y'" == "Improve_Seed", "Resilient seeds", upper("`y'"))))
    xtreg `y' drought_shock12m_t i.Panel $controls, fe vce(cluster cluster)
    outreg2 using "$TABLES/TableA10_contemporaneous_droughts.doc", `opt' ctitle("`ct'") ///
        dec(3) drop(i.Panel $controls) lab `wc'
    local opt append
}

*------------------------------------------------------------------------------
* Table 7: enumeration area fixed effects
*------------------------------------------------------------------------------
local opt replace
foreach y in logmaize area crops Improve_Seed {
    local d = cond("`y'" == "logmaize", "drought_shock12m_t", "drought_shock12m_t_1")
    local ct = cond("`y'" == "logmaize", "Yields (maize)", ///
               cond("`y'" == "area", "Cropland expansion", ///
               cond("`y'" == "crops", "Diversification", "Resilient seeds")))
    xtreg `y' `d' i.Panel i.cluster $controls, fe vce(cluster cluster)
    outreg2 using "$TABLES/Table7_enumeration_area_fe.doc", `opt' ctitle("`ct'") ///
        dec(3) drop(i.Panel i.cluster $controls) lab `wc'
    local opt append
}

*------------------------------------------------------------------------------
* Figure 6 (left) and Table A12: Conley standard errors (acreg), maize yields.
* The 2019 wave has no GPS coordinates; each household keeps its 2015 location.
*------------------------------------------------------------------------------
sort panelid Panel
fillmissing latitude, with(previous)
fillmissing longitude, with(previous)

local ac addtext(Additional controls, Yes, Household FE, Yes, Year FE, Yes)
local opt replace
foreach d in drought_shock12m_t drought_shock6m_t {
    local m = cond("`d'" == "drought_shock12m_t", "12months", "6months")
    * Household: 100 km cut-off; enumeration area: 150 km cut-off
    foreach id in hh cluster {
        local dist = cond("`id'" == "hh", 100, 150)
        local tag  = cond("`id'" == "hh", "HH", "EA")
        * acreg sorts by id() and time(); hh repeats across enumeration areas, so
        * the order of tied observations is fixed for a reproducible variance
        set sortseed 20250504
        acreg logmaize `d' $controls, id(`id') time(Panel) lag(3) spatial ///
            latitude(latitude) longitude(longitude) dist(`dist') pfe1(hh) pfe2(Panel) ///
            hac correctr2
        fig_post, figure(fig06) panel("Conley standard errors") ///
            label("Drought<br>(`m' - `tag')") coef(`d')
        outreg2 using "$TABLES/TableA12_conley_se.doc", `opt' ///
            ctitle(`=cond("`id'" == "hh", "Household FE", "EA FE")') dec(3) lab `ac'
        local opt append
    }
}

*------------------------------------------------------------------------------
* Figure 6 (right) and Table A13: other ways to compute the standard errors of
* the maize-yield model
*------------------------------------------------------------------------------
* Wild cluster bootstrap test (boottest) after the main model
xtreg logmaize drought_shock12m_t i.Panel $controls, fe vce(cluster cluster)
boottest drought_shock12m_t, cluster(cluster)
local bt_p  = r(p)
local bt_lo = el(r(CI), 1, 1)
local bt_hi = el(r(CI), 1, 2)
fig_post, figure(fig06b) panel("Other clustering approaches") label("Bootstrapping") ///
    coef(drought_shock12m_t) b(_b[drought_shock12m_t]) se(_se[drought_shock12m_t]) ///
    lo(`bt_lo') hi(`bt_hi') p(`bt_p') order(1)
outreg2 using "$TABLES/TableA13_other_clustering.doc", replace ctitle("Bootstrapping") ///
    dec(3) drop(i.Panel $controls) lab `wc'

* Wild bootstrap (Stata's wildbootstrap)
wildbootstrap xtreg logmaize drought_shock12m_t i.Panel $controls, fe cluster(cluster) ///
    rseed(1234)
* r(table) holds one column per tested constraint; wb_cns1 is drought_shock12m_t = 0
assert "`e(wb_cns1)'" == "drought_shock12m_t = 0"
matrix WB = r(table)
foreach s in b ll ul pvalue {
    local wb_`s' = WB[rownumb(WB, "`s'"), 1]
}
fig_post, figure(fig06b) panel("Other clustering approaches") ///
    label("Wild bootstrapping") coef(drought_shock12m_t) order(3) ///
    b(`wb_b') se(`=_se[drought_shock12m_t]') lo(`wb_ll') hi(`wb_ul') p(`wb_pvalue')
outreg2 using "$TABLES/TableA13_other_clustering.doc", append ///
    ctitle("Wild Bootstrapping") dec(3) drop(i.Panel $controls) lab `wc'

* Jackknife
jackknife: xtreg logmaize drought_shock12m_t i.Panel $controls, fe vce(cluster cluster)
fig_post, figure(fig06b) panel("Other clustering approaches") label("Jacknife") ///
    coef(drought_shock12m_t) order(2)
outreg2 using "$TABLES/TableA13_other_clustering.doc", append ctitle("Jacknife") ///
    dec(3) drop(i.Panel $controls) lab `wc'
