# scripts/fig_04_paths/r.R
# Between and within countries: female labor force participation and GDP per capita,
# 15 Asian and African countries, 1990-2025. (a) country averages; (b) each country's path.
library(tidyverse)
library(scales)
library(patchwork)

setwd(".")                                  # set to the repository root
source("style/theme_dvte.R")
theme_set(theme_dvte)

d <- read_csv("data/wdi_panel.csv") |>
  drop_na(gdppc_ppp, lfp_female) |>
  arrange(country, year) |>
  mutate(lgdp = log10(gdppc_ppp))

# Between: country means.  Within: slope with country fixed effects.
m <- d |> group_by(country) |> summarise(lgdp = mean(lgdp), lfp_female = mean(lfp_female))
cat("between slope:", round(coef(lm(lfp_female ~ lgdp, data = m))[2], 1),
    "; within slope:", round(coef(lm(lfp_female ~ lgdp + country, data = d))[2], 1), "\n")

d <- d |>
  group_by(country) |>
  mutate(direction = if_else(last(lfp_female) > first(lfp_female), "Rising", "Falling")) |>
  ungroup()
ends <- d |> group_by(country) |> slice_tail(n = 1) |> ungroup()
print(select(ends, country, year, gdppc_ppp, lfp_female, direction))

x_ppp <- scale_x_continuous(breaks = log10(c(1000, 3000, 10000, 30000)),
                            labels = dollar(c(1000, 3000, 10000, 30000)))
dir_cols <- scale_colour_manual(values = c(Rising = "#1f4e79", Falling = "#b5532a"), guide = "none")

pa <- ggplot(m, aes(lgdp, lfp_female)) +
  geom_smooth(method = "lm", formula = y ~ x, se = FALSE, colour = "#b5532a", linewidth = 0.7) +
  geom_point(colour = "#1f4e79", size = 1.2) +
  geom_text(aes(label = country), size = 2.2, hjust = -0.1, vjust = -0.3) +
  x_ppp + coord_cartesian(xlim = range(d$lgdp) + c(0, 0.3), ylim = c(10, 90)) +
  labs(x = "GDP per capita (2021 PPP $, log scale)", y = "Female labor force participation (%)",
       title = "(a) Between: country averages")

pb <- ggplot(d, aes(lgdp, lfp_female, colour = direction, group = country)) +
  geom_path(linewidth = 0.4) +
  geom_point(data = ends, size = 1) +
  geom_text(data = ends, aes(label = country), size = 2.2, hjust = -0.1, vjust = -0.3) +
  dir_cols + x_ppp + coord_cartesian(xlim = range(d$lgdp) + c(0, 0.3), ylim = c(10, 90)) +
  labs(x = "GDP per capita (2021 PPP $, log scale)", y = NULL,
       title = "(b) Within: each country, 1990-2025")

ggsave("Chapters/Figures/fig_04_paths_R.svg", pa + pb, width = 7, height = 3.6)
