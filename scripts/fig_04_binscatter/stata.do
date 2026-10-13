* scripts/fig_04_binscatter/stata.do
* Binned scatterplots of female labor force participation against GDP per capita:
* (a) the number of bins; (b) what "controlling for region" does to a binscatter.
* Requires binsreg:  net install binsreg, from("https://raw.githubusercontent.com/nppackages/binsreg/master/stata") replace
cd "."                                      // set to the repository root
adopath + "style"
set scheme dvte

import delimited "data/wdi_flfp_xsec.csv", clear
generate lgdp = log10(gdppc_2022)
replace region = "Europe & Central Asia" if region == "North America"
encode region, generate(reg)
tabulate reg, generate(r_)
local W r_2-r_6

* The data-driven number of bins (IMSE-optimal, Cattaneo et al. 2024)
binsregselect flfp_2023 lgdp
local kopt = e(nbinsdpi)
display "binsregselect: IMSE-optimal number of bins = `kopt'"

* Equal-count bin means for 5, kopt and 10 bins
foreach k in 5 `kopt' 10 {
    xtile b`k' = lgdp, nquantiles(`k')
    bysort b`k': egen x`k' = mean(lgdp)
    bysort b`k': egen y`k' = mean(flfp_2023)
}

* Residualized binscatter: what binscatter's controls() option does
regress lgdp i.reg
predict rx, residuals
summarize lgdp, meanonly
replace rx = rx + r(mean)
regress flfp_2023 i.reg
predict ry, residuals
summarize flfp_2023, meanonly
replace ry = ry + r(mean)
xtile br = rx, nquantiles(10)
bysort br: egen xr = mean(rx)
bysort br: egen yr = mean(ry)

* binsreg with region controls, evaluated at the mean of the controls
preserve
binsreg flfp_2023 lgdp `W', nbins(10) savedata(binsreg_dots) replace
use binsreg_dots, clear
keep dots_x dots_fit
generate byte from_binsreg = 1
tempfile dots
save `dots'
restore
append using `dots'

local xl xlabel(3 "$1,000" 4 "$10,000" 5 "$100,000") xtitle("GDP per capita, 2022 (US$, log scale)")

sort lgdp
twoway (scatter flfp_2023 lgdp, mcolor(gs11) msize(vsmall))                       ///
       (connected y5 x5, sort lcolor("181 83 42") mcolor("181 83 42") msymbol(S)) ///
       (connected y`kopt' x`kopt', sort lcolor("31 78 121") mcolor("31 78 121")  ///
            msize(small)),                                                       ///
    `xl' ytitle("Female labor force participation, 2023 (%)")                    ///
    legend(order(2 "5 bins" 3 "`kopt' bins") pos(5) ring(0) cols(1))            ///
    title("(a) Five bins or fourteen", pos(11)) name(a, replace)

twoway (connected y10 x10, sort lcolor(gs7) mcolor(gs7) msize(small))            ///
       (connected yr xr, sort lpattern(dash) lcolor("181 83 42")                ///
            mcolor("181 83 42") msymbol(S) msize(small))                        ///
       (connected dots_fit dots_x, sort lcolor("31 78 121") mcolor("31 78 121") ///
            msize(small)),                                                       ///
    `xl' ytitle("") yscale(range(10 85))                                         ///
    legend(order(1 "No controls" 2 "Residualized on region"                     ///
                 3 "binsreg, region controls") pos(5) ring(0) cols(1))          ///
    title("(b) Controlling for region", pos(11)) name(b, replace)

graph combine a b, ycommon rows(1) xsize(7) ysize(3.4)
graph export "Chapters/Figures/fig_04_binscatter_stata.svg", replace
erase binsreg_dots.dta
