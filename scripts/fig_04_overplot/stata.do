* scripts/fig_04_overplot/stata.do
* Monthly earnings by age, PSLM 2019-20: four answers to overplotting.
* Panel (d) needs heatplot from SSC:  ssc install heatplot ; ssc install palettes ; ssc install colrspace
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

local ylab ylabel(1000 "1,000" 10000 "10,000" 100000 "100,000" 1000000 "1,000,000", angle(0))
local frame yscale(log range(1000 1000000)) xscale(range(14 65)) xtitle("Age (years)") ytitle("Monthly earnings (Rs, log scale)")

scatter earn_month age if earn_month <= 1e6, msize(tiny) mcolor("31 78 121")        ///
    `ylab' `frame' title("(a) One point per earner", pos(11)) name(a, replace)

* jitter() is a percentage of the plot region, not a data unit
scatter earn_month age if earn_month <= 1e6, jitter(2) msize(vtiny)                ///
    mcolor("31 78 121%8") `ylab' `frame'                                          ///
    title("(b) Jittered and transparent", pos(11)) name(b, replace)

preserve
contract age earn_month, freq(n)
summarize n
display "distinct points: " r(N) "   largest stack: " r(max)
scatter earn_month age [aweight = n] if earn_month <= 1e6, msymbol(O)               ///
    mcolor("31 78 121%50") mlwidth(none) `ylab' `frame'                           ///
    title("(c) Area proportional to count", pos(11)) name(c, replace)
restore

* Stata has no built-in hexbin; heatplot bins log earnings into hexagons and sums the weights
generate log_earn = log10(earn_month)
heatplot log_earn age [iweight = hhweight] if earn_month <= 1e6, hexagon            ///
    statistic(sum) xbins(25) ybins(18) colors(Blues) legend(off)                  ///
    ylabel(3 "1,000" 4 "10,000" 5 "100,000" 6 "1,000,000", angle(0))                ///
    xtitle("Age (years)") ytitle("Monthly earnings (Rs, log scale)")              ///
    title("(d) Hexagonal bins, weighted", pos(11)) name(d, replace)

graph combine a b c d, rows(2) xsize(7) ysize(5.6)
graph export "Chapters/Figures/fig_04_overplot_stata.svg", replace
