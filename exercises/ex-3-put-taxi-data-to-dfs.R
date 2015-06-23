library(rhdfs)
hdfs.init()

hdfs.ls("data")
hdfs.ls("taxi")

localFiles <- dir("data", pattern = "_sample.csv", full.names = TRUE)
localFiles
hdfs.mkdir("taxi/sample")
hdfs.put(localFiles, "taxi/sample")
hdfs.ls("taxi/sample")

hdfs.ls("taxi/sample")$file
