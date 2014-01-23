### access metagenomes from MG-RAST

cc <- collection ("4523110.3;4517863.3;4517860.3;4517857.3;4517862.3;4523109.3;4517856.3;4517865.3;4517861.3;4517858.3;4517864.3;4517855.3", count = c (annotation = "function", level = "level3", source = "COG"), normed = c (annotation = "function", level = "level3", source = "COG", entry = "normed"))

#### normalize matR table, convert to matrix, run kruskal-wallis statistical test ##### 

> cc <- collection ("4523110.3;4517863.3;4517860.3;4517857.3;4517862.3;4523109.3;4517856.3;4517865.3;4517861.3;4517858.3;4517864.3;4517855.3", normed = c (annotation = "function", level = "level3", source = "COG", entry = "normed"))
request posted: counts : function : level3 : COG : na

> cc
mgm4523110.3 mgm4517863.3 mgm4517860.3 mgm4517857.3 mgm4517862.3 mgm4523109.3 mgm4517856.3 mgm4517865.3 mgm4517861.3 mgm4517858.3 mgm4517864.3 mgm4517855.3 

$normed  (counts : function : level3 : COG : na)

> head(cc$normed)
        mgm4517855.3 mgm4517856.3 mgm4517857.3 mgm4517858.3 mgm4517860.3 mgm4517861.3 mgm4517862.3 mgm4517863.3 mgm4517864.3 mgm4517865.3 mgm4523109.3 mgm4523110.3
COG0001          133           56           13          167           28          148           88           15          158           38           84            9
COG0002          278           64           17          281           32          285          107           24          243           72           47            4
COG0003          294           46           22          245           41          225          102           30          233           53            2            0
COG0004          609           60           42          512           66          569          171           48          445           65          146           18
COG0005          117           19            9           72           15           97           34           11           89           21           34            7
COG0006          711           72           24          655           58          724          194           33          445           71          155           18

> cc.matrix<-as.matrix(cc$normed)
> cc.normed<-normalize(cc.matrix, method=c("standard"))
> head(cc.normed)
        mgm4517855.3 mgm4517856.3 mgm4517857.3 mgm4517858.3 mgm4517860.3 mgm4517861.3 mgm4517862.3 mgm4517863.3 mgm4517864.3 mgm4517865.3 mgm4523109.3 mgm4523110.3
COG0001         0.33         0.38         0.32         0.34         0.36         0.34         0.36         0.34         0.34         0.35         0.41         0.39
COG0002         0.37         0.39         0.35         0.37         0.37         0.38         0.37         0.39         0.37         0.41         0.36         0.31
COG0003         0.38         0.37         0.37         0.36         0.39         0.37         0.37         0.41         0.37         0.38         0.15         0.11
COG0004         0.42         0.39         0.43         0.41         0.44         0.43         0.41         0.45         0.41         0.40         0.45         0.47
COG0005         0.32         0.29         0.29         0.28         0.30         0.31         0.28         0.31         0.31         0.31         0.34         0.37
COG0006         0.43         0.40         0.38         0.43         0.42         0.44         0.42         0.42         0.41         0.41         0.45         0.47
> col.groups<-c(1,1,1,1,2,2,2,2,3,3,3,3)
> results<-sigtest(cc.normed, groups=col.groups, test="Kruskal-Wallis")


#### transform p values from KW test into a column that can be added onto matrix #####


> results.newtable<-sigtest(newtable.matrix, groups=col.groups, test="Kruskal-Wallis")
> pvalues<-t(results.newtable$p.value)
> pvalues.t<-t(pvalues)
> head(pvalues.t)
      [,1]
[1,] 0.155
[2,] 0.155
[3,] 0.779
[4,] 0.155
[5,] 0.155
[6,] 0.077

### add the pvalues from KW test as last column onto cc.normed ####

> cc.normed.pvalues<-cbind(cc.normed, pvalues.t)

### select only those COGs that fall below a significance threshold ###

> dim(cc.normed.pvalues)
[1] 3967   13
> cc.normed.subselect<-subset(cc.normed.pvalues, cc.normed.pvalues[,13] < 0.01)
> dim(cc.normed.subselect)
[1] 41 13

### and remove the pvalue column ###

>cc.normed.subselect.nopvalues<-cc.normed.subselect[,-13]
