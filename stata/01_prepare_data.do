/*------------------------------------------------------------------------------
  01_prepare_data.do
  Builds the outcomes of the paper from the RALS household panel and saves the
  analysis data (data/analysis_data.dta), which the later do-files use.

  Input : data/RALS_data.dta  (RALS 2012, 2015, 2019; 6,626 households, 19,878
          observations; drought indicators from the SPEI already merged)
  Output: data/analysis_data.dta
  Run from 00_run_all.do.
------------------------------------------------------------------------------*/

use "$RAW_DATA", clear
xtset panelid Panel

*------------------------------------------------------------------------------
* Household means of the time-varying controls (Mundlak-Chamberlain, Table 6),
* over the three waves
*------------------------------------------------------------------------------
foreach var of varlist Education_HH age hhsize Access_Credit Market_Participation ///
    FISP_participation asset_index {
    egen `var'bar = mean(`var'), by(panelid)
}

* Head is male (1/0)
replace Sex_HH = 0 if Sex_HH == 2

*------------------------------------------------------------------------------
* Crops grown and adoption of improved (climate-resilient) seeds: missing = no
*------------------------------------------------------------------------------
global cropdummies cropBambara_nuts cropBlack_Sunhemp cropBurley_Tobacco cropCashew_nut ///
    cropCowpeas cropGroundnuts cropIrish_Potatoes cropMixed_Beans cropPaprika ///
    cropPigeon_peas cropRice cropSeed_Cotton cropSesame_seeds cropSoyabeans ///
    cropSunflower cropSweet_Potato_orange_fleshed cropSweet_Potato_white_fleshed ///
    cropVelvet_Beans cropVirginia_Tobacco cropCassava cropMaize cropMillet cropPopcorn ///
    cropSorghum cropSugar_Cane

foreach var of varlist $cropdummies Improve_Seed {
    replace `var' = 0 if `var' == .
}

* Crop diversification: number of crops grown
egen crops = rowtotal($cropdummies)

*------------------------------------------------------------------------------
* Yields (kg/ha) of the seven major crops, and their logarithm
*------------------------------------------------------------------------------
gen maize   = totharvMaize       / ha_plantMaize
gen gnut    = totharvGroundnuts  / ha_plantGroundnuts
gen soy     = totharvSoyabeans   / ha_plantSoyabeans
gen cow     = totharvCowpeas     / ha_plantCowpeas
gen beans   = totharvMixed_Beans / ha_plantMixed_Beans
gen sorghum = totharvSorghum     / ha_plantSorghum
gen sun     = totharvSunflower   / ha_plantSunflower

foreach var of varlist maize gnut soy cow beans sorghum sun {
    gen log`var' = log(`var')
}

*------------------------------------------------------------------------------
* Cropland: total area planted (hectares), and the acreage shares of the seven
* major crops
*------------------------------------------------------------------------------
foreach var of varlist $areasum {
    replace `var' = 0 if `var' == .
}
egen area = rowtotal($areasum)

foreach var of varlist ha_plantGroundnuts ha_plantMaize ha_plantMixed_Beans ///
    ha_plantSoyabeans ha_plantSunflower ha_plantCowpeas ha_plantSorghum {
    gen `var'_area = `var' / area
}

* Soybean and sunflower shares with households without cropland counted as 0
* (Table A6, columns 5 and 6, and Figure 4)
gen ha_plantSoyabeans_area0 = cond(area > 0, ha_plantSoyabeans_area, 0)
gen ha_plantSunflower_area0 = cond(area > 0, ha_plantSunflower_area, 0)

* Crop Herfindahl-Hirschman index (eq. 1) and Simpson's diversity index (eq. 2)
gen hhi = ha_plantGroundnuts_area^2 + ha_plantMaize_area^2 + ha_plantSorghum_area^2 + ///
    ha_plantMixed_Beans_area^2 + ha_plantSoyabeans_area^2 + ha_plantSunflower_area^2 + ///
    ha_plantCowpeas_area^2
gen sdi = 1 - hhi

*------------------------------------------------------------------------------
* Labels (used in the tables)
*------------------------------------------------------------------------------
la var hhsize                       "Household size (num)"
la var Access_Credit                "Credit access (1/0)"
la var age                          "Age of household head (years)"
la var Education_HH                 "Educational level (years)"
la var Sex_HH                       "Head is male (1/0)"
la var Market_Participation         "Market participation (1/0)"
la var FISP_participation           "FISP participation (1/0)"
la var drought                      "Self-reported droughts (1/0)"
la var asset_index                  "Asset index"
la var drought_shock12m_t_1         "Drought (12months)"
la var drought_shock6m_t_1          "Drought (6 months)"
la var drought_shock12m_t           "Drought (12months)"
la var drought_shock6m_t            "Drought (6months)"
la var Improve_Seed                 "Climate-resilient crops (1/0)"
la var crops                        "Crop counts"
la var area                         "Total cropland area"
la var hhi                          "Herfindahl Hirschman Index (HHI)"
la var sdi                          "Simpson's Diversity Index (SDI)"
la var maize                        "Maize"
la var gnut                         "Groundnut"
la var soy                          "Soybeans"
la var cow                          "Cowpea"
la var beans                        "Beans"
la var sorghum                      "Sorghum"
la var sun                          "Sunflower"
la var logmaize                     "Maize"
la var loggnut                      "Groundnut"
la var logsoy                       "Soybean"
la var logcow                       "Cowpea"
la var logbeans                     "Beans"
la var logsorghum                   "Sorghum"
la var logsun                       "Sunflower"
la var ha_plantGroundnuts_area      "Groundnut acreage share"
la var ha_plantMaize_area           "Maize acreage share"
la var ha_plantSorghum_area         "Sorghum acreage share"
la var ha_plantMixed_Beans_area     "Beans acreage share"
la var ha_plantSoyabeans_area       "Soybean acreage share"
la var ha_plantSunflower_area       "Sunflower acreage share"
la var ha_plantCowpeas_area         "Cowpea acreage share"
la var ha_plantSoyabeans_area0      "Soybean acreage share"
la var ha_plantSunflower_area0      "Sunflower acreage share"

sort panelid Panel
save "$ANALYSIS", replace
