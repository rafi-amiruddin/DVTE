# scripts/fig_04_overplot/r.R
# Monthly earnings by age, PSLM 2019-20: four answers to overplotting.
library(tidyverse)
library(scales)
library(patchwork)
library(hexbin)                             # needed by geom_hex()

setwd(".")                                  # set to the repository root
source("style/theme_dvte.R")
theme_set(theme_dvte)

pp <- read_csv("data/pslm_person_subset.csv")
hh <- read_csv("data/pslm_hh_subset.csv") |> select(hhid, hhweight)
e  <- pp |> left_join(hh, by = "hhid") |> filter(earn_month > 0, between(age, 15, 64))
ties <- count(e, age, earn_month)

# How many people hide behind each plotted point?
cat("earners:", nrow(e), " distinct points:", nrow(ties),
    " share at points shared by 10+:", round(sum(ties$n[ties$n >= 10]) / nrow(e), 2),
    " largest stack:", max(ties$n), "\n")

y_rs  <- scale_y_log10(labels = label_comma())
frame <- coord_cartesian(xlim = c(14, 65), ylim = c(1e3, 1e6))
lab   <- labs(x = "Age (years)", y = "Monthly earnings (Rs, log scale)")

set.seed(346)
pa <- ggplot(e, aes(age, earn_month)) + geom_point(size = 0.5, colour = "#1f4e79") +
  y_rs + frame + lab + ggtitle("(a) One point per earner")

# Jitter height is in log10 units, because position adjustments run after the scale transform
pb <- ggplot(e, aes(age, earn_month)) +
  geom_jitter(width = 0.5, height = 0.04, size = 0.4, alpha = 0.08, colour = "#1f4e79") +
  y_rs + frame + lab + ggtitle("(b) Jittered and transparent")

pc <- ggplot(ties, aes(age, earn_month, size = n)) +
  geom_point(alpha = 0.5, colour = "#1f4e79") +
  scale_size_area(max_size = 4, guide = "none") +
  y_rs + frame + lab + ggtitle("(c) Area proportional to count")

pd <- ggplot(e, aes(age, earn_month)) +
  geom_hex(aes(weight = hhweight), binwidth = c(2, 0.17)) +   # widths: 2 years, 0.17 log10 units
  scale_fill_distiller(palette = "Blues", direction = 1, trans = "log10",
                       labels = label_comma(), name = "Earners\nrepresented") +
  y_rs + frame + lab + ggtitle("(d) Hexagonal bins, weighted")

p <- (pa + pb) / (pc + pd) & theme(axis.title = element_text(size = 8))
ggsave("Chapters/Figures/fig_04_overplot_R.svg", p, width = 7, height = 5.6)
