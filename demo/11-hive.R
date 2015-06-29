

# configure ---------------------------------------------------------------
# install.packages("RHive")
library(RHive)
dirHive <- "/user/hive"
Sys.setenv(HIVE_HOME = "/usr/lib/hive")
rhive.init()
rhive.connect(host = "127.0.0.1", hiveServer2 = TRUE)


# queries -----------------------------------------------------------------

# test query
rhive.query("select * from sample_07")

# count by weekday on the taxi dataset
var_group_by <- "from_unixtime(unix_timestamp(dropoff_datetime,'yyyy-MM-dd'),'u')"
query_group_by <- sprintf("SELECT %s, COUNT(*) FROM trip_data GROUP BY %s",
                          var_group_by, var_group_by)
cat(query_group_by)
count_weekday <- rhive.query(query_group_by)
View(count_weekday)

