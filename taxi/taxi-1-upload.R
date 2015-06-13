library(rmr2)
library(rhdfs)
hdfs.init()

taxifile <- "data/trip_data_1.csv"
file.exists(taxifile)

# Create small extract of taxi dat
dat <- readLines(taxifile, n = 100)
con <- file("data/trip_data_1_small.csv", open = "w")
writeLines(dat, con)
close(con)
list.files("data")
hdfs.put("data/trip_data_1_small.csv", "taxi/trip_data_1_small.csv")
hdfs.ls("taxi")

# Put taxi data in dfs
hdfs.ls(".")
hdfs.mkdir("taxi")

hdfs.put(taxifile, file.path("taxi", basename(taxifile)))
hdfs.ls(".")
