setwd(dirname(rstudioapi::getSourceEditorContext()$path))

library("ggplot2")
library("scales")

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
    ggsave(file = paste(name, outformat, sep = "."), height = h, width = w, dpi=300, type = "cairo")
}

attach_n <- function(dat, gsize=0) {
  dat = read.table(dat, header = F)
  names(dat) = c("Type", "Group", "Size")
  dat$Sum = cumsum(as.numeric(dat$Size))
  
  if (gsize == 0) {
    # N*
    gsize = sum(dat$Size)
  }
  dat$N = 100*dat$Sum/gsize
  dat$N2 = 100*c(0, dat$Sum[-nrow(dat)]/gsize)
  return(dat)
}

get_dummy <- function(dat=NULL, type) {
  x_max=max(dat$N)
  data.frame(Type = c(type), Group = c("dummy"), Size = c(0), Sum = c(0), N = c(x_max), N2 = c(x_max))
}

bind_blocks <- function(unpolished, unpolished_dummy, medaka1, medaka1_dummy, medaka2, medaka2_dummy, merfin1, merfin1_dummy, merfin2, merfin2_dummy, contig, contig_dummy) {
  
  blocks = data.frame()
  if (!is.null(unpolished)) {
    blocks=rbind(blocks, unpolished, unpolished_dummy)
  }
  if (!is.null(medaka1)) {
    blocks=rbind(blocks, medaka1, medaka1_dummy)
  }
  if (!is.null(medaka2)) {
    blocks=rbind(blocks, medaka2, medaka2_dummy)
  }
  if (!is.null(merfin1)) {
    blocks=rbind(blocks, merfin1, merfin1_dummy)
  }
  if (!is.null(merfin2)) {
    blocks=rbind(blocks, merfin2, merfin2_dummy)
  }
  if (!is.null(contig)) {
    blocks=rbind(blocks, contig, contig_dummy)
  }
  return(blocks)
}

block_n <- function(unpolished=NULL, medaka1=NULL, medaka2=NULL, merfin1=NULL, merfin2=NULL, contig=NULL, out, gsize = 0, w = 6, h = 5, title = NULL) {
  
  # Read file
  if (!is.null(unpolished)) {
    unpolished = attach_n(dat = unpolished, gsize = gsize)
    unpolished_dummy = get_dummy(dat = unpolished, type = "unpolished")
  }  

  if (!is.null(medaka1)) {
    medaka1 = attach_n(dat = medaka1, gsize = gsize)
    medaka1_dummy = get_dummy(dat = medaka1, type = "medaka1")
  }
  
  if (!is.null(medaka2)) {
    medaka2 = attach_n(dat = medaka2, gsize = gsize)
    medaka2_dummy = get_dummy(dat = medaka2, type = "medaka2")
  }
  
  if (!is.null(merfin1)) {
    merfin1 = attach_n(dat = merfin1, gsize = gsize)
    merfin1_dummy = get_dummy(dat = merfin1, type = "merfin1")
  }
  
  if (!is.null(merfin2)) {
    merfin2 = attach_n(dat = merfin2, gsize = gsize)
    merfin2_dummy = get_dummy(dat = merfin2, type = "merfin2")
  }
  
  if (!is.null(contig)) {
    contig = attach_n(dat = contig, gsize = gsize)
    contig_dummy = get_dummy(dat = contig, type = "contig")
  }
  
  stats = "NG"
  if (gsize == 0) {
    stats = "N"
  }
  
  dat = bind_blocks(unpolished, unpolished_dummy, medaka1, medaka1_dummy, medaka2, medaka2_dummy, merfin1, merfin1_dummy, merfin2, merfin2_dummy, contig, contig_dummy)
  y_max=max(dat$Size)
  
  ggplot(data = dat, aes(x = N2, y = Size, colour = Type)) +
    geom_step(aes(linetype=Type)) +
    theme_bw() +
    theme(legend.text = element_text(size=15),
          legend.position = c(0.95,0.95),  # Modify this if the legend is covering your favorite circle
          legend.background = element_rect(size=0.1, linetype="solid", colour ="black"),
          legend.box.just = "right",
          legend.justification = c("right", "top"),
          legend.title = element_blank(),
          plot.title = element_text(size=15,face="bold", hjust = 0.5),
          axis.title=element_text(size=15,face="bold"),
          axis.text=element_text(size=15)) +
    scale_color_manual(values = c("unpolished" = "gray", "medaka1" = "#ED1C24", "medaka2" = "#ED1C24", "merfin1" = "#21409A", "merfin2" = "#21409A", "contig" = "black"), breaks = c("unpolished", "medaka1", "merfin1", "contig"), labels = c("Unpolished", "Medaka", "Merfin", "Contig"))+
    scale_linetype_manual(values = c("unpolished" = "solid", "medaka1" = "dotted", "medaka2" = "solid", "merfin1" = "dotted", "merfin2" = "solid", "contig" = "solid"), breaks = c("medaka1", "medaka2"), labels = c("Round 1", "Round 2"))+
    scale_x_continuous(limits = c(0, 100)) +
    scale_y_continuous(limits = c(0, y_max), labels = fancy_scientific) +
    xlab(stats) + ylab("Size (bp)") +
    geom_vline(xintercept = 50, show.legend = FALSE, linetype="dashed", color="black")+
    ggtitle(title)
  
  save_plot(out, "png", h = h, w = w)
}

block_n(unpolished = "mat_unpolished.sizes", medaka1 = "mat_medaka1.sizes", medaka2 = "mat_medaka2.sizes", merfin1 = "mat_merfin1.sizes", merfin2 = "mat_merfin2.sizes", contig = "mat_contig.sizes", out = "Fig. 3b mat", gsize = 0, w = 6, h = 5, title = "Maternal")
block_n(unpolished = "pat_unpolished.sizes", medaka1 = "pat_medaka1.sizes", medaka2 = "pat_medaka2.sizes", merfin1 = "pat_merfin1.sizes", merfin2 = "pat_merfin2.sizes", contig = "pat_contig.sizes", out = "Fig. 3b pat", gsize = 0, w = 6, h = 5, title = "Paternal")