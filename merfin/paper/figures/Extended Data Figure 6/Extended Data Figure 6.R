setwd(dirname(rstudioapi::getSourceEditorContext()$path))

library(ggplot2)
library(dplyr)
library(ggpubr)

data <- read.csv("results.txt", header = FALSE, sep = "\t", na.strings="")

png("Supplementary Figure 4.png", width = 2500, height = 2000)

# Add regression line
ggplot(data, aes(x=V2, y=V6)) +
  theme(
    panel.background = element_rect(fill = "white",
                                    colour = "white",
                                    size = 1, linetype = "solid"),
    panel.grid.major = element_line(size = 1, linetype = 'solid',
                                    colour = "grey"), 
    panel.grid.minor = element_line(size = 1, linetype = 'solid',
                                    colour = "grey"),
    legend.position="none",
    axis.title = element_text(family = "Arial",
                              size = rel(10), colour = "black"), 
    axis.text = element_text(family = "Arial",
                             size = rel(10), colour = "black"),
    axis.ticks.length = unit(2, "cm"),
    axis.ticks = element_line(colour = "black", size=(1)),
    plot.tag = element_text(size = rel(10), face = "bold"),
  )+
  xlab("Read fraction")+
  ylab("QV*")+
  geom_jitter(aes(group=V1),width = 0.05, height = 0, size=5)+
  scale_x_continuous(breaks=c(0.2,0.4,0.6,0.8,1))+
  scale_y_continuous(breaks=25:35, limits = c(30,32))

dev.off()