

# @knitr configure-rhive --------------------------------------------------
# install.packages("RHive")
library(RHive)
dirHive <- "/user/hive"
Sys.setenv(HIVE_HOME = "/usr/lib/hive")
rhive.init()
rhive.connect(host = "127.0.0.1", hiveServer2 = TRUE)




# @knitr row-count --------------------------------------------------------
query_count <- "SELECT COUNT(*) FROM taxi_sample"


# @knitr build-row-count --------------------------------------------------
name_table <- "taxi_sample"
query_count <- sprintf("SELECT COUNT(*) FROM %s",
                       name_table)
cat(query_count)



# @knitr run-row-count ----------------------------------------------------
table_count <- rhive.query(query_count)
head(table_count)



# @knitr define-hour ------------------------------------------------------
query_hour <- "
SELECT pickup_datetime, substring(pickup_datetime, 12, 2) AS hour
  FROM taxi_sample LIMIT 100"



# @knitr build-define-hour ------------------------------------------------
field_time <- "pickup_datetime"
field_hour <- sprintf("substring(%s, 12, 2)",
                      field_time)
query_hour <- sprintf(
  "SELECT %s, %s AS hour
  FROM %s LIMIT 100",
  field_time, field_hour, name_table)
cat(query_hour)



# @knitr run-define-hour --------------------------------------------------
head(rhive.query(query_hour))



# @knitr count-by-hour ----------------------------------------------------
query_count <- "
SELECT substring(pickup_datetime, 12, 2) AS hour, COUNT(*) AS count
FROM taxi_sample
GROUP BY substring(pickup_datetime, 12, 2)"


# @knitr build-count-by-hour ----------------------------------------------
query_count <- sprintf(
  "SELECT %s AS hour, COUNT(*) AS count
FROM %s
GROUP BY %s",
  field_hour, name_table, field_hour)
cat(query_count)


# @knitr run-count-by-hour ------------------------------------------------
head(rhive.query(query_count))


