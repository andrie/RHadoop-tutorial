library(rmr2)
library(rhdfs)
hdfs.init()

taxifile <- "data/trip_data_1_sample.csv"
file.exists(taxifile)

list.files("data")
hdfs.ls("data")

hdfs.ls("taxi")
hdfs.put("data/trip_data_1_sample.csv", "taxi/trip_data_1_sample.csv")
hdfs.ls("taxi")

# Put taxi data in dfs
hdfs.ls(".")
hdfs.mkdir("taxi")

hdfs.put(taxifile, file.path("taxi", basename(taxifile)))
hdfs.ls(".")
