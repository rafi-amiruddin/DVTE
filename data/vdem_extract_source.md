# Varieties of Democracy (V-Dem)

DVTE — `vdem_extract.csv`

| Field | Value |
|---|---|
| Source | V-Dem Country-Year Dataset v16, Full+Others file (`V-Dem-CY-Full+Others-v16.csv`), V-Dem Institute, University of Gothenburg |
| DOI | [10.23696/vdemds26](https://doi.org/10.23696/vdemds26) |
| License | Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0). This extract is a derivative of the V-Dem dataset and is distributed under the same license; anything derived from this file must carry CC BY-SA 4.0 and cite V-Dem. The license applies to this data file only, not to the rest of the repository |
| Extracted | 2026-11-10 |
| Coverage | 183 political units, 1900–2025 (19,857 rows), including historical units (e.g. `DDR`, `VDR`, `YMD`) and territories (e.g. `PSG`, `PSB`, `SML`, `ZZB`) |
| Identifiers | `country_name`, `country_text_id` (V-Dem's three-letter code, ISO alpha-3 for current states, with `XKX` for Kosovo), `year` |
| Indices (0–1, higher = more of the concept, except `v2x_corr`) | `v2x_polyarchy` electoral democracy; `v2x_libdem` liberal democracy; `v2x_freexp_altinf` freedom of expression and alternative sources of information; `v2x_rule` rule of law; `v2x_corr` political corruption (higher = more corrupt); `v2x_gender` women's political empowerment; `v2x_gencl` women's civil liberties; `v2x_gencs` women's civil society participation; `v2x_genpp` women's political participation |
| Categorical | `v2x_regime`: Regimes of the World, 0 closed autocracy, 1 electoral autocracy, 2 electoral democracy, 3 liberal democracy |
| Scope | Ten indices selected from the full release; values unaltered. The full file (several hundred MB) is not redistributed |
| Missing values | Empty, not zero |
| SHA-256 | `29ca1a5335bc734bf07caaa9b226ffe8b1ee02688a3881ca3f6239b3d346cef0` |
| Build script | `scripts/freeze_maddison_vdem.py` |
| Citation | Coppedge, M., Gerring, J., Knutsen, C. H., Lindberg, S. I., et al. (2026), "V-Dem Country-Year Dataset v16," Varieties of Democracy (V-Dem) Project. https://doi.org/10.23696/vdemds26 |
| Caution | Twenty V-Dem units have no Maddison series (historical states, territories, and a few small or recent states such as `SSD`, `ERI`, `SOM`, `BTN`, `MDV`). A merge with `mpd2023.csv` on code and year drops them |

## Revision history

| Date | Change |
|---|---|
| November 10, 2026 | First frozen extract |
