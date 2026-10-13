# scripts/fig_04_region/r.R
# Female labor force participation against GDP per capita, one panel per region:
# each region's countries in color with a within-region linear fit, all others in grey.
library(tidyverse)
library(scales)

setwd(".")                                  # set to the repository root
source("style/theme_dvte.R")
theme_set(theme_dvte)

x <- read_csv("data/wdi_flfp_xsec.csv") |>
  drop_na(gdppc_2022, flfp_2023) |>
  mutate(lgdp = log10(gdppc_2022),
         reg = recode(region, "North America" = "Europe & Central Asia"),
         reg = recode(reg,
                      "Europe & Central Asia" = "Europe, Central Asia & North America",
                      "Middle East, North Africa, Afghanistan & Pakistan" =
                        "Middle East, North Africa,\nAfghanistan & Pakistan"))

# Pooled and within-region linear slopes (points per tenfold increase in GDP per capita)
cat("pooled slope:", round(coef(lm(flfp_2023 ~ lgdp, data = x))[2], 1),
    "; slope within regions:", round(coef(lm(flfp_2023 ~ lgdp + reg, data = x))[2], 1), "\n")

slopes <- x |>
  group_by(reg) |>
  summarise(n = n(), slope = coef(lm(flfp_2023 ~ lgdp))[2], mean = mean(flfp_2023)) |>
  mutate(label = sprintf("n = %d, slope %+.0f", n, slope))
print(slopes)

p <- ggplot(x, aes(lgdp, flfp_2023)) +
  geom_point(data = select(x, -reg), colour = "grey80", size = 0.6) +   # all countries, every panel
  geom_point(colour = "#1f4e79", size = 1) +
  geom_smooth(method = "lm", formula = y ~ x, se = FALSE, colour = "#b5532a", linewidth = 0.7) +
  geom_text(data = filter(x, country == "Pakistan"), aes(label = country),
            size = 2.5, hjust = -0.15, vjust = -0.4) +
  geom_text(data = slopes, aes(x = Inf, y = -Inf, label = label),
            hjust = 1.05, vjust = -0.6, size = 2.5) +
  facet_wrap(~ reg, ncol = 3) +
  scale_x_continuous(breaks = 3:5, labels = dollar(10^(3:5))) +
  labs(x = "GDP per capita, 2022 (US$, log scale)",
       y = "Female labor force participation, 2023 (%)")

ggsave("Chapters/Figures/fig_04_region_R.svg", p, width = 7, height = 4.6)
