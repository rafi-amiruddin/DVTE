# scripts/fig_04_form/r.R
# A smoother as the referee for a functional form:
# (a) linear and quadratic fits of female labor force participation on log GDP per capita;
# (b) a quadratic in age for log earnings, PSLM 2019-20, against the age means and a smoother.
library(tidyverse)
library(scales)
library(patchwork)

setwd(".")                                  # set to the repository root
source("style/theme_dvte.R")
theme_set(theme_dvte)

# (a) Countries --------------------------------------------------------------------------
x <- read_csv("data/wdi_flfp_xsec.csv") |>
  drop_na(gdppc_2022, flfp_2023) |>
  mutate(lgdp = log10(gdppc_2022))
gx <- tibble(lgdp = seq(min(x$lgdp), max(x$lgdp), length.out = 200))
lin  <- lm(flfp_2023 ~ lgdp, data = x)
quad <- lm(flfp_2023 ~ lgdp + I(lgdp^2), data = x)
smo  <- loess(flfp_2023 ~ lgdp, data = x, span = 0.75, degree = 1,
              family = "gaussian", surface = "direct")
cat("linear slope:", round(coef(lin)[2], 2), "; correlation:", round(cor(x$lgdp, x$flfp_2023), 2), "\n")
tp <- -coef(quad)[2] / (2 * coef(quad)[3])
cat("quadratic minimum at", dollar(10^tp), "\n")

fits_a <- bind_rows(
  mutate(gx, fit = predict(lin, gx),  line = "Linear"),
  mutate(gx, fit = predict(quad, gx), line = "Quadratic"),
  mutate(gx, fit = predict(smo, gx),  line = "Smoother, span 0.75"))

# (b) Earners ----------------------------------------------------------------------------
pp <- read_csv("data/pslm_person_subset.csv")
hh <- read_csv("data/pslm_hh_subset.csv") |> select(hhid, hhweight)
e  <- pp |> left_join(hh, by = "hhid") |>
  filter(earn_month > 0, between(age, 15, 64)) |>
  mutate(ly = log(earn_month))

q_age <- lm(ly ~ age + I(age^2), data = e, weights = hhweight)
cat("quadratic peak at age", round(-coef(q_age)[2] / (2 * coef(q_age)[3]), 1), "\n")

m <- e |>
  group_by(age) |>
  summarise(ly = weighted.mean(ly, hhweight), w = sum(hhweight), n = n()) |>
  mutate(heaped = if_else(age %% 5 == 0, "Age ending in 0 or 5", "Age mean"))

# A weighted local linear fit to the age means equals one fitted to the earners
s_age <- loess(ly ~ age, data = m, weights = w, span = 0.3, degree = 1,
               family = "gaussian", surface = "direct")
ga <- tibble(age = seq(15, 64.75, by = 0.25))
fits_b <- bind_rows(
  mutate(ga, fit = predict(q_age, ga), line = "Quadratic"),
  mutate(ga, fit = predict(s_age, ga), line = "Smoother, span 0.3"))
cat("smoother peak at age", ga$age[which.max(predict(s_age, ga))], "\n")

line_cols <- c("Linear" = "#b5532a", "Quadratic" = "grey25", "Smoother, span 0.75" = "#1f4e79",
               "Smoother, span 0.3" = "#1f4e79")
line_types <- c("Linear" = "dashed", "Quadratic" = "dotted", "Smoother, span 0.75" = "solid",
                "Smoother, span 0.3" = "solid")

pa <- ggplot(fits_a, aes(lgdp, fit)) +
  geom_point(data = x, aes(lgdp, flfp_2023), colour = "grey70", size = 0.8) +
  geom_line(aes(colour = line, linetype = line), linewidth = 0.7) +
  scale_colour_manual(values = line_cols, name = NULL) +
  scale_linetype_manual(values = line_types, name = NULL) +
  scale_x_continuous(breaks = 3:5, labels = dollar(10^(3:5))) +
  labs(x = "GDP per capita, 2022 (US$, log scale)",
       y = "Female labor force participation, 2023 (%)", title = "(a) A line through a U") +
  theme(legend.position = c(0.7, 0.15))

pb <- ggplot(fits_b, aes(age, fit)) +
  geom_point(data = m, aes(age, ly, size = n, fill = heaped), shape = 21, stroke = 0, alpha = 0.8) +
  geom_line(aes(colour = line, linetype = line), linewidth = 0.7) +
  scale_fill_manual(values = c("Age mean" = "grey55", "Age ending in 0 or 5" = "#b5532a"), name = NULL) +
  scale_size_area(max_size = 4, guide = "none") +
  scale_colour_manual(values = line_cols, name = NULL) +
  scale_linetype_manual(values = line_types, name = NULL) +
  scale_y_continuous(breaks = log(c(10000, 15000, 20000, 25000)), labels = label_comma()(c(10000, 15000, 20000, 25000)),
                     limits = log(c(7000, 30000))) +
  labs(x = "Age (years)", y = "Monthly earnings (Rs, geometric mean, log scale)",
       title = "(b) A quadratic in age") +
  theme(legend.position = c(0.72, 0.25), legend.spacing.y = unit(0, "pt"))

ggsave("Chapters/Figures/fig_04_form_R.svg", pa + pb, width = 7, height = 3.4)
