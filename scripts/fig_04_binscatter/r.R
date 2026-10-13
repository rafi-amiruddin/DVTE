# scripts/fig_04_binscatter/r.R
# Binned scatterplots of female labor force participation against GDP per capita:
# (a) the number of bins; (b) what "controlling for region" does to a binscatter.
# Requires: install.packages("binsreg")
library(tidyverse)
library(scales)
library(patchwork)
library(binsreg)

setwd(".")                                  # set to the repository root
source("style/theme_dvte.R")
theme_set(theme_dvte)

x <- read_csv("data/wdi_flfp_xsec.csv") |>
  mutate(lgdp = log10(gdppc_2022),
         reg  = if_else(region == "North America", "Europe & Central Asia", region))

binned_means <- function(xv, yv, k) {
  tibble(x = xv, y = yv, bin = ntile(xv, k)) |>
    group_by(bin) |> summarise(x = mean(x), y = mean(y))
}

# The data-driven number of bins (IMSE-optimal, Cattaneo et al. 2024)
k_opt <- binsregselect(x$flfp_2023, x$lgdp)$nbinsdpi
cat("binsregselect: IMSE-optimal number of bins =", k_opt, "\n")

# Panel (b): three binscatters, ten bins each
res_x <- resid(lm(lgdp ~ reg, x)) + mean(x$lgdp)
res_y <- resid(lm(flfp_2023 ~ reg, x)) + mean(x$flfp_2023)
W     <- model.matrix(~ reg, x)[, -1]
bsr   <- binsreg(x$flfp_2023, x$lgdp, w = W, nbins = 10)$data.plot[[1]]$data.dots

pb_data <- bind_rows(
  binned_means(x$lgdp, x$flfp_2023, 10) |> mutate(method = "No controls"),
  binned_means(res_x, res_y, 10)        |> mutate(method = "Residualized on region"),
  tibble(x = bsr$x, y = bsr$fit)         |> mutate(method = "binsreg, region controls"))

x_dollars <- scale_x_continuous(breaks = 3:5, labels = function(v) dollar(10^v))
lab_x     <- "GDP per capita, 2022 (US$, log scale)"

pa_data <- bind_rows(binned_means(x$lgdp, x$flfp_2023, 5) |> mutate(k = "5 bins"),
                     binned_means(x$lgdp, x$flfp_2023, k_opt) |> mutate(k = paste(k_opt, "bins")))

pa <- ggplot(x, aes(lgdp, flfp_2023)) +
  geom_point(colour = "grey70", size = 0.8) +
  geom_line(data = pa_data, aes(x, y, colour = k)) +
  geom_point(data = pa_data, aes(x, y, colour = k, shape = k, size = k)) +
  scale_colour_manual(values = c("#b5532a", "#1f4e79"), name = NULL) +
  scale_shape_manual(values = c(15, 16), name = NULL) +
  scale_size_manual(values = c(3, 1.5), name = NULL) +
  x_dollars + labs(x = lab_x, y = "Female labor force participation, 2023 (%)",
                   title = "(a) Five bins or fourteen") +
  theme(legend.position = c(0.8, 0.15))

pb <- ggplot(pb_data, aes(x, y, colour = method, linetype = method)) +
  geom_line() + geom_point(size = 1.5) +
  scale_colour_manual(values = c("No controls" = "grey45", "Residualized on region" = "#b5532a",
                                 "binsreg, region controls" = "#1f4e79"), name = NULL) +
  scale_linetype_manual(values = c("No controls" = "solid", "Residualized on region" = "dashed",
                                   "binsreg, region controls" = "solid"), name = NULL) +
  x_dollars + coord_cartesian(ylim = range(x$flfp_2023)) +
  labs(x = lab_x, y = NULL, title = "(b) Controlling for region") +
  theme(legend.position = c(0.7, 0.15))

ggsave("Chapters/Figures/fig_04_binscatter_R.svg", pa + pb, width = 7, height = 3.4)
