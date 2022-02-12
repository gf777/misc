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

bind_blocks <- function(unpolished, unpolished_dummy, freebayes, freebayes_dummy, medaka2, medaka2_dummy, merfin, merfin_dummy, merfin_nofilter, merfin_nofilter_dummy, contig, contig_dummy) {
  
  blocks = data.frame()
  if (!is.null(unpolished)) {
    blocks=rbind(blocks, unpolished, unpolished_dummy)
  }
  if (!is.null(freebayes)) {
    blocks=rbind(blocks, freebayes, freebayes_dummy)
  }
  if (!is.null(medaka2)) {
    blocks=rbind(blocks, medaka2, medaka2_dummy)
  }
  if (!is.null(merfin)) {
    blocks=rbind(blocks, merfin, merfin_dummy)
  }
  if (!is.null(merfin_nofilter)) {
    blocks=rbind(blocks, merfin_nofilter, merfin_nofilter_dummy)
  }
  if (!is.null(contig)) {
    blocks=rbind(blocks, contig, contig_dummy)
  }
  return(blocks)
}

block_n <- function(unpolished=NULL, freebayes=NULL, medaka2=NULL, merfin=NULL, merfin_nofilter=NULL, contig=NULL, out, gsize = 0, w = 6, h = 5, title = NULL) {
  
  # Read file
  if (!is.null(unpolished)) {
    unpolished = attach_n(dat = unpolished, gsize = gsize)
    unpolished_dummy = get_dummy(dat = unpolished, type = "unpolished")
  }  

  if (!is.null(freebayes)) {
    freebayes = attach_n(dat = freebayes, gsize = gsize)
    freebayes_dummy = get_dummy(dat = freebayes, type = "freebayes")
  }
  
  if (!is.null(medaka2)) {
    medaka2 = attach_n(dat = medaka2, gsize = gsize)
    medaka2_dummy = get_dummy(dat = medaka2, type = "medaka2")
  }
  
  if (!is.null(merfin)) {
    merfin = attach_n(dat = merfin, gsize = gsize)
    merfin_dummy = get_dummy(dat = merfin, type = "merfin")
  }
  
  if (!is.null(merfin_nofilter)) {
    merfin_nofilter = attach_n(dat = merfin_nofilter, gsize = gsize)
    merfin_nofilter_dummy = get_dummy(dat = merfin_nofilter, type = "merfin_nofilter")
  }
  
  if (!is.null(contig)) {
    contig = attach_n(dat = contig, gsize = gsize)
    contig_dummy = get_dummy(dat = contig, type = "contig")
  }
  
  stats = "NG"
  if (gsize == 0) {
    stats = "N"
  }
  
  dat = bind_blocks(unpolished, unpolished_dummy, freebayes, freebayes_dummy, medaka2, medaka2_dummy, merfin, merfin_dummy, merfin_nofilter, merfin_nofilter_dummy, contig, contig_dummy)
  y_max=max(dat$Size)
  
  ggplot(data = dat, aes(x = N2, y = Size, colour = Type)) +
    geom_step(aes(linetype=Type)) +
    theme_bw() +
    theme(legend.text = element_text(size=15),
          legend.position = c(0.98,0.95),  # Modify this if the legend is covering your favorite circle
          legend.background = element_rect(size=0.1, linetype="solid", colour ="black"),
          legend.box.just = "right",
          legend.justification = c("right", "top"),
          legend.title = element_blank(),
          plot.title = element_text(size=15,face="bold", hjust = 0.5),
          axis.title=element_text(size=15,face="bold"),
          axis.text=element_text(size=15)) +
    scale_color_manual(values = c("unpolished" = "gray", "freebayes" = "#21409A", "merfin" = "#32CD32", "merfin_nofilter" = "#ED1C24", "contig" = "black"), breaks = c("unpolished", "freebayes", "merfin", "merfin_nofilter", "contig"), labels = c("Unpolished", "Freebayes only", "Freebayes + Merfin", "Merfin (no filter)", "Contig"))+
    scale_linetype_manual(values = c("unpolished" = "solid", "freebayes" = "dotted", "merfin" = "dotted", "merfin_nofilter" = "solid", "contig" = "solid"), breaks = c("unpolished", "freebayes", "merfin", "merfin_nofilter", "contig"), labels = c("Unpolished", "Freebayes only", "Freebayes + Merfin", "Merfin (no filter)", "Contig"))+
    scale_x_continuous(limits = c(0, 100)) +
    scale_y_continuous(limits = c(0, y_max), labels = fancy_scientific) +
    xlab(stats) + ylab("Size (bp)") +
    geom_vline(xintercept = 50, show.legend = FALSE, linetype="dashed", color="black")+
    ggtitle(title)
  
  save_plot(out, "png", h = h, w = w)
}

block_n(unpolished = "unpolished.pri.sizes", freebayes = "pri_alt.pri.sizes", merfin = "pri_alt.merfin.pri.sizes", merfin_nofilter = "pri_alt.merfin.nofilter.pri.sizes", contig = "contig.pri.sizes", out = "Extended Data Figure 8 pri_alt.pri", gsize = 1033365587, w = 6, h = 5, title = "Primary assembly - Polished primary and alternate")
block_n(unpolished = "unpolished.alt.sizes", freebayes = "pri_alt.alt.sizes", merfin = "pri_alt.merfin.alt.sizes", merfin_nofilter = "pri_alt.merfin.nofilter.alt.sizes", contig = "contig.alt.sizes", out = "Extended Data Figure 8 pri_alt.alt", gsize = 1033365587, w = 6, h = 5, title = "Alternate assembly - Polished primary and alternate")

block_n(unpolished = "unpolished.pri.sizes", freebayes = "pri.pri.sizes", merfin = "pri.merfin.pri.sizes", merfin_nofilter = "pri.merfin.nofilter.pri.sizes", contig = "contig.pri.sizes", out = "Extended Data Figure 8 pri.pri", gsize = 1033365587, w = 6, h = 5, title = "Primary assembly - Polished primary only")
block_n(unpolished = "unpolished.alt.sizes", contig = "contig.alt.sizes", out = "Extended Data Figure 8 pri.alt", gsize = 1033365587, w = 6, h = 5, title = "Alternate assembly - Polished primary only")
