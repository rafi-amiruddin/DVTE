# =============================================================================
# ECO346 — Data Visualization Techniques for Economists
# Chapter 2: One Grammar, Three Dialects — R
#
# Run this from top to bottom. Every example builds on the one before it.
# Nothing is saved to disk; figures appear in the plot pane (or inline, if
# you are in a notebook or on the cloud).
#
# CLOUD USERS (Posit Cloud, Google Colab with an R runtime, RStudio Server):
# this script needs no local files. It reads the data over https from the
# book's public repository, so it runs identically on your machine and in a
# browser. If a package is missing, uncomment the install line below and run
# it once.
# =============================================================================

# install.packages(c("readr", "ggplot2", "dplyr"))   # run once if needed

library(readr)     # read_csv()
library(ggplot2)   # the grammar of graphics
library(dplyr)     # filter(), used in one example near the end


# -----------------------------------------------------------------------------
# 1. READING THE DATA
#
# The URL below points at a frozen extract in the book's repository. It does
# not change, needs no account or API key, and works from anywhere. This is
# the same address the Python and Stata scripts use.
# -----------------------------------------------------------------------------

wdi <- read_csv(
  "https://raw.githubusercontent.com/rafi-amiruddin/DVTE/main/data/wdi_panel.csv"
)

# Always look at a table before plotting it. Three questions: how many rows,
# what are the columns called, and what does one row represent?

dim(wdi)          # rows and columns
names(wdi)        # column names
head(wdi)         # the first six rows

# One row is one country in one year. 15 countries x 36 years = 540 rows.
# That shape — one row per observation, one column per variable — is what
# every plotting layer in every one of the three languages expects.


# -----------------------------------------------------------------------------
# 2. THE DATA SLOT
#
# A ggplot begins by naming the table and nothing else. This creates an
# object. It does not draw anything.
# -----------------------------------------------------------------------------

p <- ggplot(wdi)
p     # an empty canvas: ggplot knows the data, but not what to do with it

# The object exists and can be assigned, inspected, and extended. Nothing is
# rendered until the object is printed. Keep this in mind — it is the single
# biggest difference from Python's matplotlib, where every call draws
# immediately.


# -----------------------------------------------------------------------------
# 3. THE MAPPING SLOT
#
# Mapping assigns a COLUMN to a visual channel: position, colour, size, shape.
# Mappings live inside aes().
# -----------------------------------------------------------------------------

p <- ggplot(wdi, aes(x = year, y = lfp_female))
p     # now there are axes, because x and y have been mapped

# Still no data drawn — a mapping says where things go, not what to draw.


# -----------------------------------------------------------------------------
# 4. THE GEOMETRY SLOT
#
# Geometry is the visual form: points, lines, bars, areas. Layers are added
# with `+`.
# -----------------------------------------------------------------------------

ggplot(wdi, aes(x = year, y = lfp_female)) +
  geom_point()

# That is every country in one cloud, which is not useful yet — but it is a
# real figure, built from exactly three decisions: data, mapping, geometry.

# Layers stack. Two geometries on the same mapping:

ggplot(wdi, aes(x = year, y = lfp_female)) +
  geom_point() +
  geom_line()

# The lines are wrong: ggplot does not know the rows belong to different
# countries, so it connects them all in sequence. That is a grouping problem,
# and grouping is solved by mapping — which is the next idea.


# -----------------------------------------------------------------------------
# 5. MAPPING VS SETTING — the most common beginner error
#
# MAPPING: the channel varies BY a column. It goes inside aes().
# SETTING: the channel is a fixed value. It goes outside aes().
# -----------------------------------------------------------------------------

# Mapping colour to country. Note this also fixes the grouping problem above:
# once colour varies by country, ggplot draws one line per country.

ggplot(wdi, aes(x = year, y = lfp_female, colour = country)) +
  geom_line()

# Setting colour to a fixed value. Every line is the same colour, and the
# grouping problem returns, because nothing tells ggplot the rows differ.

ggplot(wdi, aes(x = year, y = lfp_female)) +
  geom_line(colour = "steelblue")

# The classic mistake — a constant inside aes(). This does NOT error. It
# creates a one-level legend for a value that never varies, which looks like
# it worked and did not. Run it and read the legend:

ggplot(wdi, aes(x = year, y = lfp_female, colour = "steelblue")) +
  geom_line()

# If grouping is all you want, without colour, map `group` instead:

ggplot(wdi, aes(x = year, y = lfp_female, group = country)) +
  geom_line()


# -----------------------------------------------------------------------------
# 6. THE SCALE SLOT
#
# A scale controls how a mapped variable becomes a visual value: the axis
# range, where ticks fall, and whether the mapping is linear or transformed.
# -----------------------------------------------------------------------------

# Default: ggplot picks the range from the data.

ggplot(wdi, aes(x = year, y = lfp_female, group = country)) +
  geom_line()

# Explicit range and ticks. Female LFP is a percentage, so 0–100 is the
# honest range even though no country reaches either end.

ggplot(wdi, aes(x = year, y = lfp_female, group = country)) +
  geom_line() +
  scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, 25))

# A WARNING specific to R. `limits` inside a scale does not zoom — it DROPS
# observations outside the range before anything is drawn. Compare:

ggplot(wdi, aes(x = year, y = lfp_female, group = country)) +
  geom_line() +
  scale_y_continuous(limits = c(40, 60))       # data outside 40–60 is deleted

ggplot(wdi, aes(x = year, y = lfp_female, group = country)) +
  geom_line() +
  coord_cartesian(ylim = c(40, 60))            # data kept, view zoomed

# The second is almost always what you meant. Python's set_ylim() and Stata's
# yscale(range()) both behave like coord_cartesian(), so this trap is R's alone.

# Transformations act on the SCALE, not on the column. GDP per capita is
# skewed enough to show why that matters:

ggplot(wdi, aes(x = year, y = gdppc_ppp, group = country)) +
  geom_line()

ggplot(wdi, aes(x = year, y = gdppc_ppp, group = country)) +
  geom_line() +
  scale_y_log10()

# The underlying column is untouched. Only its rendering changed.


# -----------------------------------------------------------------------------
# 7. THE FACET SLOT
#
# Fifteen lines on one axis is a tangle. Faceting splits one plot into small
# multiples — one panel per group, sharing axes so panels stay comparable.
# -----------------------------------------------------------------------------

ggplot(wdi, aes(x = year, y = lfp_female)) +
  geom_line() +
  facet_wrap(~ country)

# ncol controls the grid. Five columns and fifteen countries gives 3 x 5:

ggplot(wdi, aes(x = year, y = lfp_female)) +
  geom_line() +
  facet_wrap(~ country, ncol = 5)


# -----------------------------------------------------------------------------
# 8. THE THEME SLOT
#
# Theme controls everything that is not data: fonts, gridlines, background,
# panel borders. It never changes what is plotted, only how it looks.
# -----------------------------------------------------------------------------

ggplot(wdi, aes(x = year, y = lfp_female)) +
  geom_line() +
  facet_wrap(~ country, ncol = 5) +
  theme_grey()

# Labels are not part of the theme — they are content, and they are the
# difference between a figure a reader can use and one they cannot.

ggplot(wdi, aes(x = year, y = lfp_female)) +
  geom_line() +
  facet_wrap(~ country, ncol = 5) +
  labs(
    x = "Year",
    y = "Female labour force participation (%)"
  ) +
  theme_grey()


# -----------------------------------------------------------------------------
# 9. ALL SIX SLOTS AT ONCE
#
# The figure that appears in the book. Every line below is one slot of the
# grammar, in order: data, mapping, geometry, facet, scale, labels, theme.
# -----------------------------------------------------------------------------

ggplot(wdi, aes(x = year, y = lfp_female)) +          # data + mapping
  geom_line(colour = "steelblue", linewidth = 0.6) +  # geometry
  facet_wrap(~ country, ncol = 5) +                   # facet
  scale_y_continuous(limits = c(0, 100)) +            # scale
  labs(x = "Year",
       y = "Female labour force participation (%)") + # labels
  theme_grey(base_size = 9)                        # theme


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
