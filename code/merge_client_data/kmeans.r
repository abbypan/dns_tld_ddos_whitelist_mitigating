#kmeans
#options(echo=TRUE) 

args <- commandArgs(trailingOnly = TRUE)
print(args)
dfile <- args[1]
clnum <- args[2]
alg <- args[3]

d <- read.table(dfile,header=TRUE,sep=',')
somekey <- d$somekey
d$somekey <- NULL

(kc <- kmeans(d, clnum, algorithm = alg))
d$somekey <- somekey
d$kmeans <- kc$cluster
write.table(d, file=paste(dfile,'cluster',clnum,'algorithm',alg,'kmeans.out.csv',sep='.'), quote=FALSE, row.names=FALSE, sep=',')
save(kc, file=paste(dfile,'cluster',clnum,'algorithm',alg,'kmeans.RData',sep='.'))

#kc$size
#which(d$kmeans!=2)
#d[d$kmeans!=2,]
