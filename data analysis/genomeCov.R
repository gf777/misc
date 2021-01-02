#setwd(dirname(rstudioapi::getSourceEditorContext()$path))

library(ggplot2)
library(dplyr)
library(grid)
library(gridExtra)

data <- read.csv("noAutosomes.noX.decollapsed.genomecov", header = FALSE, col.names = c("scaffold","cov","count", "len", "freq"), sep = "\t", na.strings="NA")

data %>% filter (len>52500) %>% filter (len<55000) %>% ggplot(aes(x = cov, y = count)) + 
  geom_line(aes(color = scaffold)) +
  xlim(c(0,100))

p<-ggplot(data, aes(x = cov, y = count)) + 
  geom_line(size=5) +
  xlim(c(0,100)) +
  geom_vline(aes(xintercept=30), color="black", linetype="dashed", size=3) +
  geom_vline(aes(xintercept=60), color="black", linetype="dashed", size=3) +
  theme(
    axis.title = element_text(family = "Arial",
                              size = rel(5), colour = "black"), 
    axis.text = element_text(family = "Arial",
                             size = rel(5), colour = "black"),
    axis.ticks.length = unit(2, "cm"),
    axis.ticks = element_line(colour = "black", size=(1)),
    plot.title = element_text(size = rel(5), face = "bold")
  )

plots = data %>% 
    group_by(scaffold) %>% 
    do(plots = p %+% .) %>% 
    rowwise() %>%
    do(x=.$plots + ggtitle(.$scaffold))

png("marmoset scaffolds.png", width = 50000, height = 50000) 
grid.arrange(grobs = plots$x, ncol = 37)
dev.off()
  
