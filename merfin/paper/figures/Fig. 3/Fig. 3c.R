setwd(dirname(rstudioapi::getSourceEditorContext()$path))

library(ggplot2)
library(dplyr)
library(cowplot)
library(patchwork)
library(RSvgDevice)
library(scales)

fancy_scientific <- function(d) {
  # turn in to character string in scientific notation
  d <- format(d, scientific = TRUE)
  # quote the part before the exponent to keep all the digits and turn the 'e+' into 10^ format
  d <- gsub("^(.*)e\\+", "'\\1'%*%10^", d)
  # convert 0x10^00 to 0
  d <- gsub("\\'0[\\.0]*\\'(.*)", "'0'", d)
  # return this as an expression
  parse(text=d)
}

save_plot <- function(name, outformat, h, w) {
  ggsave(file = paste(name, outformat, sep = "."), height = h, width = w, dpi=300)
}

plot_bars <- function(df, hap, readout, title) {
  plt<-
    df %>% filter(haplotype == hap) %>%
    ggplot(aes_string(x="merfin", y=readout)) +
    geom_bar(stat="identity", aes(fill=merfin), color="black",size=0.5)+
    theme_bw() +
    theme(
      panel.background = element_rect(color = NA),
      plot.title = element_text(hjust = 0.5,
                                size = 15, colour = "black", face="bold",
                                margin = margin(t = 10, r = 0, b = 10, l = 0)), 
      axis.title = element_blank(),
      axis.text = element_text(
                               size = 15),
      axis.title.x=element_blank(),
      axis.text.x=element_blank(),
      axis.text.y=element_text(margin = margin(l = 10)),
      axis.ticks.x=element_blank(),
      plot.tag = element_text(size = 15, face = "bold"),
      strip.text.x = element_text(size = 15),
      legend.position = "none"
    )+
    scale_fill_manual(values=c("#ED1C24","#21409A"))+
    scale_color_manual(values=c("#ED1C24","#21409A"))+
    scale_y_continuous(limits = c(0, data$variants), labels = fancy_scientific)+
    ggtitle(title)+
    facet_grid(cols = vars(round))
  
plt 
}

data <- read.csv("data.variants", header = TRUE, sep = "\t", na.strings="NA")
data$merfin <- factor(data$merfin, levels = c(FALSE,TRUE))
levels(data$merfin) <- list(Medaka=FALSE, Merfin=TRUE)
data$round <- factor(data$round, levels = c("r1", "r2"))
levels(data$round) <- list("Round 1"="r1", "Round 2"="r2")

mat <- plot_bars(data, 'mat', 'variants', 'Maternal')+theme(plot.margin = margin(0, 0.08, 0, 0.97, "cm"))
pat <- plot_bars(data, 'pat', 'variants', 'Paternal')

leg <- get_legend(mat + theme(panel.background = element_rect(element_rect(fill = "white"),color = NA),
                              legend.text = element_text(size = 15, face = "bold"),
                              legend.position="bottom",
                              legend.title = element_blank(),
                              legend.background = element_rect(fill = "white"),
                              legend.key = element_blank()))

plot_grid(plot_grid(mat,pat, ncol = 2, rel_widths = c(1,1)),leg, nrow = 2, rel_heights = c(5,1))+panel_border(remove = TRUE)

save_plot("Figure 3c", "png", h = 2.5, w = 12)

