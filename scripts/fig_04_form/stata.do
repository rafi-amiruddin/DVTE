* scripts/fig_04_form/stata.do
* A smoother as the referee for a functional form:
* (a) linear and quadratic fits of female labor force participation on log GDP per capita;
* (b) a quadratic in age for log earnings, PSLM 2019-20, against the age means and a smoother.
cd "."                                      // set to the repository root
adopath + "style"
set scheme dvte

* Local polynomial with tricube weights on the nearest span*n points, times weights W
* (as in scripts/fig_04_span/stata.do)
mata:
real colvector loessfit(real colvector X, real colvector Y, real colvector W,
                        real colvector G, real scalar span, real scalar deg)
{
    real scalar n, q, i, h
    real colvector d, ds, w, f, b
    real matrix A
    n = rows(X)
    q = floor(span * n)
    f = J(rows(G), 1, .)
    for (i = 1; i <= rows(G); i++) {
        d  = abs(X :- G[i])
        ds = sort(d, 1)
        h  = ds[q] * 1.0000001
        w  = ((1 :- (d :/ h):^3) :* (d :< h)):^3 :* W
        A  = J(n, 1, 1)
        if (deg >= 1) A = A, (X :- G[i])
        if (deg >= 2) A = A, (X :- G[i]):^2
        b  = invsym(cross(A, w, A)) * cross(A, w, Y)
        f[i] = b[1]
    }
    return(f)
}
end

* (a) Countries --------------------------------------------------------------------------
import delimited "data/wdi_flfp_xsec.csv", clear
drop if missing(gdppc_2022, flfp_2023)
generate lgdp = log10(gdppc_2022)
generate byte touse = 1
correlate lgdp flfp_2023
regress flfp_2023 lgdp
regress flfp_2023 c.lgdp##c.lgdp
display "quadratic minimum at $" %9.0fc 10^(-_b[lgdp] / (2 * _b[c.lgdp#c.lgdp]))

summarize lgdp, meanonly
local lo = r(min)
local hi = r(max)
set obs 200
replace touse = 0 if missing(touse)
generate double g = `lo' + (_n - 1) * (`hi' - `lo') / 199
generate double sm75 = .
mata: X = st_data(., "lgdp", "touse"); Y = st_data(., "flfp_2023", "touse");  ///
      st_store(., "sm75", loessfit(X, Y, J(rows(X), 1, 1), st_data(., "g"), 0.75, 1))

twoway (scatter flfp_2023 lgdp, mcolor(gs11) msize(vsmall))                    ///
       (lfit flfp_2023 lgdp, lcolor("181 83 42") lpattern(dash))               ///
       (qfit flfp_2023 lgdp, lcolor(gs4) lpattern(shortdash))                  ///
       (line sm75 g, lcolor("31 78 121") lwidth(medthick)),                    ///
    xlabel(3 "$1,000" 4 "$10,000" 5 "$100,000")                                ///
    xtitle("GDP per capita, 2022 (US$, log scale)")                           ///
    ytitle("Female labor force participation, 2023 (%)")                      ///
    legend(order(2 "Linear" 3 "Quadratic" 4 "Smoother, span 0.75")            ///
           pos(5) ring(0) cols(1))                                            ///
    title("(a) A line through a U", pos(11)) name(a, replace)

* (b) Earners ----------------------------------------------------------------------------
import delimited "data/pslm_hh_subset.csv", clear
keep hhid hhweight
tempfile hh
save `hh'
import delimited "data/pslm_person_subset.csv", clear
merge m:1 hhid using `hh', keep(master match) nogenerate
keep if earn_month > 0 & inrange(age, 15, 64)
generate double ly = ln(earn_month)

regress ly c.age##c.age [pweight = hhweight]
local b0 = _b[_cons]
local b1 = _b[age]
local b2 = _b[c.age#c.age]
display "quadratic peak at age " %4.1f -`b1' / (2 * `b2')

bysort age: egen double w = total(hhweight)
bysort age: generate n = _N
collapse (mean) ly (first) w n [aweight = hhweight], by(age)
generate byte heaped = mod(age, 5) == 0
generate byte touse = 1
set obs 200
replace touse = 0 if missing(touse)
generate double ga = 15 + (_n - 1) * 0.25
generate double quad = `b0' + `b1' * ga + `b2' * ga^2
generate double sm30 = .
mata: X = st_data(., "age", "touse"); Y = st_data(., "ly", "touse");           ///
      W = st_data(., "w", "touse");                                            ///
      st_store(., "sm30", loessfit(X, Y, W, st_data(., "ga"), 0.3, 1))
summarize sm30
list ga sm30 if sm30 == r(max)

twoway (scatter ly age if !heaped [aweight = n], msymbol(O) mcolor(gs9%80) mlwidth(none))   ///
       (scatter ly age if heaped [aweight = n], msymbol(O) mcolor("181 83 42%80") mlwidth(none)) ///
       (line quad ga, lcolor(gs4) lpattern(shortdash))                         ///
       (line sm30 ga, lcolor("31 78 121") lwidth(medthick)),                   ///
    yscale(range(`=ln(7000)' `=ln(30000)'))                                    ///
    ylabel(`=ln(10000)' "10,000" `=ln(15000)' "15,000" `=ln(20000)' "20,000"   ///
           `=ln(25000)' "25,000", angle(0))                                    ///
    xtitle("Age (years)") ytitle("Monthly earnings (Rs, geometric mean, log scale)") ///
    legend(order(1 "Age mean" 2 "Age ending in 0 or 5" 3 "Quadratic"           ///
                 4 "Smoother, span 0.3") pos(5) ring(0) cols(1))              ///
    title("(b) A quadratic in age", pos(11)) name(b, replace)

graph combine a b, rows(1) xsize(7) ysize(3.4)
graph export "Chapters/Figures/fig_04_form_stata.svg", replace
