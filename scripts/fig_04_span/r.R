# scripts/fig_04_span/r.R
# Local regression smoothers of female labor force participation on GDP per capita:
# (a) the span; (b) the degree of the local polynomial, at a fixed span.
library(tidyverse)
library(scales)
library(patchwork)

setwd(".")                                  # set to the repository root
source("style/theme_dvte.R")
theme_set(theme_dvte)

x <- read_csv("data/wdi_flfp_xsec.csv") |>
  drop_na(gdppc_2022, flfp_2023) |>
  mutate(lgdp = log10(gdppc_2022))
grid <- tibble(lgdp = seq(min(x$lgdp), max(x$lgdp), length.out = 200))

# loess() with family = "gaussian" (no robustness iterations) and surface = "direct"
# (exact fit at every grid point, no interpolation)
smooth_at <- function(span, degree) {
  fit <- loess(flfp_2023 ~ lgdp, data = x, span = span, degree = degree,
               family = "gaussian", surface = "direct")
  predict(fit, grid)
}

curves <- bind_rows(
  mutate(grid, fit = smooth_at(0.20, 1), panel = "a", line = "Span 0.2"),
  mutate(grid, fit = smooth_at(0.75, 1), panel = "a", line = "Span 0.75"),
  mutate(grid, fit = smooth_at(0.75, 0), panel = "b", line = "Local mean (degree 0)"),
  mutate(grid, fit = smooth_at(0.75, 1), panel = "b", line = "Local linear (degree 1)"),
  mutate(grid, fit = smooth_at(0.75, 2), panel = "b", line = "Local quadratic (degree 2)"))

curves |>
  group_by(panel, line) |>
  summarise(left = first(fit), right = last(fit), min = min(fit),
            at = dollar(10^lgdp[which.min(fit)]), .groups = "drop") |>
  print()

# The defaults: lowess() uses f = 2/3 and 3 robustness iterations; loess() uses span 0.75,
# degree 2; geom_smooth() uses loess below 1,000 points and a GAM above
lw <- lowess(x$lgdp, x$flfp_2023)
cat("lowess() default: left end", round(lw$y[1], 1), "; minimum", round(min(lw$y), 1), "\n")

x_dollar <- scale_x_continuous(breaks = 3:5, labels = dollar(10^(3:5)))

pa <- ggplot(filter(curves, panel == "a"), aes(lgdp, fit)) +
  geom_point(data = x, aes(lgdp, flfp_2023), colour = "grey70", size = 0.8) +
  geom_line(aes(colour = line, linewidth = line)) +
  scale_colour_manual(values = c("Span 0.2" = "#b5532a", "Span 0.75" = "#1f4e79"), name = NULL) +
  scale_linewidth_manual(values = c("Span 0.2" = 0.5, "Span 0.75" = 0.8), name = NULL) +
  x_dollar +
  labs(x = "GDP per capita, 2022 (US$, log scale)",
       y = "Female labor force participation, 2023 (%)", title = "(a) The span") +
  theme(legend.position = c(0.75, 0.15))

pb <- ggplot(filter(curves, panel == "b"), aes(lgdp, fit)) +
  geom_point(data = x, aes(lgdp, flfp_2023), colour = "grey70", size = 0.8) +
  geom_line(aes(colour = line, linetype = line), linewidth = 0.7) +
  scale_colour_manual(values = c("Local mean (degree 0)" = "#b5532a",
                                 "Local linear (degree 1)" = "#1f4e79",
                                 "Local quadratic (degree 2)" = "grey25"), name = NULL) +
  scale_linetype_manual(values = c("Local mean (degree 0)" = "dashed",
                                   "Local linear (degree 1)" = "solid",
                                   "Local quadratic (degree 2)" = "dotted"), name = NULL) +
  x_dollar +
  labs(x = "GDP per capita, 2022 (US$, log scale)", y = NULL,
       title = "(b) The degree, span 0.75") +
  theme(legend.position = c(0.65, 0.15))

ggsave("Chapters/Figures/fig_04_span_R.svg", pa + pb & ylim(10, 85), width = 7, height = 3.4)
