# scripts/fig_02_flfp/r_ggplot2.R
library(ggplot2)
library(readr)

setwd("C:/Users/Rafi/OneDrive - Higher Education Commission/02 COMSATS Assignments/Fall 2026/ECO346 Data Visualization Techniques for Economists/Typst_DVTE_V1")

wdi <- read_csv("data/wdi_panel.csv")

p <- ggplot(wdi, aes(year, lfp_female)) +
  geom_line(colour = "steelblue", linewidth = 0.6) +
  facet_wrap(~ country, ncol = 5) +
  labs(x = "Year", y = "Female labour force participation (%)") +
  theme_grey(base_size = 9) +
  theme(strip.text = element_text(face = "bold"))

ggsave("Chapters/Figures/fig_02_flfp_R.svg", p, width = 9, height = 6)