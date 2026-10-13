# scripts/fig_04_cs_redesign/r.R
# Redesign of the case-study figure: one panel, each decile drawn twice. A filled point marks
# consumption from all sources, an open point purchases only, and an arrow joins them.
library(tidyverse)
library(scales)

setwd(".")                                  # set to the repository root
source("style/theme_dvte.R")
theme_set(theme_dvte)

h <- read_csv("data/hies_hh_subset.csv") |>
  mutate(pc_purch = total_purch / hhsize / 12) |>
  filter(pc_purch > 0)

# Means in ten bins holding equal shares of the weighted households
wdeciles <- function(d, x, y, k = 10) {
  d |> arrange({{ x }}) |>
    mutate(bin = pmin(floor(cumsum(hhweight) / sum(hhweight) * k), k - 1)) |>
    group_by(bin) |>
    summarise(x = weighted.mean({{ x }}, hhweight), y = weighted.mean({{ y }}, hhweight))
}

shift <- h |>
  mutate(la = log(pc_exp_month), lp = log(pc_purch),
         sa = 100 * food_share, sp = 100 * food_share_purch) |>
  group_by(area) |>
  group_modify(~ inner_join(wdeciles(.x, la, sa), wdeciles(.x, lp, sp),
                            by = "bin", suffix = c("_all", "_purch"))) |>
  ungroup()
shift |>
  group_by(area) |>
  summarise(fall_min = min(100 * (1 - exp(x_purch - x_all))),
            fall_max = max(100 * (1 - exp(x_purch - x_all))),
            dshare_min = min(y_purch - y_all), dshare_max = max(y_purch - y_all)) |>
  print()

cols <- c(rural = "#b5532a", urban = "#1f4e79")
p <- ggplot(shift, aes(colour = area)) +
  geom_segment(aes(x = x_all, y = y_all, xend = x_purch, yend = y_purch),
               arrow = arrow(length = unit(0.12, "cm"), type = "open"), linewidth = 0.35) +
  geom_point(aes(x_all, y_all, shape = "All sources"), size = 1.8) +
  geom_point(aes(x_purch, y_purch, shape = "Purchases only"), size = 1.8, fill = "white") +
  geom_text(data = filter(shift, bin == 9), aes(x_all, y_all, label = str_to_title(area)),
            hjust = -0.25, fontface = "bold", size = 3) +
  scale_colour_manual(values = cols, guide = "none") +
  scale_shape_manual(values = c("All sources" = 16, "Purchases only" = 21), name = NULL) +
  scale_x_continuous(breaks = log(c(2000, 5000, 10000, 20000)),
                     labels = comma(c(2000, 5000, 10000, 20000)),
                     expand = expansion(mult = c(0.03, 0.14))) +
  labs(x = "Consumption per person (Rs a month, log scale)",
       y = "Food share of consumption (%)",
       title = "Counting purchases only moves every decile") +
  theme(legend.position = c(0.82, 0.88))

ggsave("Chapters/Figures/fig_04_cs_redesign_R.svg", p, width = 6, height = 4)
