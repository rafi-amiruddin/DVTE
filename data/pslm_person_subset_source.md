# PSLM 2019-20 — Person-Level Teaching Subset

DVTE — `pslm_person_subset.csv`

| Field | Value |
|---|---|
| Source | Pakistan Bureau of Statistics, Pakistan Social and Living Standards Measurement Survey (PSLM) 2019-20, district level |
| Derived from | `pslm_person.csv` (full cleaned person-level file) |
| Sampling unit | Household — every person in a sampled household is included; this is never a person-level subsample |
| Sampling method | Stratified by province × urban/rural × district, target ~12% of households per stratum, floored so every district in the full data remains represented (minimum 30 households per district, or all households if the district has fewer than 30) |
| Random seed | 20260913 (fixed, for reproducibility) |
| Weights | `hhweight`. Because small districts are deliberately over-represented relative to their true population share (to keep every district visible on a map), any population-weighted statistic on this subset must use `hhweight` — an unweighted figure will be biased in a way the full file is not |
| Use case | Fast download for classroom exercises. For analysis requiring full-sample precision or unbiased unweighted statistics, use `pslm_person.csv` |
| Sections covered | Roster and demography, migration and functional limitation (Section B-2), education (Section C-1), employment and income (Section E) |
| Key variables | `hhid`, `idc`, `age`, `sex`, `marital`, migration and disability items, education and literacy items, employment status and earnings |
