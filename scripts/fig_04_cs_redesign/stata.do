* scripts/fig_04_cs_redesign/stata.do
* Redesign of the case-study figure: one panel, each decile drawn twice. A filled point marks
* consumption from all sources, an open point purchases only, and an arrow joins them.
cd "."                                      // set to the repository root
adopath + "style"
set scheme dvte

import delimited "data/hies_hh_subset.csv", clear
generate double pc_purch = total_purch / hhsize / 12
keep if pc_purch > 0
generate double x_all   = ln(pc_exp_month)
generate double y_all   = 100 * food_share
generate double x_purch = ln(pc_purch)
generate double y_purch = 100 * food_share_purch

* Ten bins holding equal shares of the weighted households, within area, for each definition
foreach d in all purch {
    sort area x_`d'
    by area: generate double cw = sum(hhweight)
    by area: egen double tw = max(cw)
    generate byte bin_`d' = min(floor(cw / tw * 10), 9)
    drop cw tw
    preserve
    collapse (mean) x_`d' y_`d' [aweight = hhweight], by(area bin_`d')
    rename bin_`d' bin
    tempfile b_`d'
    save `b_`d''
    restore
}
use `b_all', clear
merge 1:1 area bin using `b_purch', nogenerate
generate fall   = 100 * (1 - exp(x_purch - x_all))
generate dshare = y_purch - y_all
tabstat fall dshare, by(area) statistics(min max)

local r "181 83 42"
local u "31 78 121"
twoway (pcarrow y_all x_all y_purch x_purch if area == "rural", lcolor("`r'") mcolor("`r'") msize(small)) ///
       (pcarrow y_all x_all y_purch x_purch if area == "urban", lcolor("`u'") mcolor("`u'") msize(small)) ///
       (scatter y_all x_all if area == "rural", mcolor("`r'") msymbol(O))                    ///
       (scatter y_all x_all if area == "urban", mcolor("`u'") msymbol(O))                    ///
       (scatter y_purch x_purch if area == "rural", mcolor("`r'") msymbol(Oh))               ///
       (scatter y_purch x_purch if area == "urban", mcolor("`u'") msymbol(Oh))               ///
       (scatter y_all x_all if bin == 9, msymbol(none) mlabel(area) mlabposition(3)        ///
            mlabcolor(black) mlabsize(small)),                                              ///
    xlabel(`=ln(2000)' "2,000" `=ln(5000)' "5,000" `=ln(10000)' "10,000" `=ln(20000)' "20,000") ///
    xtitle("Consumption per person (Rs a month, log scale)")                                ///
    ytitle("Food share of consumption (%)")                                                 ///
    legend(order(3 "All sources" 5 "Purchases only") pos(1) ring(0) cols(1))               ///
    title("Counting purchases only moves every decile", pos(11))
graph export "Chapters/Figures/fig_04_cs_redesign_stata.svg", replace
