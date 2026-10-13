* scripts/fig_04_age_earnings/stata.do
* Monthly earnings by age, PSLM 2019-20: (a) three conditional averages; (b) conditional spread.
cd "."                                      // set to the repository root
adopath + "style"
set scheme dvte

import delimited "data/pslm_hh_subset.csv", clear
keep hhid hhweight
tempfile hh
save `hh'

import delimited "data/pslm_person_subset.csv", clear
merge m:1 hhid using `hh', keep(master match) nogenerate
keep if earn_month > 0 & inrange(age, 15, 64)
generate double lny = ln(earn_month)

* collapse accepts pweights for means and percentiles alike
collapse (mean) mean = earn_month (mean) lny                                    ///
         (p10) p10 = earn_month (p25) p25 = earn_month (p50) p50 = earn_month    ///
         (p75) p75 = earn_month (p90) p90 = earn_month [pweight = hhweight], by(age)
generate geomean = exp(lny)
list age mean geomean p10 p25 p50 p75 p90 if inlist(age, 25, 40, 55), noobs

local ylab yscale(log range(2000 120000)) ///
    ylabel(2000 "2,000" 10000 "10,000" 100000 "100,000", angle(0))

twoway (connected mean age, lcolor("181 83 42") mcolor("181 83 42") msize(vsmall)) ///
       (connected geomean age, lcolor("31 78 121") mcolor("31 78 121") msize(vsmall)) ///
       (connected p50 age, lcolor(gs7) mcolor(gs7) msize(vsmall)),                  ///
    `ylab' xtitle("Age (years)") ytitle("Monthly earnings (Rs, log scale)")         ///
    legend(order(1 "Mean" 2 "Geometric mean" 3 "Median") pos(11) ring(0) cols(1))  ///
    title("(a) Which average?", pos(11)) name(a, replace)

twoway (rarea p10 p90 age, color("31 78 121%15") lwidth(none))                    ///
       (rarea p25 p75 age, color("31 78 121%30") lwidth(none))                    ///
       (line p50 age, connect(stairstep) lcolor(gs3)),                           ///
    `ylab' xtitle("Age (years)") ytitle("")                                       ///
    legend(order(1 "10th to 90th percentile" 2 "25th to 75th percentile"          ///
                 3 "Median") pos(11) ring(0) cols(1))                             ///
    title("(b) How spread out?", pos(11)) name(b, replace)

graph combine a b, ycommon rows(1) xsize(7) ysize(3.4)
graph export "Chapters/Figures/fig_04_age_earnings_stata.svg", replace
