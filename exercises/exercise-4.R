library(rmr2)
library(rhdfs)
hdfs.init()

rmr.options(backend = "local")
rmr.options(backend.parameters = list("mapreduce.map.java.opts=-Xmx800M",
                                      "mapreduce.reduce.java.opts=-Xmx800M"))

# -------------------------------------------------------------------------

# Script to perform word count --------------------------------------------

ebookLocation <- ""  ## << speecify the local file path
dat <- readLines(ebookLocation, n = 100)
words <- unlist(strsplit(dat, split = ""))  ## << Specify a regular expression in the split
words <- tolower(words)
## << Optionally, remove all numerical digits as well as empty (blank) words

wordcount <-      ## << Do a word count here. Hint: use table or tapply
keyval(
    key = ...(wordcount),  ## << Specify the key function (replace the ...)
    val = ...(wordcount)   ## << Specify the value function (replace the ...)
)


