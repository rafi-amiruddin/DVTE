# hies_hh_subset.csv

One row per household, 24,808 households, PSLM-HIES 2018-19 (Pakistan Bureau of Statistics). Built by `scripts/data_prep/hies_prepare.do` from the raw Stata modules `sec_6a`, `sec_12b`, `sec_00`, `plist` and `weight`, which are not in this repository.

All money values are in current Pakistani rupees. Annual values are built from each item's recall period: fortnightly items ×26, monthly items ×12, annual items ×1.

| Variable | Definition |
|---|---|
| `hhcode` | Household code (10 digits) |
| `province` | Khyber Pakhtunkhwa, Punjab, Sindh, Balochistan |
| `area` | rural or urban |
| `psu` | Primary sampling unit |
| `hhsize` | Number of household members |
| `hhweight` | Household sampling weight (constant within PSU; sums to 33.3 million households) |
| `total_exp` | Annual consumption from all sources, groups 1000-5000, durables excluded |
| `total_purch` | Annual consumption from purchases only (equals `z` in `sec_12b` for all but 57 households) |
| `food_exp` | Annual food consumption from all sources: sub-groups 1001, 1002, 1003, 2001 |
| `food_purch` | Annual food consumption from purchases only, same sub-groups |
| `pc_exp_month` | `total_exp / hhsize / 12`: monthly consumption per person |
| `food_share` | `food_exp / total_exp` |
| `food_share_purch` | `food_purch / total_purch` |
| `durables` | Annual durable goods, all sources (group 6000; not part of `total_exp`) |
| `c1001`-`c1004`, `c2001`, `c2002` | Annual consumption by sub-group, all sources |
| `g4000`, `g5000` | Annual consumption, groups 4000 and 5000, all sources |

"All sources" means purchases, wages and salaries received in kind, own-produced and consumed goods, and gifts or assistance, the last three valued at market prices. This is the PBS definition of consumption expenditure.

## Validation against the PBS report

| | This file (weighted) | PBS 2018-19 |
|---|---|---|
| Mean monthly household consumption, Pakistan | Rs 37,063 | Rs 37,159 |
| Urban | Rs 47,311 | Rs 47,362 |
| Rural | Rs 30,785 | Rs 30,908 |
| Food share, Pakistan | 37.4% | 36.05% |
| Urban | 32.2% | 30.64% |
| Rural | 42.4% | 41.13% |

Food shares here are spending-weighted (total food divided by total consumption), as in the PBS tables. They are not averages of household shares.

## Caveats

- The sub-group labels are not stored in the data. The food definition is inferred from the earlier HIES coding scheme and from where own-produced consumption appears (dairy and wheat), then checked against the PBS tables. It is about 1.4 points above the PBS food share in both areas, and the urban-rural gap matches. Sub-group 1004 is excluded as probably ready-made food, which PBS counts under restaurants.
- The purchases-only aggregate in `sec_12b` (`z`) omits own-produced and in-kind consumption, which average 22% of consumption (rural 24%, urban 19%). It understates consumption and the food share, most of all for farm households.
- Extremes: monthly consumption per person ranges from about Rs 1,100 to Rs 263,000, and household size from 1 to 55. They are kept.
- Use of these data is subject to the PBS terms of access.
