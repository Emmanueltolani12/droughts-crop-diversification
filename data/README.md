# Data

The data are not included in this repository. Save the files below in this folder (`data/`) before running `00_run_all.do`; it stops with a message if one is missing.

| File | Content | Source |
|---|---|---|
| `RALS_data.dta` | Household panel from the Rural Agricultural Livelihoods Survey (RALS) 2012, 2015 and 2019: 6,626 households, 19,878 household-year observations, with the drought indicators from the SPEI merged at the household's location | RALS: Indaba Agricultural Policy Research Institute (IAPRI), Zambia. SPEI: Global SPEI database / SPEI Global Drought Monitor |
| `SPEI6_Admin2_Zambia_2011_2014_2018.xlsx` | 6-month SPEI in April 2011, 2014 and 2018, mean by district (Figure 1, Panel A) | SPEI Global Drought Monitor, [spei.csic.es](https://spei.csic.es) |
| `SPEI12_Admin2_Zambia_2011_2014_2018.xlsx` | 12-month SPEI in April 2011, 2014 and 2018, mean by district (Figure 1, Panel B) | as above |
| `shapefiles/zmb_admbnda_adm2_dmmu_20201124.*` | District (admin level 2) boundaries of Zambia (`.shp`, `.shx`, `.dbf`, `.prj`) | Zambia administrative boundaries (DMMU, 2020), [OCHA HDX](https://data.humdata.org/dataset/cod-ab-zmb) |

The RALS is household-level microdata that cannot be redistributed. It can be requested from IAPRI ([iapri.org.zm](https://www.iapri.org.zm)).

`00_run_all.do` writes `analysis_data.dta` into this folder (the analysis variables built by `stata/01_prepare_data.do`).
