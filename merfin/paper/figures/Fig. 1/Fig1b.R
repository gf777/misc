library(ggplot2)
library(scales)
library(cowplot)
library(gridExtra)
library(data.table)
library(gtable)

getwd()
setwd("Merfin/")

merfin_col <- c("#999999", "#ED1C24", "#21409A")
merfin_col4 <- c("#999999", "#444444", "#ED1C24", "#21409A")

plot_pr <- function(dat, X, Y) {
    ggplot(dat, aes(x=X, y=Y, fill = Legend, col = Legend)) + 
        geom_point(aes(shape = factor(SET)), size = 1) +
        ylab("Precision") +
        xlab("Recall") +
        theme_classic() +
        theme(
            axis.title = element_text(face="bold", size=6),
            axis.text = element_text(face="bold", size=5),
            legend.title = element_blank(),
            legend.spacing = unit(0.5, 'mm'),
            legend.text = element_text(size = 5, margin = margin(t=0, r=0, b=0, l=-2)),    # 
            #legend.position = c(0.05, 0.1),  # Modify this if the legend is covering your favorite circle
            legend.box.just = "left",
            legend.position = "top",
            #legend.justification = c("left", "bottom"),
            legend.key.size = unit(2, "mm"),
            legend.key=element_blank(),
            legend.margin=margin(c(-2, 0, 0, 0), unit="mm")
        ) +
        #guides( shape = guide_legend(order = 1), # order 1
        #        col = guide_legend(override.aes = list(size=1, alpha=1), order = 2),
        #        fill  = "none") +
        scale_color_manual(values = merfin_col4) +
        scale_fill_manual(values = merfin_col4) +
        scale_x_continuous(limits = c(min(X, Y), 1.00)) +
        scale_y_continuous(limits = c(min(X, Y), 1.00))
}

plot_bar <- function(dat, X, Y, x_lab, y_lab) {
    ggplot(dat, aes(x=X, y=Y, fill = X)) + 
        geom_bar(stat="identity", col = "black", size = 0.1,
                 position=position_dodge()) +
        ylab(y_lab) +
        #xlab(x_lab) +
        theme_classic() +
        theme(
            axis.title = element_text(face="bold", size=6),
            axis.text = element_text(face="bold", size=5),
            legend.position = "none",
            legend.title = element_blank(),
            legend.key = element_blank()) +
        scale_color_manual(values = merfin_col4) +
        scale_fill_manual(values = merfin_col4) +
        scale_x_discrete(name=x_lab) +
        scale_y_continuous(expand = c(0, 0),
                           limits = c(0.980, 1.0),
                           oob = rescale_none)
}

### Read data
dat=fread("hg002_benchmark_all.txt", header = T, sep = "\t", na.strings = "NA")
head(dat)

### Keep in-place order
dat$ID = factor(dat$ID, levels = as.ordered(dat$ID))
#dat$Legend = factor(dat$Legend, levels = unique(as.ordered(dat$Legend)))
#dat$Legend

# Recall, Precision
dat_sub <- subset(dat, Type == "SNP_INDEL" & Filter == "ALL" 
                  & (Category == "Default" | Category == "Hard" 
                   | Category == "Merfin_gt1" | Category == "Hard_Merfin_gt1"))
p1 <- plot_pr(dat_sub, dat_sub$METRIC.Recall, dat_sub$METRIC.Precision)
p1

leg = gtable_filter(ggplotGrob(p1), "guide-box")
labels <- arrangeGrob(leg)
ggsave("output/benchmark_legend.pdf", labels, width=90, height=4,  units = "mm")

# F1, Illumina
dat_sub <- subset(dat, Type == "SNP_INDEL" & Filter == "ALL" 
                    &  SET  == "Illumina"
                    & (Category == "Default" | Category == "Hard" 
                     | Category == "Merfin_gt1" | Category == "Hard_Merfin_gt1"))
p2 <- plot_bar(dat_sub,
              dat_sub$Legend, dat_sub$METRIC.F1_Score,
              "Illumina", "F1")
p2

# F1, Multi-platform
dat_sub <- subset(dat, Type == "SNP_INDEL" & Filter == "ALL" 
                  &  SET  == "Multi"
                  & (Category == "Default" | Category == "Hard" 
                   | Category == "Merfin_gt1" | Category == "Hard_Merfin_gt1"))
p3 <- plot_bar(dat_sub,
              dat_sub$Legend, dat_sub$METRIC.F1_Score,
              "Multi",
              "F1")
p3


data_plot <- arrangeGrob(p1 + theme(legend.position = "none"),
                         p2 + theme(legend.position = "none", axis.text.x = element_blank()),
                         p3 + theme(legend.position = "none", axis.text.x = element_blank()),
                         ncol = 3,
                         widths = c(1, 1, 1))

p <- arrangeGrob(data_plot, labels, nrow = 2, heights = c(6, 1))
p
ggsave(file = "hg002_benchmark.pdf", p, width = 110, height = 38, units = "mm", device=cairo_pdf)


