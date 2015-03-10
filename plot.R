library(dplyr)
library(ggplot2)

ticks <- c(1,3,10,30,100,300)

read.csv("plot.csv", sep="|") %>%
    ggplot(aes(x = aggregation, y = join, label = system, color = type)) +
    geom_text() + ## geom_point(size = 3) +
    scale_x_log10(breaks = ticks, labels = ticks) + 
    scale_y_log10(breaks = ticks, labels = ticks) +
    geom_smooth(aes(x = aggregation, y = join), method = "lm", se = FALSE,
                formula = y ~ x + 0, color="grey60")

