

# packages ----------------------------------------------------------------
# install.packages("RHive")
library(RHive)


# rhive -------------------------------------------------------------------
dirHive <- "/user/hive"
Sys.setenv(HIVE_HOME = "/usr/lib/hive")
rhive.init()
rhive.connect(host = "127.0.0.1", hiveServer2 = TRUE)


# table parameters --------------------------------------------------------
name_table <- "taxi_sample" # "/rmr2/trip_data"
hdfs_folder <- "/user/andrie.devries/taxi/sample"
field_separator <- ","



# other parameters --------------------------------------------------------
folder_hql <- "hql"


