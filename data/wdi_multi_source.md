# World Development Indicators (WDI): multi-indicator panel

DVTE — `wdi_multi.csv`, with `countries.csv`

| Field | Value |
|---|---|
| Source | World Bank, World Development Indicators (API source 2), via the Python package wbgapi |
| WDI release | Database last updated 2026-10-08 |
| Extracted | 2026-11-10 |
| License | Creative Commons Attribution 4.0 International (CC BY 4.0) |
| Coverage | 217 economies (countries and territories; no regional or income aggregates), 1990–2025, balanced: 7,812 rows (217 × 36) |
| Keys | `iso3` (ISO 3166-1 alpha-3; `XKX` for Kosovo), `country`, `year` |
| Companion file | `countries.csv`: `iso3`, `country`, `region` (World Bank code), `region_name`, `income_group` (`HIC`, `UMC`, `LMC`, `LIC`; Venezuela is unclassified). Region and income group are the classifications in force on the extraction date. Pakistan is in "Middle East, North Africa, Afghanistan & Pakistan" |
| Scope | 34 indicators, values unaltered. A country-year with no value for an indicator is empty, not zero; the latest year with data differs by indicator (see table) |
| SHA-256 | `wdi_multi.csv`: `ced7a993ec29536a15956bb2711cc312f9f146c27845ae87d44f964c7e4d9423`; `countries.csv`: `7ea2cf313a33d6f258a3c673e4e67e013aa0c033b847342fa98e4e7b304457ad` |
| Build script | `scripts/freeze_wdi.py` |
| Consistency | For the 15 countries in `wdi_panel.csv`, `gdppc_ppp`, `lfp_female` and `inflation` agree exactly with that file |
| Citation | World Bank (2026), *World Development Indicators*, database updated October 8, 2026. Washington, DC: The World Bank. https://datacatalog.worldbank.org/dataset/world-development-indicators |
| Caution | Values are as released, including real extremes (DR Congo inflation of 23,773 percent in 1994; Rwanda life expectancy of 12 years in 1994) and source artifacts (Sudan's tax revenue above 600 percent of GDP in 1998–99; Timor-Leste above 100 percent in 2010–12; Palau's CO₂ emissions per capita). Use a log scale or state any exclusion in the caption. `gdppc_ppp` uses 2021 PPPs, like PWT 11.0 but on a different benchmark; Maddison uses 2011 prices |

## Indicators

| Column | WDI code | Indicator | Economies | Last year |
|---|---|---|---|---|
| `gdppc_ppp` | NY.GDP.PCAP.PP.KD | GDP per capita, PPP (constant 2021 international $) | 199 | 2025 |
| `gdppc_usd` | NY.GDP.PCAP.CD | GDP per capita (current US$) | 214 | 2025 |
| `pop` | SP.POP.TOTL | Population, total | 217 | 2025 |
| `urban` | SP.URB.TOTL.IN.ZS | Urban population (% of total) | 217 | 2025 |
| `agri_va` | NV.AGR.TOTL.ZS | Agriculture, forestry, and fishing, value added (% of GDP) | 206 | 2025 |
| `manuf_va` | NV.IND.MANF.ZS | Manufacturing, value added (% of GDP) | 204 | 2025 |
| `trade` | NE.TRD.GNFS.ZS | Trade (% of GDP) | 193 | 2025 |
| `inflation` | FP.CPI.TOTL.ZG | Inflation, consumer prices (annual %) | 193 | 2025 |
| `tax_rev` | GC.TAX.TOTL.GD.ZS | Tax revenue (% of GDP) | 159 | 2024 |
| `remit` | BX.TRF.PWKR.DT.GD.ZS | Personal remittances, received (% of GDP) | 197 | 2025 |
| `lfp_female` | SL.TLF.CACT.FE.ZS | Labor force participation rate, female (% ages 15+, modeled ILO estimate) | 187 | 2025 |
| `lfp_male` | SL.TLF.CACT.MA.ZS | Labor force participation rate, male (% ages 15+, modeled ILO estimate) | 187 | 2025 |
| `unemp` | SL.UEM.TOTL.ZS | Unemployment, total (% of labor force, modeled ILO estimate) | 187 | 2025 |
| `emp_agri` | SL.AGR.EMPL.ZS | Employment in agriculture (% of total employment, modeled ILO estimate) | 187 | 2025 |
| `life_exp` | SP.DYN.LE00.IN | Life expectancy at birth, total (years) | 217 | 2024 |
| `fertility` | SP.DYN.TFRT.IN | Fertility rate, total (births per woman) | 217 | 2024 |
| `adol_fert` | SP.ADO.TFRT | Adolescent fertility rate (births per 1,000 women ages 15–19) | 217 | 2024 |
| `u5mr` | SH.DYN.MORT | Mortality rate, under-5 (per 1,000 live births) | 196 | 2024 |
| `imr` | SP.DYN.IMRT.IN | Mortality rate, infant (per 1,000 live births) | 196 | 2024 |
| `mmr` | SH.STA.MMRT | Maternal mortality ratio (modeled estimate, per 100,000 live births) | 194 | 2023 |
| `stunting` | SH.STA.STNT.ZS | Prevalence of stunting, height for age (% of children under 5) | 163 | 2024 |
| `health_exp` | SH.XPD.CHEX.GD.ZS | Current health expenditure (% of GDP) | 193 | 2024 |
| `prim_net` | SE.PRM.NENR | School enrollment, primary (% net) | 194 | 2019 |
| `sec_gross` | SE.SEC.ENRR | School enrollment, secondary (% gross) | 207 | 2025 |
| `ter_gross` | SE.TER.ENRR | School enrollment, tertiary (% gross) | 200 | 2025 |
| `lit_adult` | SE.ADT.LITR.ZS | Literacy rate, adult total (% of people ages 15 and above) | 162 | 2024 |
| `lit_female` | SE.ADT.LITR.FE.ZS | Literacy rate, adult female (% of females ages 15 and above) | 163 | 2024 |
| `gini` | SI.POV.GINI | Gini index | 171 | 2025 |
| `pov_intl` | SI.POV.DDAY | Poverty headcount ratio at $3.00 a day (2021 PPP) (% of population) | 171 | 2025 |
| `electricity` | EG.ELC.ACCS.ZS | Access to electricity (% of population) | 216 | 2024 |
| `water_basic` | SH.H2O.BASW.ZS | People using at least basic drinking water services (% of population) | 214 | 2024 |
| `internet` | IT.NET.USER.ZS | Individuals using the Internet (% of population) | 213 | 2025 |
| `women_parl` | SG.GEN.PARL.ZS | Proportion of seats held by women in national parliaments (%) | 193 | 2025 |
| `co2_pc` | EN.GHG.CO2.PC.CE.AR5 | Carbon dioxide (CO₂) emissions excluding LULUCF per capita (t CO₂e/capita) | 203 | 2024 |

Survey-based series (`stunting`, `lit_adult`, `lit_female`, `gini`, `pov_intl`, `prim_net`) are observed only in survey years and are sparse: use the most recent value within a stated window, not a single year, for cross-sections.

## Revision history

| Date | Change |
|---|---|
| November 10, 2026 | First frozen extract |
