* scripts/fig_04_region/stata.do
* Female labor force participation against GDP per capita, one panel per region:
* each region's countries in color with a within-region linear fit, all others in grey.
cd "."                                      // set to the repository root
adopath + "style"
set scheme dvte

import delimited "data/wdi_flfp_xsec.csv", clear
drop if missing(gdppc_2022, flfp_2023)
generate lgdp = log10(gdppc_2022)
replace region = "Europe & Central Asia" if region == "North America"
encode region, generate(reg)

* Pooled and within-region linear slopes (points per tenfold increase in GDP per capita)
regress flfp_2023 lgdp
regress flfp_2023 lgdp i.reg

* by() cannot draw the other regions' countries in the background, so build each panel
levelsof reg, local(regions)
local panels
foreach r of local regions {
    local name : label (reg) `r'
    if strpos("`name'", "Middle East") local name `""Middle East, North Africa," "Afghanistan & Pakistan""'
    else if "`name'" == "Europe & Central Asia" local name "Europe, Central Asia & North America"
    else local name `""`name'""'
    quietly regress flfp_2023 lgdp if reg == `r'
    local sign = cond(_b[lgdp] >= 0, "+", "")
    local note : display "n = " e(N) ", slope `sign'" %3.0f _b[lgdp]
    local note = strtrim(subinstr("`note'", "`sign' ", "`sign'", .))
    display `"`name': `note'"'
    twoway (scatter flfp_2023 lgdp, mcolor(gs13) msize(vsmall))                      ///
           (scatter flfp_2023 lgdp if reg == `r', mcolor("31 78 121") msize(small))  ///
           (lfit flfp_2023 lgdp if reg == `r', lcolor("181 83 42") lwidth(medthick)) ///
           (scatter flfp_2023 lgdp if reg == `r' & country == "Pakistan",            ///
                msymbol(none) mlabel(country) mlabsize(vsmall) mlabcolor(black)),     ///
        xlabel(3 "$1,000" 4 "$10,000" 5 "$100,000") ylabel(0(20)80)                  ///
        xtitle("") ytitle("") legend(off) title(`name', size(small) pos(11))         ///
        note("`note'", pos(5) ring(0) size(vsmall)) name(g`r', replace) nodraw
    local panels `panels' g`r'
}

graph combine `panels', rows(2) ycommon xcommon xsize(7) ysize(4.6)              ///
    b1title("GDP per capita, 2022 (US$, log scale)", size(small))                ///
    l1title("Female labor force participation, 2023 (%)", size(small))
graph export "Chapters/Figures/fig_04_region_stata.svg", replace
