* scripts/fig_04_flfp_gdp/stata.do
* Female labor force participation against GDP per capita: linear axis vs log axis with population bubbles.
cd "."                                      // set to the repository root
adopath + "style"
set scheme dvte

import delimited "data/pwt_full.csv", clear
keep if year == 2023
keep countrycode pop
rename countrycode iso3
tempfile pop
save `pop'

import delimited "data/wdi_flfp_xsec.csv", clear
merge 1:1 iso3 using `pop', keep(master match) nogenerate

generate gdp_k = gdppc_2022 / 1000
generate lbl = country if inlist(iso3, "PAK", "IND", "CHN")

scatter flfp_2023 gdp_k, mcolor("31 78 121%80") msize(small)                 ///
    title("(a) Linear axis", pos(11) size(medsmall))                          ///
    xtitle("GDP per capita, 2022 (thousand US$)")                             ///
    ytitle("Female labor force participation, 2023 (%)") name(a, replace)

* [aweight=pop] scales marker area in proportion to population
gsort -pop
twoway (scatter flfp_2023 gdppc_2022 [aweight = pop], msymbol(O)             ///
            mcolor("31 78 121%35") mlcolor(white) mlwidth(vthin))            ///
       (scatter flfp_2023 gdppc_2022 if lbl != "", msymbol(none)             ///
            mlabel(lbl) mlabposition(3) mlabsize(vsmall)),                   ///
    xscale(log) xlabel(1000 "$1,000" 10000 "$10,000" 100000 "$100,000")      ///
    title("(b) Log axis, sized by population", pos(11) size(medsmall))       ///
    xtitle("GDP per capita, 2022 (US$, log scale)") ytitle("") legend(off)   ///
    name(b, replace)

graph combine a b, ycommon rows(1) xsize(7) ysize(3.4)
graph export "Chapters/Figures/fig_04_flfp_gdp_stata.svg", replace
