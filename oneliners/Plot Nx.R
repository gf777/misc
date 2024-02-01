library(ggplot2)
library(dplyr)
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

filenames <- list.files(".", pattern="*.ssv", full.names=TRUE)
ldf <- lapply(filenames, read.csv, sep = ' ', header = FALSE)
names(ldf) <- substr(filenames, 3, 19)
ldf <- lapply(ldf, setNames, c("size","percent"))
df <- bind_rows(ldf, .id = "column_label")
df$size_mbp <- df$size / 1000000

theme_set(theme_minimal())
options(scipen = 999)
ggplot(data=df, aes(x=percent, y=size_mbp))+
  geom_line(aes(color = column_label))+
  ylab("Mbp")+
  xlab("Nx (%)")+
  scale_colour_grey()+
  scale_y_log10()

