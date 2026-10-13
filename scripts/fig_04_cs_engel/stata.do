* scripts/fig_04_cs_engel/stata.do
* Engel curves for food, Pakistan, HIES 2018-19: food share against monthly consumption
* per person, rural and urban. (a) consumption from all sources; (b) purchases only.
* Stata cannot rasterize one layer of a vector graph, so the 24,808-point cloud makes a
* large SVG; export PNG instead if file size matters.
cd "."                                      // set to the repository root
adopath + "style"
set scheme dvte

* Weighted local linear fit, tricube weights on the nearest span*n points
mata:
real colvector loessfit(real colvector X, real colvector Y, real colvector W,
                        real colvector G, real scalar span)
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
        A  = J(n, 1, 1), (X :- G[i])
        b  = invsym(cross(A, w, A)) * cross(A, w, Y)
        f[i] = b[1]
    }
    return(f)
}
end

import delimited "data/hies_hh_subset.csv", clear
generate double pc_purch = total_purch / hhsize / 12
generate double lx_a  = ln(pc_exp_month)
generate double pct_a = 100 * food_share
generate double lx_b  = ln(pc_purch) if pc_purch > 0
generate double pct_b = 100 * food_share_purch if pc_purch > 0
generate byte rural = area == "rural"

local xl xlabel(`=ln(2000)' "2,000" `=ln(5000)' "5,000" `=ln(10000)' "10,000"     ///
                `=ln(20000)' "20,000" `=ln(50000)' "50,000")                        ///
         xscale(range(`=ln(1000)' `=ln(60000)')) yscale(range(0 80)) ylabel(0(10)80)  ///
         xtitle("Consumption per person (Rs a month, log scale)")

foreach v in a b {
    local title = cond("`v'" == "a", "(a) All sources", "(b) Purchases only")
    local ytl = cond("`v'" == "a", "Food share of consumption (%)", "")
    foreach r in 1 0 {
        local s = cond(`r', "r", "u")
        * Ten bins holding equal shares of the weighted households, within area
        sort rural lx_`v'
        by rural: generate double cw = sum(hhweight) if lx_`v' < .
        by rural: egen double tw = max(cw)
        generate byte bin_`v'`s' = min(floor(cw / tw * 10), 9) if rural == `r' & lx_`v' < .
        drop cw tw
        generate double wx = hhweight * lx_`v'
        generate double wy = hhweight * pct_`v'
        bysort bin_`v'`s': egen double sw = total(hhweight)
        by bin_`v'`s': egen double sx = total(wx)
        by bin_`v'`s': egen double sy = total(wy)
        by bin_`v'`s': generate double bx_`v'`s' = sx / sw if _n == 1 & !missing(bin_`v'`s')
        generate double by_`v'`s' = sy / sw if bx_`v'`s' < .
        drop wx wy sw sx sy
        * Smoother on a 100-point grid between the first and last bin means
        summarize bx_`v'`s', meanonly
        local lo = r(min)
        local hi = r(max)
        generate double g_`v'`s' = `lo' + (_n - 1) * (`hi' - `lo') / 99 in 1/100
        generate double f_`v'`s' = .
        generate byte use = rural == `r' & lx_`v' < .
        mata: X = st_data(., "lx_`v'", "use"); Y = st_data(., "pct_`v'", "use");      ///
              W = st_data(., "hhweight", "use"); G = st_data((1, 100), "g_`v'`s'");   ///
              st_store((1, 100), "f_`v'`s'", loessfit(X, Y, W, G, 0.3))
        drop use
        local x`s' = cond(`r', `lo', `hi')
        local y`s' = cond(`r', f_`v'`s'[1], f_`v'`s'[100])
    }
    twoway (scatter pct_`v' lx_`v', msymbol(p) mcolor(gs8%5))                        ///
           (line f_`v'r g_`v'r, sort lcolor("181 83 42") lwidth(medthick))                ///
           (line f_`v'u g_`v'u, sort lcolor("31 78 121") lwidth(medthick))                ///
           (scatter by_`v'r bx_`v'r, mcolor("181 83 42") msize(small))               ///
           (scatter by_`v'u bx_`v'u, mcolor("31 78 121") msize(small)),              ///
        `xl' ytitle("`ytl'")                                                        ///
        text(`yr' `xr' "Rural ", placement(w) color("181 83 42") size(small))        ///
        text(`yu' `xu' " Urban", placement(e) color("31 78 121") size(small))        ///
        legend(off) title("`title'", pos(11)) name(`v', replace)
}

graph combine a b, rows(1) ycommon xsize(7) ysize(3.8)
graph export "Chapters/Figures/fig_04_cs_engel_stata.svg", replace
