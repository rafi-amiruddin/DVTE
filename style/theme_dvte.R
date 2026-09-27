# style/theme_dvte.R --- DVTE house style for ggplot2
# Usage:
#   source("style/theme_dvte.R")
#   p + theme_dvte            # one plot
#   theme_set(theme_dvte)     # every plot that follows

library(ggplot2)

theme_dvte <- theme_gray(base_size = 9) +
  theme(strip.text = element_text(face = "bold"),
        panel.grid.minor = element_blank())
