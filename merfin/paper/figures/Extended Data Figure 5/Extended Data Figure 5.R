setwd(dirname(rstudioapi::getSourceEditorContext()$path))

library(ggplot2)
library(dplyr)
library(ggpubr)
library(grid)
library(gridExtra)
library(RSvgDevice)

plot <- function(data,QV,label) {
  ggplot(data, aes(x=source, y=get(QV), group=1)) +
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
    axis.text.x = element_text(angle = 45, hjust=1),
    axis.ticks.length = unit(2, "cm"),
    axis.ticks = element_line(colour = "black", size=(1)),
    plot.tag = element_text(size = rel(10), face = "bold"),
  )+
  scale_y_continuous(labels = scales::number_format(accuracy = 0.1))+
  ylab(label)+
  xlab("")+
  geom_point(size=5)+
  geom_line(size=2.5)
}

data <- read.csv("results.txt", header = TRUE, sep = "\t", na.strings="")

data$source <- factor(data$source, levels = data$source)

data <- data %>% filter (source != "v0.7 (HiCanu)")

plotQV <- plot(data,"QV_illumina",'QV')
plotQVstar <- plot(data,"QVstar_illumina",'QV*')

png("Supplementary Figure 3.png", width = 4000, height = 2000)

grid.arrange(plotQV,plotQVstar, nrow=1)

dev.off()

#Correlations
cor(data$P_hifi, data$Pstar_hifi, method = "pearson")
cor(data$P_illumina, data$Pstar_illumina, method = "pearson")
cor(data$P_hifi, data$P_illumina, method = "pearson")
cor(data$Pstar_hifi, data$Pstar_illumina, method = "pearson")

