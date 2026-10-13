# scripts/fig_04_age_earnings/r.R
# Monthly earnings by age, PSLM 2019-20: (a) three conditional averages; (b) conditional spread.
library(tidyverse)
library(scales)
library(patchwork)

setwd(".")                                  # set to the repository root
source("style/theme_dvte.R")
theme_set(theme_dvte)

pp <- read_csv("data/pslm_person_subset.csv")
hh <- read_csv("data/pslm_hh_subset.csv") |> select(hhid, hhweight)
e  <- pp |> left_join(hh, by = "hhid") |> filter(earn_month > 0, between(age, 15, 64))

# Weighted quantile: smallest value whose cumulative weight share reaches q
wquantile <- function(v, w, q) {
  o <- order(v); v <- v[o]; w <- w[o]
  v[which(cumsum(w) / sum(w) >= q)[1]]
}

by_age <- e |>
  group_by(age) |>
  summarise(mean    = weighted.mean(earn_month, hhweight),
            geomean = exp(weighted.mean(log(earn_month), hhweight)),
            p10 = wquantile(earn_month, hhweight, 0.10),
            p25 = wquantile(earn_month, hhweight, 0.25),
            p50 = wquantile(earn_month, hhweight, 0.50),
            p75 = wquantile(earn_month, hhweight, 0.75),
            p90 = wquantile(earn_month, hhweight, 0.90))
print(filter(by_age, age %in% c(25, 40, 55)))

y_rs <- scale_y_log10(labels = label_comma(), limits = c(2e3, 1.2e5))

pa <- by_age |>
  pivot_longer(c(mean, geomean, p50), names_to = "stat") |>
  mutate(stat = recode(stat, mean = "Mean", geomean = "Geometric mean", p50 = "Median")) |>
  ggplot(aes(age, value, colour = stat)) +
  geom_line() + geom_point(size = 0.8) +
  scale_colour_manual(values = c("Mean" = "#b5532a", "Geometric mean" = "#1f4e79",
                                 "Median" = "grey40"), name = NULL) +
  y_rs + labs(x = "Age (years)", y = "Monthly earnings (Rs, log scale)",
              title = "(a) Which average?") +
  theme(legend.position = c(0.25, 0.85))

pb <- ggplot(by_age, aes(age)) +
  geom_ribbon(aes(ymin = p10, ymax = p90), fill = "#1f4e79", alpha = 0.15) +
  geom_ribbon(aes(ymin = p25, ymax = p75), fill = "#1f4e79", alpha = 0.30) +
  geom_step(aes(y = p50), direction = "mid", colour = "grey20") +
  y_rs + labs(x = "Age (years)", y = NULL, title = "(b) How spread out?",
              caption = "Bands: 10th-90th and 25th-75th percentiles; line: median")

ggsave("Chapters/Figures/fig_04_age_earnings_R.svg", pa + pb, width = 7, height = 3.4)
