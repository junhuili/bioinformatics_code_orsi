# This script will make a histogram with error bars for each datapoint (e.g. standard deviations).

> newtable<-read.table("experiment_table.txt", row.names=1, header=T)
> newtable
        SQ_mean  SQ_std_dev
79  18829.00000  3467.70755
80  27836.76331  1304.79428
81   3338.85511   250.58016
76  27257.11169  3000.37484
77  41346.93570  1609.68400
78   2143.20310   121.36772
71  14726.00000    55.00000
72  28800.28787  1391.65873
73   1798.90580   183.68033
74  25158.19780  1866.03262
75  39334.19101  5889.37046
82    679.00784   191.32203
83 127954.49040 10862.15006
84 115690.32220 19263.55188
85    368.53571    26.38146
89 102265.54280 22713.58420
90    428.53067   101.51268
91     68.09457    16.84311

> barx<-barplot(newtable[,1], col=topo.colors(3, alpha=0.75), ylim=c(0,180000))

>     error.bar <- function(x, y, upper, lower=upper, length=0.1,...){
      if(length(x) != length(y) | length(y) !=length(lower) | length(lower) != length(upper))
      stop("vectors must be same length")
      arrows(x,y+upper, x, y-lower, angle=90, code=3, length=length, ...)
      }

error.bar(barx,newtable[,1],(newtable[,2]/2))
