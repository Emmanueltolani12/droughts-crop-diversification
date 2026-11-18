/*------------------------------------------------------------------------------
  04_additional_results.do
  Table 5, Table A8  Self-reported droughts: maize yields, cropland, resilient
                     seeds and diversification (household FE)
  Table A9           2SLS: self-reported droughts and maize yields, instrumented
                     by the 12-month drought indicator or the SPEI-12
  Table 6            Mundlak-Chamberlain (correlated random effects) estimates

  Input : data/analysis_data.dta
  Output: tables/Table5*.doc, tables/TableA8*.doc, tables/TableA9*.doc,
          tables/Table6*.doc (with .txt)
  Run from 00_run_all.do.
------------------------------------------------------------------------------*/

use "$ANALYSIS", clear
xtset panelid Panel

local nc  addtext(Additional controls, No, Year FE, Yes)
local wc  addtext(Additional controls, Yes, Year FE, Yes)

* Self-reported drought: missing (households without crops) = no drought
replace drought = 0 if drought == .

*------------------------------------------------------------------------------
* Table 5 and Table A8: self-reported droughts
*------------------------------------------------------------------------------
local opt replace
foreach y in logmaize area Improve_Seed crops {
    xtreg `y' drought i.Panel $controls, fe vce(cluster cluster)
    local ct = cond("`y'" == "logmaize", "Yields (Maize)", ///
               cond("`y'" == "area", "Cropland expansion", ///
               cond("`y'" == "Improve_Seed", "Resilient seeds", "Diversification")))
    outreg2 using "$TABLES/Table5_self_reported_droughts.doc", `opt' ctitle("`ct'") ///
        dec(3) keep(drought) lab `wc'
    outreg2 using "$TABLES/TableA8_self_reported_droughts.doc", `opt' ctitle("`ct'") ///
        dec(3) drop(i.Panel) lab `wc'
    local opt append
}

*------------------------------------------------------------------------------
* Table A9: 2SLS, self-reported droughts instrumented by the drought indicator
* (columns 1-2) and by the SPEI-12 (columns 3-4)
*------------------------------------------------------------------------------
local opt replace
foreach iv in drought_shock12m_t SPEI12 {
    local ivname = cond("`iv'" == "SPEI12", "SPEI", "Droughts")
    foreach c in No Yes {
        if "`c'" == "No" xtivreg logmaize (drought = `iv') i.Panel, fe vce(cluster cluster)
        else             xtivreg logmaize (drought = `iv') i.Panel $controls, fe vce(cluster cluster)
        outreg2 using "$TABLES/TableA9_2sls_self_reported.doc", `opt' ctitle("Maize") ///
            dec(3) drop(i.Panel $controls) lab ///
            addtext(Additional controls, `c', Year FE, Yes, IV, `ivname')
        local opt append
    }
}

*------------------------------------------------------------------------------
* Table 6: Mundlak-Chamberlain estimates (random effects with the household
* means of the time-varying controls)
*------------------------------------------------------------------------------
local opt replace
foreach y in logmaize area crops Improve_Seed {
    * Contemporaneous drought for yields, previous drought for the adaptations
    local d = cond("`y'" == "logmaize", "drought_shock12m_t", "drought_shock12m_t_1")
    local ct = cond("`y'" == "logmaize", "Yield", ///
               cond("`y'" == "area", "Cropland expansion", ///
               cond("`y'" == "crops", "Diversification", "Improved seeds")))
    xtreg `y' `d' $controls $tcontrols i.Panel, re vce(cluster hh)
    outreg2 using "$TABLES/Table6_mundlak_chamberlain.doc", `opt' ctitle("`ct'") ///
        dec(3) drop(i.Panel $tcontrols) lab ///
        addtext(Additional controls, Yes, Village FE, Yes, Year FE, Yes)
    local opt append
}
