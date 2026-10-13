# scripts/fig_04_flfp_gdp/r.R
# Female labor force participation against GDP per capita: linear axis vs log axis with population bubbles.
library(tidyverse)
library(scales)
library(patchwork)

setwd(".")                                  # set to the repository root
source("style/theme_dvte.R")
theme_set(theme_dvte)

x   <- read_csv("data/wdi_flfp_xsec.csv")
pop <- read_csv("data/pwt_full.csv") |> filter(year == 2023) |> select(countrycode, pop)
x   <- left_join(x, pop, by = c("iso3" = "countrycode"))

pa <- ggplot(x, aes(gdppc_2022 / 1000, flfp_2023)) +
  geom_point(colour = "#1f4e79", size = 1.2, alpha = 0.8) +
  labs(x = "GDP per capita, 2022 (thousand US$)",
       y = "Female labor force participation, 2023 (%)", title = "(a) Linear axis")

# Area proportional to population: scale_size_area(), not scale_size()
pb <- ggplot(drop_na(x, pop) |> arrange(desc(pop)), aes(gdppc_2022, flfp_2023)) +
  geom_point(aes(size = pop), colour = "#1f4e79", alpha = 0.35) +
  geom_text(data = filter(x, iso3 %in% c("PAK", "IND", "CHN")),
            aes(label = country), hjust = -0.2, size = 2.6) +
  scale_size_area(max_size = 14, guide = "none") +
  scale_x_log10(labels = label_dollar()) +
  labs(x = "GDP per capita, 2022 (US$, log scale)", y = NULL,
       title = "(b) Log axis, sized by population")

ggsave("Chapters/Figures/fig_04_flfp_gdp_R.svg", pa + pb, width = 7, height = 3.4)
