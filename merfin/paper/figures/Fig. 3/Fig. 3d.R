setwd(dirname(rstudioapi::getSourceEditorContext()$path))

library(ggplot2)
library(dplyr)
library(grid)
library(gridExtra)
library(RSvgDevice)

text_size1=6.5
text_size2=80

#################################
#Recall,Precision,F1
#################################

AppendMe <- function(dfNames) {
  do.call(rbind, lapply(dfNames, function(x) {
    cbind(get(x), source = x)
  }))
}

grid_arrange_shared_legend <- function(...) {
  plots <- list(...)
  g <- ggplotGrob(plots[[1]] + theme(
    legend.position="bottom", 
    legend.title = element_blank(),
    legend.background = element_blank(),
    legend.key = element_rect(fill = NA, color = NA)))$grobs
  legend <- g[[which(sapply(g, function(x) x$name) == "guide-box")]]
  lheight <- sum(legend$height)
  grid.arrange(arrangeGrob(
    arrangeGrob(plots[[1]] + theme(legend.position="none", plot.margin = unit(c(0,2,2,0), "cm"), axis.text.x = element_blank())),
    arrangeGrob(plots[[2]] + theme(legend.position="none", plot.margin = unit(c(0,2,2,0), "cm"), axis.text.x = element_blank())),
    arrangeGrob(plots[[3]] + theme(legend.position="none", plot.margin = unit(c(0,0,2,0), "cm"), axis.text.x = element_blank())),
    arrangeGrob(plots[[4]] + theme(legend.position="none", plot.margin = unit(c(0,2,2,0), "cm"))+ ggtitle("")),
    arrangeGrob(plots[[5]] + theme(legend.position="none", plot.margin = unit(c(0,2,2,0), "cm")) + ggtitle("")),
    arrangeGrob(plots[[6]] + theme(legend.position="none", plot.margin = unit(c(0,0,2,0), "cm")) + ggtitle("")),
    nrow=2, heights = c(1,1.44)),
               legend, nrow=2, heights = unit.c(unit(1, "npc") - lheight, lheight))
}

plot_lines <- function(df, tp, stage, res_val, title) {

  df<-df %>% filter(type==tp)  

  plt <- ggplot(df, aes_string(x=stage, y=res_val)) +
    geom_point(size=8, aes(color=as.factor(legend)))+
    geom_line(size=2, aes(group=as.factor(merfin), color=as.factor(legend)))+
    theme(
      panel.background = element_rect(fill = "white",
                                      colour = "gray",
                                      size = 2, linetype = "solid"),
      panel.grid.major = element_line(size = 1, linetype = 'dotted',
                                      colour = "grey"), 
      panel.grid.minor = element_line(size = 1, linetype = 'dotted',
                                      colour = "grey"),
      plot.title = element_text(family = "Arial", hjust = 0.5,
                                size = rel(text_size1), colour = "black", face="bold",
                                margin = margin(t = 10, r = 0, b = 10, l = 0)), 
      axis.title = element_text(family = "Arial",
                                size = rel(text_size1), colour = "black", face="bold"), 
      axis.title.y = element_blank(),
      axis.title.x = element_blank(),
      axis.text = element_text(family = "Arial",
                               size = rel(text_size1), colour = "black"),
      axis.ticks = element_line(size = 2),
      axis.ticks.length = unit(0.5,"cm"),
      axis.text.x=element_text(margin = margin(t = 20), angle = 45, hjust = 1),
      axis.text.y.right=element_text(margin = margin(l = 10)),
      plot.tag = element_text(size = rel(text_size1), face = "bold"),
      legend.text = element_text(size = rel(text_size1), face = "bold"),
      legend.position="bottom",
      legend.key.size = unit(2,"cm"),
      legend.title = element_blank(),
      legend.background = element_blank(),
      legend.key = element_rect(fill = NA, color = NA),
      legend.spacing.x = unit(1.0, 'cm'),
      strip.background = element_blank(), strip.text = element_blank(),
      panel.spacing = unit(2, "lines")
      )+
    ggtitle(title)+
    scale_color_manual(values=c("#21409A","#ED1C24"), breaks = c(3,2), labels = rev(c("Medaka", "Merfin")), guide = guide_legend(reverse = TRUE))+
    scale_x_discrete(labels = c('Unpolished','Round 1','Round 2'), expand = c(0.05,0.05))+
    scale_y_continuous(labels = scales::number_format(accuracy = 0.01))
  plt
}

data <- read.csv("Fig 3d.data", header = TRUE, sep = "\t", na.strings="NA")
data$status <- factor(data$status, levels = c("Unpolished", "Regular", "Merfin"))
data$step <- factor(data$step, levels = c("Unpolished", "round1", "round2"))
#data$species <- factor(data$species, levels = c("fArcCen1", "rGopEvg1", "bTaeGut1"))

gr1<-plot_lines(data, 'SNP', 'step', 'F1score', 'F1 score')
gr2<-plot_lines(data, 'SNP', 'step', 'precision', 'Precision')
gr3<-plot_lines(data, 'SNP', 'step', 'recall', 'Recall')

gr4<-plot_lines(data, 'INDEL', 'step', 'F1score', 'F1 score')
gr5<-plot_lines(data, 'INDEL', 'step', 'precision', 'Precision')
gr6<-plot_lines(data, 'INDEL', 'step', 'recall', 'Recall')

def<-grid_arrange_shared_legend(gr1,gr2,gr3,gr4,gr5,gr6)

png("Figure 3d.png", width = 3500, height = 1500)

grid.arrange(def, vp=viewport(width=0.98))

dev.off()