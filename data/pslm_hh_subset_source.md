# PSLM 2019-20 — Household-Level Teaching Subset

DVTE — `pslm_hh_subset.csv`

| Field | Value |
|---|---|
| Source | Pakistan Bureau of Statistics, Pakistan Social and Living Standards Measurement Survey (PSLM) 2019-20, district level |
| Derived from | `pslm_hh.csv` (full cleaned household-level file) |
| Sampling unit | Household |
| Sampling method | Stratified by province × urban/rural × district, target ~12% of households per stratum, floored so every district in the full data remains represented (minimum 30 households per district, or all households if the district has fewer than 30) |
| Random seed | 20260913 (fixed, for reproducibility) |
| Weights | `hhweight`. Because small districts are deliberately over-represented relative to their true population share (to keep every district visible on a map), any population-weighted statistic on this subset must use `hhweight` — an unweighted figure will be biased in a way the full file is not |
| Use case | Fast download for classroom exercises. For analysis requiring full-sample precision or unbiased unweighted statistics, use `pslm_hh.csv` |
| Sections covered | Identifiers and weights, household demography, housing/water/sanitation (Section F), household-level income streams (Section E Part B), durable assets (Section H), food insecurity experience scale (Section K) |
| Key variables | `hhid`, `psu`, `prov_code`, `dist_code`, `urban_rural`, `hhweight`, `hh_size`, `n_female`, `n_child`, `head_age`, housing and water/sanitation items (`tenure`, `water_source`, `water_improved`, `toilet_flush`, etc.), household income streams (`hh_inc_remit_dom`, `hh_inc_remit_for`, `hh_inc_rent`, `hh_inc_other`, with `discordant_*` flags), 35 durable-asset ownership and quantity items, and `fies_raw` (0-8, requires all 8 FIES items answered) |
| Known judgement calls | `water_improved` follows the JMP service ladder but excludes bottled water (code 16), which JMP only counts as improved alongside a verified secondary source; household income streams use `max()` across household members with a `discordant_*` flag for the ~3-6% of households where reporters disagreed rather than a true sum; `fies_raw` is set to missing unless all 8 items were answered, rather than treating unanswered items as zero |
