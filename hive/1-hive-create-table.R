
source("hive/0-configure.R")

# define the metadata -----------------------------------------------------
# field format string
test_data <- read.csv("test-data.csv", as.is = TRUE)
class_data <- sapply(test_data, class)
class_data[class_data == "character"] <- "STRING"
class_data[class_data == "integer"] <- "INT"
class_data[class_data == "numeric"] <- "FLOAT"
string_fields <- paste(paste(names(class_data), class_data), collapse = ", ")

# query defining the table
query_create_external <- paste(
  
  sprintf("DROP TABLE IF EXISTS %s;", name_table),
  
  sprintf("CREATE EXTERNAL TABLE %s(%s) ROW FORMAT",
          name_table, string_fields),
  
  sprintf("DELIMITED FIELDS TERMINATED BY ','", field_separator),
  
  "LINES TERMINATED BY '\\n'",
  
  "STORED AS TEXTFILE",
  
  sprintf("LOCATION '%s';", hdfs_folder),
  
  sep = "\n"
)
cat(query_create_external,
    file = file.path(folder_hql, "1-create-external-table.sql"))


