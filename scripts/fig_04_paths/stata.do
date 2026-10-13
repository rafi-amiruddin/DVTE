* scripts/fig_04_paths/stata.do
* Between and within countries: female labor force participation and GDP per capita,
* 15 Asian and African countries, 1990-2025. (a) country averages; (b) each country's path.
cd "."                                      // set to the repository root
adopath + "style"
set scheme dvte

import delimited "data/wdi_panel.csv", clear
drop if missing(gdppc_ppp, lfp_female)
generate lgdp = log10(gdppc_ppp)
encode country, generate(cid)
xtset cid year

* Between (country means) and within (fixed effects) slopes
xtreg lfp_female lgdp, be
xtreg lfp_female lgdp, fe

* Direction of each country's change, first to last year
bysort cid (year): generate rising = lfp_female[_N] > lfp_female[1]
bysort cid (year): generate byte last = _n == _N
list country year gdppc_ppp lfp_female rising if last, noobs

local xl xlabel(3 "$1,000" `=log10(3000)' "$3,000" 4 "$10,000" `=log10(30000)' "$30,000") ///
         xscale(range(2.9 4.85)) yscale(range(10 90)) ylabel(25(25)75)                    ///
         xtitle("GDP per capita (2021 PPP $, log scale)")

* (a) Between: country means with a linear fit
preserve
collapse (mean) lgdp lfp_female, by(country)
twoway (lfit lfp_female lgdp, lcolor("181 83 42") lwidth(medthick))           ///
       (scatter lfp_female lgdp, mcolor("31 78 121") mlabel(country)           ///
            mlabsize(vsmall) mlabcolor(black)),                                ///
    `xl' ytitle("Female labor force participation (%)") legend(off)            ///
    title("(a) Between: country averages", pos(11)) name(a, replace)
restore

* (b) Within: one line per country, colored by the direction of its change
local paths
levelsof cid, local(ids)
foreach c of local ids {
    quietly summarize rising if cid == `c', meanonly
    local col = cond(r(mean) == 1, `""31 78 121""', `""181 83 42""')
    local paths `paths' (line lfp_female lgdp if cid == `c', sort(year) lcolor(`col') lwidth(thin))
}
twoway `paths'                                                                 ///
       (scatter lfp_female lgdp if last & rising, mcolor("31 78 121")          ///
            mlabel(country) mlabsize(vsmall) mlabcolor("31 78 121"))           ///
       (scatter lfp_female lgdp if last & !rising, mcolor("181 83 42")         ///
            mlabel(country) mlabsize(vsmall) mlabcolor("181 83 42")),          ///
    `xl' ytitle("") legend(off)                                                ///
    title("(b) Within: each country, 1990-2025", pos(11)) name(b, replace)

graph combine a b, rows(1) ycommon xsize(7) ysize(3.6)
graph export "Chapters/Figures/fig_04_paths_stata.svg", replace
