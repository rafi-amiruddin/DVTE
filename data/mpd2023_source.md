# Maddison Project Database (MPD)

DVTE — `mpd2023.csv`

| Field | Value |
|---|---|
| Source | Maddison Project Database, version 2023 (Bolt and van Zanden), Groningen Growth and Development Centre; file `mpd2023_web.xlsx`, sheet "Full data" |
| DOI | [10.34894/INZBF2](https://doi.org/10.34894/INZBF2) |
| License | Creative Commons Attribution 4.0 International (CC BY 4.0) |
| Extracted | 2026-11-10 |
| Coverage | 169 countries, year 1–2022 (23,280 rows); coverage is sparse before 1820 and complete for all 169 countries from 1950 |
| Columns | `countrycode` (ISO 3166-1 alpha-3), `country`, `region` (Maddison's eight regions), `year`, `gdppc`, `pop` |
| Units | `gdppc`: real GDP per capita in 2011 international dollars. `pop`: population in thousands |
| Scope | All countries and years as released. Country-years with neither GDP per capita nor population (blank rows in the "Full data" sheet) are dropped; no value is altered |
| Missing values | Empty, not zero |
| SHA-256 | `dbcb671483a7b46e8f66ccc14c8c0d0e7c067a1e6a65fb5c98979d7ca150fa8b` |
| Build script | `scripts/freeze_maddison_vdem.py` |
| Citation | Bolt, J. and van Zanden, J. L. (2024), "Maddison style estimates of the evolution of the world economy: A new 2023 update," *Journal of Economic Surveys*, 1–41. DOI: 10.1111/joes.12618 |
| Caution | MPD GDP per capita is in 2011 prices; PWT 11.0 and WDI `NY.GDP.PCAP.PP.KD` use 2021 PPPs. Levels from the three sources are not interchangeable. Use MPD for long-run comparisons and growth paths, not for levels beside PWT or WDI on one axis |

## Revision history

| Date | Change |
|---|---|
| November 10, 2026 | First frozen extract. The first upload kept the sheet's 107,864 blank country-years (131,144 rows); this version drops them |
