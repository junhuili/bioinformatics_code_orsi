### subsample a fast using a list of header names ####

> library(Biostrings)
> newFASTA<-readDNAStringSet("633.fa", "fasta")
> head(newFASTA)
> names(newFASTA)=sapply(names(newFASTA),substr,start=1,stop=19)
> head(names(newFASTA))
[1] "CAM_READ_0238855565" "CAM_READ_0238855551" "CAM_READ_0238855555" "CAM_READ_0238855559" "CAM_READ_0238855561" "CAM_READ_0238855567"
> list<-read.table("633_COG_hits.txt")
> list<-as.character(list[,1])
> head(list)
> subset<-newFASTA[names(newFASTA)%in%list]
> head(subset)
>writeXStringSet (subset, "fasta.fa")
