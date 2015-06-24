library(rhdfs)
hdfs.init()

# List taxi data files in local file system
localFiles <- dir("data", pattern = "_sample.csv", full.names = TRUE)
localFiles

# Put files into dfs
hdfs.mkdir("taxi/sample")
hdfs.put(localFiles, "taxi/sample")
hdfs.ls("taxi/sample")

hdfs.ls("taxi/sample")$file
