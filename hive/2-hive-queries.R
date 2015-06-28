
source("0-configure.R")

# queries -----------------------------------------------------------------

# parameters
group_definition <- "substring(pickup_datetime, 12, 2)"
group_name <- "hour"

# count by weekday on the taxi dataset
query_group_by <- sprintf("SELECT %s AS %s, COUNT(*) AS count FROM %s GROUP BY %s",
                          group_definition, group_name, name_table, group_definition)
cat(query_group_by, ";", sep = "",
    file = file.path(folder_hql, "2-count-by-weekday.sql"))
count_hour <- rhive.query(query_group_by)
head(count_hour)
