/*------------------------------------------------------------------------------
  02_descriptives.do
  Table 1   Summary statistics (observations, mean, standard deviation)
  Table A1  Summary statistics with between and within standard deviations

  Input : data/analysis_data.dta
  Output: tables/Table1_summary_statistics.docx/.csv
          tables/TableA1_between_within_sd.docx/.csv
  Run from 00_run_all.do.
------------------------------------------------------------------------------*/

use "$ANALYSIS", clear
xtset panelid Panel

*------------------------------------------------------------------------------
* Table 1. Summary statistics: all household-year observations, 2012-2019.
* Self-reported droughts as recorded (missing for households without crops).
*------------------------------------------------------------------------------
local g1 "Yields (kg/ha)"
local v1 maize gnut soy cow beans sorghum sun
local g2 "Crop diversification"
local v2 crops hhi sdi Improve_Seed drought area
local g3 "Acreage shares"
local v3 ha_plantGroundnuts_area ha_plantMaize_area ha_plantSorghum_area ///
         ha_plantMixed_Beans_area ha_plantSoyabeans_area ha_plantSunflower_area ///
         ha_plantCowpeas_area
local g4 "Household characteristics"
local v4 Sex_HH Education_HH age hhsize Access_Credit Market_Participation ///
         FISP_participation asset_index

* Labels as printed in Table 1
local l_Education_HH          "Education of household head"
local l_hhsize                "Household size"
local l_Market_Participation  "Market Participation (1/0)"

tempname post
tempfile t1
postfile `post' str30 group str50 variable str40 varname long obs double(mean sd) using "`t1'"
forvalues g = 1/4 {
    foreach v of local v`g' {
        quietly summarize `v'
        local lab : variable label `v'
        if "`l_`v''" != "" local lab "`l_`v''"
        post `post' ("`g`g''") ("`lab'") ("`v'") (r(N)) (r(mean)) (r(sd))
    }
}
postclose `post'

preserve
use "`t1'", clear
export delimited using "$TABLES/Table1_summary_statistics.csv", replace

putdocx clear
putdocx begin, font("Times New Roman", 10)
putdocx paragraph
putdocx text ("Table 1"), bold
putdocx paragraph
putdocx text ("Summary statistics.")
local nrows = _N + 5
putdocx table t1 = (`nrows', 4), border(all, nil) border(top) layout(autofitcontents)
putdocx table t1(1, 2) = ("Obs"), halign(right)
putdocx table t1(1, 3) = ("Mean"), halign(right)
putdocx table t1(1, 4) = ("Std. Dev."), halign(right)
putdocx table t1(1, .), border(bottom)
local row = 1
local last ""
forvalues i = 1/`=_N' {
    if group[`i'] != "`last'" {
        local ++row
        putdocx table t1(`row', 1) = (group[`i']), bold
        local last = group[`i']
    }
    local ++row
    putdocx table t1(`row', 1) = (variable[`i'])
    putdocx table t1(`row', 2) = (string(obs[`i'], "%9.0f")), halign(right)
    putdocx table t1(`row', 3) = (string(mean[`i'], "%12.3f")), halign(right)
    putdocx table t1(`row', 4) = (string(sd[`i'], "%12.3f")), halign(right)
}
putdocx table t1(`row', .), border(bottom)
putdocx paragraph
putdocx text ("Notes: FISP stands for farmer input support programme.")
putdocx save "$TABLES/Table1_summary_statistics.docx", replace
restore

*------------------------------------------------------------------------------
* Table A1. Mean and overall, between and within standard deviations of the
* household characteristics (xtsum)
*------------------------------------------------------------------------------
local l_Sex_HH                "Head is male (1/0)"
local l_Education_HH          "Education of household head"
local l_age                   "Age of household head (years)"
local l_hhsize                "Household size (number)"
local l_Access_Credit         "Credit access (1/0)"
local l_Market_Participation  "Market participation (1/0)"
local l_FISP_participation    "FISP participation (1/0)"
local l_asset_index           "Asset index"

tempfile ta1
postfile `post' str50 variable str40 varname double(mean sd between within) using "`ta1'"
foreach v of local v4 {
    quietly xtsum `v'
    post `post' ("`l_`v''") ("`v'") (r(mean)) (r(sd)) (r(sd_b)) (r(sd_w))
}
postclose `post'

preserve
use "`ta1'", clear
export delimited using "$TABLES/TableA1_between_within_sd.csv", replace
putdocx clear
putdocx begin, font("Times New Roman", 10)
putdocx paragraph
putdocx text ("Table A1: Summary statistics with between and within standard deviations"), bold
local nrows = _N + 1
putdocx table a1 = (`nrows', 5), border(all, nil) border(top) layout(autofitcontents)
local c = 1
foreach h in "" "Mean" "SD" "Between" "Within" {
    putdocx table a1(1, `c') = ("`h'"), halign(right)
    local ++c
}
putdocx table a1(1, .), border(bottom)
forvalues i = 1/`=_N' {
    local row = `i' + 1
    putdocx table a1(`row', 1) = (variable[`i'])
    local c = 2
    foreach s in mean sd between within {
        putdocx table a1(`row', `c') = (string(`s'[`i'], "%9.3f")), halign(right)
        local ++c
    }
}
putdocx table a1(`=_N + 1', .), border(bottom)
putdocx paragraph
putdocx text ("Notes: SD stands for standard deviation.")
putdocx save "$TABLES/TableA1_between_within_sd.docx", replace
restore
