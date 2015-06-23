## @knitr rhdfs -----------------------------------------------------------
library(rhdfs)
hdfs.init()

localFiles <- dir("data", pattern = "_sample.csv", full.names = TRUE)
localFiles
hdfs.mkdir("taxi")
hdfs.put(localFiles, "taxi")
hdfs.ls("taxi")

hdfs.ls("taxi")$file
