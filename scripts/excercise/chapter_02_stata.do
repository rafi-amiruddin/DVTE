*! =============================================================================
*! ECO346 — Data Visualization Techniques for Economists
*! Chapter 2: One Grammar, Three Dialects — Stata
*!
*! Run this from top to bottom. Every example builds on the one before it.
*! Nothing is saved to disk; each graph opens in the Graph window, replacing
*! the one before it.
*!
*! CLOUD USERS: Stata is not available on Google Colab or most free cloud
*! notebooks. If your institution provides Stata through a remote desktop or
*! a hosted server, this file runs there unchanged — it reads the data over
*! https and needs no local files. If you have no Stata access at all, work
*! through the R or Python file instead; the ideas are the same and the book
*! makes the same points in all three.
*!
*! Stata 16 or later is required to read a file directly from a URL.
*! =============================================================================

clear all
set more off


*! -----------------------------------------------------------------------------
*! 1. READING THE DATA
*!
*! The URL below points at a frozen extract in the book's repository. It does
*! not change, needs no account or API key, and works from anywhere. This is
*! the same address the R and Python scripts use.
*! -----------------------------------------------------------------------------

import delimited ///
    "https://raw.githubusercontent.com/rafi-amiruddin/DVTE/main/data/wdi_panel.csv", ///
    clear

* Always look at a table before plotting it.

describe                // columns, types, and how many observations
list in 1/6             // the first six rows
codebook country, compact

* One row is one country in one year. 15 countries x 36 years = 540 rows.
* That shape — one row per observation, one column per variable — is what
* every plotting layer in every one of the three languages expects.

* A note on names. Stata lowercases column names on import and will not
* accept some characters that R and Python allow. Check `describe` output
* against the CSV header if a variable seems to be missing.


*! -----------------------------------------------------------------------------
*! 2. THE FIRST GRAPH
*!
*! Stata has no plot object to build up and no canvas to paint on. A graph
*! command names the geometry, the variables, and the options, and draws
*! the whole thing in one statement.
*!
*! The grammar reads BACKWARDS from R: in `twoway line y x`, the y variable
*! comes FIRST. This catches everyone at least once.
*! -----------------------------------------------------------------------------

twoway scatter lfp_female year

* Every country in one cloud. A real figure, from one command.

twoway line lfp_female year

* The line is wrong: Stata does not know the rows belong to different
* countries, so it connects all 540 points in dataset order. Grouping has to
* be supplied explicitly, and Stata offers no `hue`-style shortcut.


*! -----------------------------------------------------------------------------
*! 3. GEOMETRY AND LAYERS
*!
*! Each parenthesised term is a layer. Layers are listed one after another
*! (or separated with ||) and drawn onto the same axes.
*! -----------------------------------------------------------------------------

twoway (scatter lfp_female year) (line lfp_female year)

* Two geometries, one mapping, one set of axes. This is the closest Stata
* comes to ggplot2's `+`, and structurally it is a genuine analogue.

* Layers can also carry their own data subset, which is how grouping is done
* by hand:

twoway (line lfp_female year if country == "Pakistan") ///
       (line lfp_female year if country == "India")

* Workable for two countries. Unworkable for fifteen — which is exactly why
* the facet slot (section 6) exists.


*! -----------------------------------------------------------------------------
*! 4. SETTING A FIXED VALUE
*!
*! Stata has no within-layer MAPPING of a variable to colour. What it has is
*! SETTING: options that fix a colour, width, or pattern for a whole layer.
*! -----------------------------------------------------------------------------

twoway line lfp_female year if country == "Pakistan", ///
    lcolor(navy) lwidth(medthick)

* Because there is no shared syntax for mapping and setting, the two cannot
* be confused the way they can in R — where a constant placed inside aes()
* silently produces a one-level legend. Stata trades that safety for the
* inability to say "colour varies by country" in a single option.


*! -----------------------------------------------------------------------------
*! 5. SCALES
*!
*! A scale controls the axis range, where ticks fall, and whether the
*! mapping is linear or transformed. In Stata these are graph OPTIONS, split
*! across two names that overlap confusingly.
*! -----------------------------------------------------------------------------

* Default: Stata picks the range from the data.

twoway line lfp_female year if country == "Pakistan"

* Explicit ticks. ylabel() sets where labels appear, and in practice usually
* widens the axis to fit them:

twoway line lfp_female year if country == "Pakistan", ///
    ylabel(0(25)100)

* yscale() sets the range itself. The two are often used together:

twoway line lfp_female year if country == "Pakistan", ///
    ylabel(0(25)100) yscale(range(0 100))

* Note: yscale(range()) ZOOMS. It does not delete observations outside the
* range. R's scale_y_continuous(limits = ...) DOES delete, which is a real
* trap for anyone moving between the two languages.

* Transformations act on the scale, not on the column:

twoway line gdppc_ppp year if country == "Pakistan", ///
    yscale(log) ytitle("GDP per capita, PPP (log scale)")

* The underlying variable is untouched. Only its rendering changed.


*! -----------------------------------------------------------------------------
*! 6. FACETING WITH by()
*!
*! Fifteen lines on one axis is a tangle. by() splits the graph into small
*! multiples — one panel per group, sharing axes so panels stay comparable.
*!
*! In Stata, by() is the nearest thing to a mapping: it is how a variable
*! gets turned into visual structure. But it produces panels, not colours.
*! -----------------------------------------------------------------------------

twoway line lfp_female year, by(country)

* cols() controls the grid. Five columns and fifteen countries gives 3 x 5:

twoway line lfp_female year, by(country, cols(5))

* by() adds a note at the foot of the graph by default. note("") removes it:

twoway line lfp_female year, by(country, cols(5) note(""))


*! -----------------------------------------------------------------------------
*! 7. SCHEMES — Stata's version of a theme
*!
*! A scheme controls everything that is not data: fonts, gridlines, colours,
*! background, plot region borders.
*!
*! This is where the analogy with the other two languages BREAKS. In R and
*! Python a theme is attached to one figure and swapped per plot. In Stata a
*! scheme is a session-level setting: it applies to every graph drawn after
*! it, until changed again.
*! -----------------------------------------------------------------------------

set scheme s2color        // Stata's long-standing default
twoway line lfp_female year, by(country, cols(5) note(""))

set scheme s1mono         // black and white, common for journal submission
twoway line lfp_female year, by(country, cols(5) note(""))

* Stata 18 and later also offer the `stcolor` family:
* set scheme stcolor
* set scheme stgcolor

set scheme s2color        // put it back before continuing


*! -----------------------------------------------------------------------------
*! 8. EVERYTHING AT ONCE
*!
*! The figure that appears in the book. Every option below corresponds to
*! one slot of the grammar: geometry, facet, scale, and labels.
*! -----------------------------------------------------------------------------

twoway (line lfp_female year), ///
    by(country, cols(5) note("")) ///
    ytitle("Female labour force participation (%)") ///
    xtitle("Year")  

* Compare this with the R and Python versions of the same figure. The layout
* is the same because the slots are the same. The syntax shares almost
* nothing.


*! -----------------------------------------------------------------------------
*! 9. TRY IT YOURSELF
*!
*! The panel is not only about labour force participation. Other columns:
*!   gdppc_ppp   GDP per capita, PPP (constant 2021 international $)
*!   gdp_growth  GDP growth, annual %
*!   inflation   Inflation, consumer prices, annual %
*!   life_exp    Life expectancy at birth
*!   internet    Individuals using the internet, % of population
*!
*! Exercise: rebuild the figure in section 8 for `internet`. Ask yourself
*! whether a 0–100 scale still makes sense, and whether the answer would
*! change if you used `gdppc_ppp` instead.
*! -----------------------------------------------------------------------------
