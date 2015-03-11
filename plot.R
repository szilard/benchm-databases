library(dplyr)
library(ggplot2)

ticks <- c(1,3,10,30,100,300,1000)

d <- read.csv("plot.csv", sep="|") 
names(d) <- tolower(names(d))

d %>% ggplot(aes(x = aggregation, y = join, label = system, color = type)) +
    geom_text() +
    scale_x_log10(breaks = ticks, labels = ticks, limits = c(0.5,1000)) + 
    scale_y_log10(breaks = ticks, labels = ticks, limits = c(0.5,1000)) +
    geom_smooth(aes(x = aggregation, y = join), method = "lm", se = FALSE,
                formula = y ~ x + 0, color="grey60")

