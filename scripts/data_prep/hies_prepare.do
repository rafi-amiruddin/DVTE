* scripts/data_prep/hies_prepare.do
* Builds data/hies_hh_subset.csv (one row per household) from the raw PSLM-HIES 2018-19
* Stata modules. The raw files are not in the repository; set `raw' to their folder and
* run from the repository root.
*
* Consumption follows PBS: purchases + in-kind wages + own-produced + gifts (columns v1-v4
* of sec_6a), groups 1000-5000, durables (6000) excluded. Validation against the PBS report
* (weighted mean monthly household consumption): ours 37,063 vs PBS 37,159; urban 47,311 vs
* 47,362; rural 30,785 vs 30,908.
*
* Food = sub-groups 1001 + 1002 + 1003 + 2001. Sub-group 1004 (probably ready-made food,
* which PBS counts under restaurants) and 2002 (fuel and household non-durables) are excluded.
* The sub-group labels are not stored in the data; the definition is inferred and checked
* against PBS: weighted food share 37.4% vs PBS 36.05% (urban 32.2 vs 30.64; rural 42.4 vs
* 41.13). The level is about 1.4 points high in both areas; the urban-rural gap matches.

clear all
local raw "C:/path/to/HIES_2018_19"          // folder with the raw .dta modules
local out "data/hies_hh_subset.csv"

* 1. Consumption by group and food sub-group, annual Rs ----------------------------------
use "`raw'/sec_6a.dta", clear
keep if inlist(itc, 1000, 2000, 4000, 5000, 6000, 1001, 1002, 1003, 1004, 2001, 2002)
foreach v in v1 v2 v3 v4 {
    replace `v' = 0 if missing(`v')
}
* Recall periods: 1000 fortnightly (x26); 2000 and 4000 monthly (x12); 5000 and 6000 annual
generate mult = cond(floor(itc/1000) == 1, 26, cond(inlist(floor(itc/1000), 2, 4), 12, 1))
generate double all   = (v1 + v2 + v3 + v4) * mult   // all sources
generate double purch = v1 * mult                    // purchases only
keep hhcode itc all purch
reshape wide all purch, i(hhcode) j(itc)
foreach v of varlist all* purch* {
    replace `v' = 0 if missing(`v')
}

generate double total_exp   = all1000 + all2000 + all4000 + all5000
generate double total_purch = purch1000 + purch2000 + purch4000 + purch5000
generate double food_exp    = all1001 + all1002 + all1003 + all2001
generate double food_purch  = purch1001 + purch1002 + purch1003 + purch2001
generate double durables    = all6000
rename (all1001 all1002 all1003 all1004 all2001 all2002 all4000 all5000) ///
       (c1001 c1002 c1003 c1004 c2001 c2002 g4000 g5000)
keep hhcode total_exp total_purch food_exp food_purch durables ///
     c1001 c1002 c1003 c1004 c2001 c2002 g4000 g5000
tempfile cons
save `cons'

* 2. Analysis sample: households with consumption aggregates in sec_12b --------------------
use "`raw'/sec_12b.dta", clear
keep hhcode
merge 1:1 hhcode using `cons', keep(match) nogenerate
save `cons', replace

* 3. Province, area, PSU -----------------------------------------------------------------
use "`raw'/sec_00.dta", clear
keep hhcode province region psu
tempfile frame
save `frame'

* 4. Household size (every row of plist is a household member) ----------------------------
use "`raw'/plist.dta", clear
collapse (count) hhsize = idc, by(hhcode)
tempfile size
save `size'

* 5. Merge; the weight is constant within PSU and is a household weight --------------------
use `cons', clear
merge 1:1 hhcode using `frame', keep(match) nogenerate
merge 1:1 hhcode using `size',  keep(match) nogenerate
merge m:1 psu using "`raw'/weight.dta", keep(match) nogenerate
rename weight hhweight
drop if total_exp <= 0

* 6. Derived variables -------------------------------------------------------------------
generate double pc_exp_month     = total_exp / hhsize / 12
generate double food_share       = food_exp / total_exp
generate double food_share_purch = food_purch / total_purch
decode province, generate(prov_name)
decode region,   generate(area)
drop province region
rename prov_name province
format hhcode %12.0f

* 7. Checks ------------------------------------------------------------------------------
count                                                       // 24,808
encode area, generate(area_n)
generate double mo_total = total_exp / 12
mean mo_total [pweight = hhweight], over(area_n)            // PBS: urban 47,362; rural 30,908
ratio (food: food_exp / total_exp) [pweight = hhweight]     // PBS: 36.05%
ratio (food: food_exp / total_exp) [pweight = hhweight], over(area_n)
assert inrange(food_share, 0, 1)
isid hhcode
drop area_n mo_total

* 8. Export ------------------------------------------------------------------------------
order hhcode province area psu hhsize hhweight total_exp total_purch food_exp food_purch ///
      pc_exp_month food_share food_share_purch durables c1001 c1002 c1003 c1004 c2001 c2002 ///
      g4000 g5000
export delimited using "`out'", replace
