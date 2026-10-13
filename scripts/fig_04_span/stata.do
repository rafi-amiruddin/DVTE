* scripts/fig_04_span/stata.do
* Local regression smoothers of female labor force participation on GDP per capita:
* (a) the span; (b) the degree of the local polynomial, at a fixed span.
cd "."                                      // set to the repository root
adopath + "style"
set scheme dvte

* A local polynomial with tricube weights on the nearest span*n points, as R's
* loess(..., family = "gaussian", surface = "direct"). Stata's lowess is local linear
* only, and lpoly has no tricube kernel and takes a bandwidth in x units, not a span.
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

import delimited "data/wdi_flfp_xsec.csv", clear
drop if missing(gdppc_2022, flfp_2023)
generate lgdp = log10(gdppc_2022)
generate byte touse = 1
summarize lgdp, meanonly
local lo = r(min)
local hi = r(max)
set obs 200                                 // room for a 200-point grid
replace touse = 0 if missing(touse)
generate double g = `lo' + (_n - 1) * (`hi' - `lo') / 199

foreach s in 20_1 75_0 75_1 75_2 {
    local span = real(substr("`s'", 1, 2)) / 100
    local deg  = real(substr("`s'", 4, 1))
    generate double f`s' = .
    mata: X = st_data(., "lgdp", "touse"); Y = st_data(., "flfp_2023", "touse");  ///
          st_store(., "f`s'", loessfit(X, Y, J(rows(X), 1, 1), st_data(., "g"), `span', `deg'))
    summarize f`s', meanonly
    display "span `span', degree `deg': ends " %4.1f f`s'[1] ", " %4.1f f`s'[200] "; minimum " %4.1f r(min)
}

* The default: lowess uses bwidth(0.8), tricube weights, local linear, no robustness iterations
lowess flfp_2023 lgdp, nograph generate(lw80)

local xl xlabel(3 "$1,000" 4 "$10,000" 5 "$100,000") xtitle("GDP per capita, 2022 (US$, log scale)")

twoway (scatter flfp_2023 lgdp, mcolor(gs11) msize(vsmall))                    ///
       (line f20_1 g, lcolor("181 83 42") lwidth(medthin))                     ///
       (line f75_1 g, lcolor("31 78 121") lwidth(medthick)),                   ///
    `xl' ytitle("Female labor force participation, 2023 (%)")                 ///
    legend(order(2 "Span 0.2" 3 "Span 0.75") pos(5) ring(0) cols(1))          ///
    title("(a) The span", pos(11)) name(a, replace)

twoway (scatter flfp_2023 lgdp, mcolor(gs11) msize(vsmall))                    ///
       (line f75_0 g, lcolor("181 83 42") lpattern(dash))                      ///
       (line f75_1 g, lcolor("31 78 121") lwidth(medthick))                    ///
       (line f75_2 g, lcolor(gs4) lpattern(shortdash)),                        ///
    `xl' ytitle("")                                                           ///
    legend(order(2 "Local mean (degree 0)" 3 "Local linear (degree 1)"        ///
                 4 "Local quadratic (degree 2)") pos(5) ring(0) cols(1))     ///
    title("(b) The degree, span 0.75", pos(11)) name(b, replace)

graph combine a b, ycommon rows(1) xsize(7) ysize(3.4)
graph export "Chapters/Figures/fig_04_span_stata.svg", replace
