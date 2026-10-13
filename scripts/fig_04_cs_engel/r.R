# scripts/fig_04_cs_engel/r.R
# Engel curves for food, Pakistan, HIES 2018-19: food share against monthly consumption
# per person, rural and urban. (a) consumption from all sources; (b) purchases only.
# The household cloud is rasterized with ggrastr so that the SVG stays small.
library(tidyverse)
library(scales)
library(ggrastr)

setwd(".")                                  # set to the repository root
source("style/theme_dvte.R")
theme_set(theme_dvte)

h <- read_csv("data/hies_hh_subset.csv") |>
  mutate(pc_purch = total_purch / hhsize / 12)

# Long format: one row per household and definition
long <- bind_rows(
  h |> transmute(area, hhweight, def = "(a) All sources",
                 lx = log(pc_exp_month), pct = 100 * food_share),
  h |> filter(pc_purch > 0) |>
    transmute(area, hhweight, def = "(b) Purchases only",
              lx = log(pc_purch), pct = 100 * food_share_purch))

# Means in ten bins holding equal shares of the weighted households
wdeciles <- function(d, k = 10) {
  d |> arrange(lx) |>
    mutate(bin = pmin(floor(cumsum(hhweight) / sum(hhweight) * k), k - 1)) |>
    group_by(bin) |>
    summarise(x = weighted.mean(lx, hhweight), y = weighted.mean(pct, hhweight))
}

# Weighted local linear fit, tricube weights on the nearest span*n points
loess_w <- function(x, y, w, grid, span = 0.3) {
  q <- floor(span * length(x))
  sapply(grid, function(g) {
    d <- abs(x - g)
    h <- sort(d, partial = q)[q] * 1.0000001
    k <- pmax(1 - (d / h)^3, 0)^3 * w
    coef(lm.wfit(cbind(1, x - g), y, k))[1]
  })
}

bins <- long |> group_by(def, area) |> group_modify(~ wdeciles(.x)) |> ungroup()
curves <- long |>
  group_by(def, area) |>
  group_modify(function(d, key) {
    b <- wdeciles(d)
    grid <- seq(min(b$x), max(b$x), length.out = 100)
    tibble(x = grid, y = loess_w(d$lx, d$pct, d$hhweight, grid))
  }) |>
  ungroup()
print(bins |> group_by(def, area) |>
        summarise(poorest = first(y), at = exp(first(x)), richest = last(y), at_r = exp(last(x))))

labels <- curves |>
  group_by(def, area) |>
  slice(if (first(area) == "urban") n() else 1) |>
  mutate(label = str_to_title(area), hj = if_else(area == "urban", -0.15, 1.15))

cols <- c(rural = "#b5532a", urban = "#1f4e79")
p <- ggplot(long, aes(lx, pct)) +
  rasterise(geom_point(colour = "grey50", alpha = 0.05, size = 0.3, stroke = 0), dpi = 300) +
  geom_line(data = curves, aes(x, y, colour = area), linewidth = 0.8) +
  geom_point(data = bins, aes(x, y, colour = area), size = 1.4) +
  geom_text(data = labels, aes(x, y, label = label, colour = area, hjust = hj), size = 2.8) +
  scale_colour_manual(values = cols, guide = "none") +
  scale_x_continuous(breaks = log(c(2000, 5000, 10000, 20000, 50000)),
                     labels = comma(c(2000, 5000, 10000, 20000, 50000))) +
  coord_cartesian(xlim = log(c(1000, 60000)), ylim = c(0, 80)) +
  facet_wrap(~ def) +
  labs(x = "Consumption per person (Rs a month, log scale)",
       y = "Food share of consumption (%)")

ggsave("Chapters/Figures/fig_04_cs_engel_R.svg", p, width = 7, height = 3.8)
