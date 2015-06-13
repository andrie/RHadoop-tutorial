library(rmr2)
library(rhdfs)
hdfs.init()

source("00-rmr-options.R")
setRmrOptions(local = TRUE)

# -------------------------------------------------------------------------

dir.create("data")
ebookLocal <- "data/ullyses.txt"

if(!file.exists(ebookLocal)) {
    download.file(url = "http://www.gutenberg.org/ebooks/4300.txt.utf-8",
                  destfile = ebookLocal)
}



file.exists(ebookLocal)
readLines(ebookLocal, n = 50)


# Copy file to HDFS -------------------------------------------------------

ebookHadoop <- dirname(ebookLocal)
hdfs.dircreate(ebookHadoop)
hdfs.ls(ebookHadoop)

hdfs.put(src = ebookLocal, dest = ebookHadoop)

hdfs.ls(ebookHadoop)
