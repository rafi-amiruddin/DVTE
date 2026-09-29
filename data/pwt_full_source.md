# Penn World Table (PWT)

DVTE — `pwt_full.csv`

| Field | Value |
|---|---|
| Source | Penn World Table, version 11.0 (Feenstra, Inklaar, Timmer), Groningen Growth and Development Centre |
| Coverage | 185 countries, 1950–2023 (13,690 rows) |
| Scope | Full table, unfiltered — every country and every variable as released |
| Encoding and precision | UTF-8; all values at full precision as released. Population (`pop`) and employment (`emp`) are in millions, so small countries have values below 1 |
| Variable names | As in this release. The national-accounts series are named `rgdp`, `rcon`, `rda`, `rn`, `rk`, `rtfp`, `rwtfp` (earlier versions of this file used `rgdpna`, `rconna`, `rdana`, `rnna`, `rkna`, `rtfpna`, `rwtfpna`) |
| Notes | Incorporates the World Bank's 2021 ICP purchasing power parities (revised back to 2017). China's series is the official national-accounts series, not the Maddison/Wu-adjusted series used in PWT 10.01 — figures built on 10.01 will not match this version for China |
| Variable subsetting | Not pre-filtered. Country and variable selection happens visibly in chapter code (see Chapter 5), not in this file |
| Citation | Feenstra, R. C., Inklaar, R. and Timmer, M. P. (2015), "The Next Generation of the Penn World Table," *American Economic Review*, 105(10), 3150-3182, available for download at [www.ggdc.net/pwt](https://www.ggdc.net/pwt) |
| Caution | PWT real GDP series are PPP-adjusted on a different benchmark than WDI's `NY.GDP.PCAP.PP.KD`. Do not plot a PWT and a WDI series on the same axis without noting this |

## Revision history

| Date | Change |
|---|---|
| September 13, 2026 | First frozen extract |
| September 2026 | Re-exported from the original PWT 11.0 release. The earlier file had been saved through Excel, which wrote every numeric value as displayed and rounded it to a whole number: population and employment below 0.5 million became 0, and the human capital index was stored as an integer. Any figure built on the earlier file should be regenerated |
