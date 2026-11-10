# World Development Indicators: multi-indicator panel

- Source: World Bank, World Development Indicators (API source 2)
- Database last updated (API): 2026-10-08
- Frozen on: 2026-11-10
- License: CC BY 4.0
- Coverage: 217 economies, 1990-2025
- Output: `wdi_multi.csv` (7,812 rows, 37 columns)
- Output SHA-256: `ced7a993ec29536a15956bb2711cc312f9f146c27845ae87d44f964c7e4d9423`
- countries.csv SHA-256: `7ea2cf313a33d6f258a3c673e4e67e013aa0c033b847342fa98e4e7b304457ad`
- Region and income group are the classifications in force on the freeze date.

## Indicators

| Column | WDI code | Name |
|---|---|---|
| `gdppc_ppp` | NY.GDP.PCAP.PP.KD | GDP per capita, PPP (constant 2021 international $) |
| `gdppc_usd` | NY.GDP.PCAP.CD | GDP per capita (current US$) |
| `pop` | SP.POP.TOTL | Population, total |
| `urban` | SP.URB.TOTL.IN.ZS | Urban population (% of total population) |
| `agri_va` | NV.AGR.TOTL.ZS | Agriculture, forestry, and fishing, value added (% of GDP) |
| `manuf_va` | NV.IND.MANF.ZS | Manufacturing, value added (% of GDP) |
| `trade` | NE.TRD.GNFS.ZS | Trade (% of GDP) |
| `inflation` | FP.CPI.TOTL.ZG | Inflation, consumer prices (annual %) |
| `tax_rev` | GC.TAX.TOTL.GD.ZS | Tax revenue (% of GDP) |
| `remit` | BX.TRF.PWKR.DT.GD.ZS | Personal remittances, received (% of GDP) |
| `lfp_female` | SL.TLF.CACT.FE.ZS | Labor force participation rate, female (% of female population ages 15+) (modeled ILO estimate) |
| `lfp_male` | SL.TLF.CACT.MA.ZS | Labor force participation rate, male (% of male population ages 15+) (modeled ILO estimate) |
| `unemp` | SL.UEM.TOTL.ZS | Unemployment, total (% of total labor force) (modeled ILO estimate) |
| `emp_agri` | SL.AGR.EMPL.ZS | Employment in agriculture (% of total employment) (modeled ILO estimate) |
| `life_exp` | SP.DYN.LE00.IN | Life expectancy at birth, total (years) |
| `fertility` | SP.DYN.TFRT.IN | Fertility rate, total (births per woman) |
| `adol_fert` | SP.ADO.TFRT | Adolescent fertility rate (births per 1,000 women ages 15-19) |
| `u5mr` | SH.DYN.MORT | Mortality rate, under-5 (per 1,000 live births) |
| `imr` | SP.DYN.IMRT.IN | Mortality rate, infant (per 1,000 live births) |
| `mmr` | SH.STA.MMRT | Maternal mortality ratio (modeled estimate, per 100,000 live births) |
| `stunting` | SH.STA.STNT.ZS | Prevalence of stunting, height for age (% of children under 5) |
| `health_exp` | SH.XPD.CHEX.GD.ZS | Current health expenditure (% of GDP) |
| `prim_net` | SE.PRM.NENR | School enrollment, primary (% net) |
| `sec_gross` | SE.SEC.ENRR | School enrollment, secondary (% gross) |
| `ter_gross` | SE.TER.ENRR | School enrollment, tertiary (% gross) |
| `lit_adult` | SE.ADT.LITR.ZS | Literacy rate, adult total (% of people ages 15 and above) |
| `lit_female` | SE.ADT.LITR.FE.ZS | Literacy rate, adult female (% of females ages 15 and above) |
| `gini` | SI.POV.GINI | Gini index |
| `pov_intl` | SI.POV.DDAY | Poverty headcount ratio at $3.00 a day (2021 PPP) (% of population) |
| `electricity` | EG.ELC.ACCS.ZS | Access to electricity (% of population) |
| `water_basic` | SH.H2O.BASW.ZS | People using at least basic drinking water services (% of population) |
| `internet` | IT.NET.USER.ZS | Individuals using the Internet (% of population) |
| `women_parl` | SG.GEN.PARL.ZS | Proportion of seats held by women in national parliaments (%) |
| `co2_pc` | EN.GHG.CO2.PC.CE.AR5 | Carbon dioxide (CO2) emissions excluding LULUCF per capita (t CO2e/capita) |
