* scripts/fig_02_flfp_three/stata.do
global root "C:/Users/Rafi/OneDrive - Higher Education Commission/02 COMSATS Assignments/Fall 2026/ECO346 Data Visualization Techniques for Economists/Typst_DVTE_V1"
cd "$root"

import delimited "data/wdi_panel.csv", clear

twoway (line lfp_female year), by(country, note("") cols(5)) ///
    ytitle("Female labour force participation (%)") xtitle("Year")

graph export "Chapters/Figures/fig_02_flfp_stata.svg", as(svg) width(900) height(600) replace