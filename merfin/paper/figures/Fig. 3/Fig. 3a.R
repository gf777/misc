setwd(dirname(rstudioapi::getSourceEditorContext()$path))

library(dplyr)
library(ggplot2)
library(cowplot)
library(patchwork)

text_size1=10

qv_data<-read.csv("qv_test4.2.txt", sep = "\t", header = TRUE)

plot_bw <- function(qv_data,scalex,scaley,avg){

  qv_data_unpolished <- qv_data %>% filter(asm == "unpolished")
  
  histogram <- ggplot() +
    geom_histogram(aes(x=qv_data_unpolished$qv, y=..count..), bins=100,color="#e9ecef", fill="#999999", position = 'identity',alpha=1) +
    geom_vline(aes(xintercept = avg, linetype="Average"), size = 3) +
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
                                margin = margin(t = 0, r = 0, b = 10, l = 0)), 
      axis.title = element_text(family = "Arial",
                                size = rel(text_size1), colour = "black", face="bold"), 
      axis.title.x = element_text(margin = margin(t = 0, r = 0, b = 0, l = 0)),
      axis.title.y = element_text(margin = margin(t = 0, r = 60, b = 0, l = 0)),
      axis.text = element_text(family = "Arial",
                               size = rel(text_size1), colour = "black"),
      axis.ticks = element_line(size = 4),
      axis.ticks.length = unit(1,"cm"),
      plot.tag = element_text(size = rel(text_size1), face = "bold"),
      strip.background = element_blank(), strip.text = element_blank(),
      panel.spacing = unit(0, "lines"),
      plot.margin = margin(0, 0.5, 0, 0, "cm"),
      legend.position = "none"
    )+
    scale_x_continuous(expand = c(0,0), limits = scalex)+
    scale_y_continuous(expand = c(0,0), limits = scaley, labels = scales::label_number_si(accuracy = 1))+
    scale_linetype_manual(values = c(Average = "longdash")) +
    ylab("Counts")+xlab("QV")
  
  inf<-qv_data_unpolished %>% filter (qv == "Inf") %>% count %>% rename(count = n)
  
  barplot <- ggplot(inf) +
    geom_bar(aes(1,y=count), color="#e9ecef", fill="#999999", stat = "identity", position = 'dodge', width = 0.8)+
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
                                margin = margin(t = 0, r = 0, b = 0, l = 0)), 
      axis.title.x = element_text(family = "Arial",
                                  size = rel(text_size1), colour = "black", face="bold",
                                  margin = margin(t = 0, r = 0, b = 0, l = 0), hjust = -5),
      axis.title.y = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      axis.ticks.length = unit(1,"cm"),
      plot.tag = element_text(size = rel(text_size1), face = "bold"),
      strip.background = element_blank(), strip.text = element_blank(),
      panel.spacing = unit(0, "lines"),
      plot.margin = margin(0, 7.5, 0, 0, "cm"),
      legend.position = "none"
    )+
    scale_x_discrete(expand = c(1,1))+
    scale_y_continuous(expand = c(0,0), limits = scaley)+
    scale_fill_manual(values = c("no_merfin" = "#ED1C24","merfin" = "#21409A"))+
    xlab("no errors")
  
  return(list(histogram,barplot))
  
}

plot_colors <- function(qv_data,scalex,scaley,avg1,avg2){
  
  qv_data$asm <- ordered(qv_data$asm, levels= c("merfin","medaka_vcf"))
  
  qv_data_merfin <- qv_data %>% filter(asm == "merfin")
  qv_data_nomerfin <- qv_data %>% filter(asm == "medaka_vcf")

histogram <- ggplot() +
  geom_histogram(aes(x=qv_data_merfin$qv, y=..count.., fill = "b"), bins=100,color="#e9ecef", position = 'identity',alpha=0.65) +
  geom_histogram(aes(x=qv_data_nomerfin$qv, y=..count.., fill = "a"), bins=100,color="#e9ecef", position = 'identity',alpha=0.65) +
  geom_histogram(aes(x=qv_data_merfin$qv, y=..count.., fill = "b"), bins=100,color="#e9ecef", position = 'identity',alpha=0.65) +
  geom_histogram(aes(x=qv_data_nomerfin$qv, y=..count.., fill = "a"), bins=100,color="#e9ecef", position = 'identity',alpha=0.5) +
  geom_vline(xintercept = avg1, size = 3, colour="#bf171d", linetype = "longdash") +
  geom_vline(xintercept = avg2, size = 3, colour="#142861", linetype = "longdash") +
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
                              margin = margin(t = 0, r = 0, b = 0, l = 0)), 
    axis.title = element_text(family = "Arial",
                              size = rel(text_size1), colour = "black", face="bold"), 
    axis.title.x = element_text(margin = margin(t = 0, r = 0, b = 0, l = 0)),
    axis.title.y = element_text(margin = margin(t = 0, r = 60, b = 0, l = 0)),
    axis.text = element_text(family = "Arial",
                             size = rel(text_size1), colour = "black"),
    axis.ticks = element_line(size = 4),
    axis.ticks.length = unit(1,"cm"),
    plot.tag = element_text(size = rel(text_size1), face = "bold"),
    strip.background = element_blank(), strip.text = element_blank(),
    panel.spacing = unit(0, "lines"),
    plot.margin = margin(0, 0.5, 0, 0, "cm"),
    legend.position = "none"
  )+
  scale_x_continuous(expand = c(0,0), limits = scalex)+
  scale_y_continuous(expand = c(0,0), limits = scaley, labels = scales::label_number_si(accuracy = 1))+
  scale_fill_manual(labels = c("Medaka only","Medaka+Merfin"), values = c("a" = "#ED1C24","b" = "#21409A"))+
  ylab("Counts")+xlab("QV")

inf <- bind_rows("merfin" = qv_data_merfin %>% filter (qv == "Inf") %>% count %>% rename(count = n), 
          "no_merfin" = qv_data_nomerfin %>% filter (qv == "Inf") %>% count %>% rename(count = n),
          .id = "group")

inf$group <- ordered(inf$group, levels= c("no_merfin","merfin"))

barplot <- ggplot(inf) +
  geom_bar(aes(x=group, y=count, fill=group), color="#e9ecef", stat = "identity", position = 'dodge', width = 0.8)+
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
                              margin = margin(t = 0, r = 0, b = 0, l = 0)), 
    axis.title.x = element_text(family = "Arial",
                              size = rel(text_size1), colour = "black", face="bold",
                              margin = margin(t = 0, r = 0, b = 0, l = 0)), 
    axis.title.y = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.ticks.length = unit(1,"cm"),
    plot.tag = element_text(size = rel(text_size1), face = "bold"),
    strip.background = element_blank(), strip.text = element_blank(),
    panel.spacing = unit(0, "lines"),
    plot.margin = margin(0, 7.5, 0, 0, "cm"),
    legend.position = "none"
  )+
  scale_x_discrete(expand = c(1,1))+
  scale_y_continuous(expand = c(0,0), limits = scaley)+
  scale_fill_manual(values = c("no_merfin" = "#ED1C24","merfin" = "#21409A"))+
  xlab("no errors")

return(list(histogram,barplot))

}

blank_p <- plot_spacer() + theme_void()

png("Fig. 3a.png", width = 4500, height = 6000)

scalex<-c(qv_data %>% filter(parent == "mat" & qv!="Inf") %>% dplyr::select(qv) %>% min(),
          qv_data %>% filter(parent == "mat" & qv!="Inf") %>% dplyr::select(qv) %>% max())
scaley<-c(0,80)

#unpolished
plot_unpolished_mat<-plot_bw(qv_data %>% filter(parent == "mat"), scalex, scaley, 29.6856)
plot_unpolished_pat<-plot_bw(qv_data %>% filter(parent == "pat"), scalex, scaley, 29.6014)

#maternal plots, exp1, round1
plot1_mat<-plot_colors(qv_data %>% filter(parent == "mat") %>% filter(exp == "1"), scalex, scaley, 38.2581, 41.0734)

#paternal plots, exp1, round1
plot1_pat<-plot_colors(qv_data %>% filter(parent == "pat") %>% filter(exp == "1"), scalex, scaley, 37.6167, 40.6178)

#maternal plots, exp1, round2
plot1.2_mat<-plot_colors(qv_data %>% filter(parent == "mat") %>% filter(exp == "1.2"), scalex, scaley, 39.7155, 43.2482)

#paternal plots, exp1, round2
plot1.2_pat<-plot_colors(qv_data %>% filter(parent == "pat") %>% filter(exp == "1.2"), scalex, scaley, 38.9859, 42.7802)

remove_axis<-theme(axis.title.x = element_blank(),
                   axis.text.x = element_blank(),
                   axis.ticks.x = element_blank(),
                   axis.ticks.length.x = unit(0, "pt"))

leg1 <- get_legend(plot1_mat[[1]] + theme(legend.margin = margin(0, 0, 0, 0),
                                         legend.text = element_text(size = rel(text_size1)),
                                         legend.position="bottom",
                                         legend.key.size = unit(2,"cm"),
                                         legend.title = element_blank(),
                                         legend.background = element_blank(),
                                         legend.key = element_rect(fill = NA, color = NA),
                                         legend.spacing.x = unit(1.0, 'cm')))

leg2 <- get_legend(plot_unpolished_mat[[1]] + theme(legend.margin = margin(0, 0, 0, 0),
                                      legend.text = element_text(size = rel(text_size1)),
                                      legend.position="bottom",
                                      legend.key.size = unit(2,"cm"),
                                      legend.title = element_blank(),
                                      legend.background = element_blank(),
                                      legend.key = element_rect(fill = NA, color = NA),
                                      legend.spacing.x = unit(1.0, 'cm')) +
                                      scale_linetype_manual(values = c(Average = "solid"))
                                      )

mat_plots<-plot_grid(
  ggdraw() + draw_label("Unpolished assembly (maternal)", fontface='bold', size = rel(text_size1)*10),
  plot_grid(
            plot_unpolished_mat[[1]]+remove_axis+ylab(""), plot_unpolished_mat[[2]]+remove_axis,
            ncol = 2, rel_widths = c(4,0.7), align = "h"),
  ggdraw() + draw_label("1 round of polishing", fontface='bold', size = rel(text_size1)*10),
  plot_grid(
            plot1_mat[[1]]+remove_axis, plot1_mat[[2]]+remove_axis,
            ncol = 2, rel_widths = c(4,0.7), align = "h"),
  ggdraw() + draw_label("2 round of polishing", fontface='bold', size = rel(text_size1)*10),
  plot_grid(
            plot1.2_mat[[1]]+ylab(""), plot1.2_mat[[2]],
            ncol = 2, rel_widths = c(4,0.7), align = "h"),
  ncol = 1, nrow = 6, rel_heights = c(0.35,4)
)

pat_plots<-plot_grid(
  ggdraw() + draw_label("Unpolished assembly (paternal)", fontface='bold', size = rel(text_size1)*10),
  plot_grid(
    plot_unpolished_pat[[1]]+remove_axis+ylab(""), plot_unpolished_mat[[2]]+remove_axis,
    ncol = 2, rel_widths = c(4,0.7), align = "h"),
  ggdraw() + draw_label("1 round of polishing", fontface='bold', size = rel(text_size1)*10),
  plot_grid(
    plot1_pat[[1]]+remove_axis+ylab(""), plot1_mat[[2]]+remove_axis,
    ncol = 2, rel_widths = c(4,0.7), align = "h"),
  ggdraw() + draw_label("2 round of polishing", fontface='bold', size = rel(text_size1)*10),
  plot_grid(
    plot1.2_pat[[1]]+ylab(""), plot1.2_mat[[2]],
    ncol = 2, rel_widths = c(4,0.7), align = "h"),
  ncol = 1, nrow = 6, rel_heights = c(0.35,4)
)

plot_grid(plot_grid(mat_plots, pat_plots, ncol = 2, rel_widths = c(1,1)),
          plot_grid(blank_p, leg1, leg2, blank_p, ncol = 4, rel_widths = c(4,7,5,4)), 
          ncol = 1, nrow = 2, rel_heights = c(4,0.2))

dev.off()
