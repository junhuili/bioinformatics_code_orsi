library(RColorBrewer)
library(gplots)

Totaltax<-read.table("/Users/williamorsi1/Desktop/R_working_directory/amino_acid_metabolism_heatmap_v2_input.txt",header=TRUE)
heatmap.2(Totaltax, Colv=NA, Rowv=NA, key=TRUE, keysize=1, cexCol=1, cexRow=1, trace="none", margins=c(20,10), col=brewer.pal(9,"OrRd"))
