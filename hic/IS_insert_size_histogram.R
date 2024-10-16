library(ggplot2)
library(dplyr)
library(scales)

setwd(dirname(rstudioapi::getSourceEditorContext()$path))
df<-read.csv("insert.sizes", sep = "\t", header = FALSE, skip = 1)
names(df) <- c('size','count')
df = df[-1,]
df['dataset']='Illumina'
#df = df %>% filter(size < 500000)

ggplot(df, aes(x=size, fill = dataset)) + geom_col(aes(y=count), width = 0.01, alpha=0.5) + 
  scale_x_log10(breaks=c(10^(0:10)), labels=trans_format('log10',math_format(10^.x))) +
  scale_fill_manual(values = c("red", "blue")) +
  theme_classic()
