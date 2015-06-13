library(rmr2)
library(rhdfs)
hdfs.init()

rmr.options(backend = "local")
rmr.options(backend.parameters = list("mapreduce.map.java.opts=-Xmx800M",
                                      "mapreduce.reduce.java.opts=-Xmx800M"))

# -------------------------------------------------------------------------

dir.create("data")
ebookLocal <- "..."

if(!file.exists(ebookLocal)) {
    url <- ""    ## <<< Your task is to specify the URL to the plain text (UTF-8) version
                 ## <<< The URL will be something like http://www.gutenberg.org/ebooks/4300.txt.utf-8
    download.file(url = url, destfile = ebookLocal)
}



file.exists(ebookLocal)
readLines(ebookLocal, n = 50)


# Copy file to HDFS -------------------------------------------------------


## <<< Complete the script below. Sucess is when you can see your file in hdfs

# Create an hdfs folder (hdfs.mkdir)


# List all the files in this folder (hdfs.ls)


# Create a copy of the file in hdfs (hdfs.put)


# Confirm the file is in hdfs (hdfs.ls)
