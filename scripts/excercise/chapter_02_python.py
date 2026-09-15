"""
=============================================================================
ECO346 — Data Visualization Techniques for Economists
Chapter 2: One Grammar, Three Dialects — Python

Run this from top to bottom. Every example builds on the one before it.
Nothing is saved to disk; each figure is displayed with plt.show().

CLOUD USERS (Google Colab, Posit Cloud, Kaggle, Binder): this script needs
no local files. It reads the data over https from the book's public
repository, so it runs identically on your machine and in a browser.
pandas, matplotlib and seaborn are pre-installed on Colab. If a package is
missing elsewhere, uncomment the install line below and run it once.

NOTEBOOK USERS: in Jupyter or Colab, figures appear inline automatically
and plt.show() is optional — but harmless, and it keeps this script
runnable as a plain .py file too.
=============================================================================
"""

# !pip install pandas matplotlib seaborn        # run once if needed

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Note the import line above: it is matplotlib.PYPLOT that is aliased as plt,
# not matplotlib itself. `import matplotlib as plt` is a common slip and
# produces a confusing AttributeError on the first plt.subplots() call.


# -----------------------------------------------------------------------------
# 1. READING THE DATA
#
# The URL below points at a frozen extract in the book's repository. It does
# not change, needs no account or API key, and works from anywhere. This is
# the same address the R and Stata scripts use.
# -----------------------------------------------------------------------------

wdi = pd.read_csv(
    "https://raw.githubusercontent.com/rafi-amiruddin/DVTE/main/data/wdi_panel.csv"
)

# Always look at a table before plotting it.

print(wdi.shape)        # rows and columns
print(wdi.columns.tolist())
print(wdi.head())

# One row is one country in one year. 15 countries x 36 years = 540 rows.
# That shape — one row per observation, one column per variable — is what
# every plotting layer in every one of the three languages expects.


# -----------------------------------------------------------------------------
# 2. THE CANVAS
#
# Python has no plot "object" to build up the way R does. matplotlib gives
# you a FIGURE (the page) holding one or more AXES (the panels), and you draw
# onto the axes by calling methods on them. Each call draws immediately.
# -----------------------------------------------------------------------------

fig, ax = plt.subplots(figsize=(6, 4))
plt.show()

# An empty panel. Nothing has been mapped and nothing drawn — but unlike R,
# there is no object here waiting to be extended. `ax` is a surface, and the
# next line will paint on it.


# -----------------------------------------------------------------------------
# 3. DATA, MAPPING AND GEOMETRY — all in one call
#
# In matplotlib these three grammar slots are not separable. ax.plot() takes
# the data (two columns), the mapping (first argument is x, second is y) and
# the geometry (the method name: plot for lines, scatter for points) at once.
# -----------------------------------------------------------------------------

fig, ax = plt.subplots(figsize=(6, 4))
ax.scatter(wdi["year"], wdi["lfp_female"])
plt.show()

# Every country in one cloud. A real figure, from one call.

fig, ax = plt.subplots(figsize=(6, 4))
ax.plot(wdi["year"], wdi["lfp_female"])
plt.show()

# The line is wrong: matplotlib does not know the rows belong to different
# countries, so it connects all 540 points in file order. Grouping has to be
# supplied — and this is where seaborn earns its place.


# -----------------------------------------------------------------------------
# 4. SEABORN AND GROUPING
#
# seaborn sits on top of matplotlib and understands data frames. It takes a
# `data=` argument and column NAMES, and it knows what a group is.
# -----------------------------------------------------------------------------

fig, ax = plt.subplots(figsize=(6, 4))
sns.lineplot(data=wdi, x="year", y="lfp_female", hue="country", ax=ax)
plt.show()

# `hue` maps colour to a column — one line per country, coloured, with a
# legend. Fifteen categories is too many to read, which is a real lesson in
# itself, and the reason faceting exists (section 7 below).


# -----------------------------------------------------------------------------
# 5. MAPPING VS SETTING
#
# MAPPING: the channel varies BY a column. In seaborn: hue=, size=, style=.
# SETTING: the channel is one fixed value. In seaborn: color=, linewidth=.
# -----------------------------------------------------------------------------

fig, ax = plt.subplots(figsize=(6, 4))
sns.lineplot(data=wdi, x="year", y="lfp_female", hue="country", ax=ax)
ax.set_title("Mapping: colour varies by country")
plt.show()

fig, ax = plt.subplots(figsize=(6, 4))
sns.lineplot(data=wdi, x="year", y="lfp_female", color="steelblue", ax=ax)
ax.set_title("Setting: one fixed colour, no grouping")
plt.show()

# Python separates the two with different keywords entirely — `hue` for
# mapping, `color` for setting — so they are harder to confuse than in R,
# where both live in the same function and only the position (inside or
# outside aes()) tells them apart.

# To group WITHOUT colouring, use units= with estimator=None:

fig, ax = plt.subplots(figsize=(6, 4))
sns.lineplot(data=wdi, x="year", y="lfp_female", units="country",
             estimator=None, color="steelblue", ax=ax)
plt.show()


# -----------------------------------------------------------------------------
# 6. SCALES
#
# A scale controls the axis range, where ticks fall, and whether the mapping
# is linear or transformed. In matplotlib these are methods on the axes.
# -----------------------------------------------------------------------------

# Default: matplotlib picks the range from the data.

fig, ax = plt.subplots(figsize=(6, 4))
sns.lineplot(data=wdi, x="year", y="lfp_female", units="country",
             estimator=None, color="steelblue", ax=ax)
ax.set_title("Default limits")
plt.show()

# Explicit range and ticks. Female LFP is a percentage, so 0–100 is the
# honest range even though no country reaches either end.

fig, ax = plt.subplots(figsize=(6, 4))
sns.lineplot(data=wdi, x="year", y="lfp_female", units="country",
             estimator=None, color="steelblue", ax=ax)
ax.set_ylim(0, 100)
ax.set_yticks(range(0, 101, 25))
ax.set_title("Limits 0–100, ticks every 25")
plt.show()

# Note: set_ylim() ZOOMS. It does not delete data outside the range. R's
# scale_y_continuous(limits = ...) does delete, which is a genuine trap for
# anyone moving between the two languages.

# Transformations act on the SCALE, not on the column:

fig, ax = plt.subplots(figsize=(6, 4))
sns.lineplot(data=wdi, x="year", y="gdppc_ppp", units="country",
             estimator=None, color="steelblue", ax=ax)
ax.set_yscale("log")
ax.set_ylabel("GDP per capita, PPP (log scale)")
plt.show()

# The underlying column is untouched. Only its rendering changed.


# -----------------------------------------------------------------------------
# 7. FACETING
#
# Fifteen lines on one axis is a tangle. seaborn's relplot() splits the plot
# into small multiples — one panel per group, sharing axes so panels stay
# comparable.
#
# IMPORTANT: relplot() creates its OWN figure. Do not call plt.subplots()
# first and do not pass ax=. This is the one place in this script where the
# figure is not made by hand.
# -----------------------------------------------------------------------------

g = sns.relplot(data=wdi, x="year", y="lfp_female",
                col="country", col_wrap=5, kind="line")
plt.show()

# col_wrap=5 with fifteen countries gives a 3 x 5 grid.


# -----------------------------------------------------------------------------
# 8. THEME
#
# Theme controls everything that is not data: fonts, gridlines, background.
# seaborn sets themes globally, for every figure that follows.
# -----------------------------------------------------------------------------

sns.set_theme(style="darkgrid")     # seaborn's familiar grey-grid look

g = sns.relplot(data=wdi, x="year", y="lfp_female",
                col="country", col_wrap=5, kind="line")
plt.show()

# Other styles worth trying: "whitegrid", "ticks", "white".
# sns.set_theme() with no arguments restores seaborn's default.


# -----------------------------------------------------------------------------
# 9. EVERYTHING AT ONCE
#
# The figure that appears in the book. Labelling a faceted grid needs care:
# relplot puts a label on every panel by default, so the per-panel labels are
# cleared and one shared pair is set for the whole figure.
# -----------------------------------------------------------------------------

sns.set_theme(style="darkgrid")

g = sns.relplot(data=wdi, x="year", y="lfp_female",
                col="country", col_wrap=5, kind="line")
g.set_titles("{col_name}")

for ax in g.axes.flat:              # clear the repeated per-panel labels
    ax.set_xlabel("")
    ax.set_ylabel("")

g.figure.set_size_inches(9, 6)
g.figure.supxlabel("Year")
g.figure.supylabel("Female labour force participation (%)")
g.figure.tight_layout(rect=[0.03, 0.03, 1, 1])   # margin for the shared labels
plt.show()


# -----------------------------------------------------------------------------
# 10. TRY IT YOURSELF
#
# The panel is not only about labour force participation. Other columns:
#   gdppc_ppp   GDP per capita, PPP (constant 2021 international $)
#   gdp_growth  GDP growth, annual %
#   inflation   Inflation, consumer prices, annual %
#   life_exp    Life expectancy at birth
#   internet    Individuals using the internet, % of population
#
# Exercise: rebuild the figure in section 9 for `internet`. Ask yourself
# whether the 0–100 scale limit still makes sense, and whether the answer
# would change if you used `gdppc_ppp` instead.
# -----------------------------------------------------------------------------
