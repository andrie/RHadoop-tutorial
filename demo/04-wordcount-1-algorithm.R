library(rmr2)
library(rhdfs)
hdfs.init()

source("00-rmr-options.R")
setRmrOptions(local = TRUE)

# -------------------------------------------------------------------------

# Script to perform word count --------------------------------------------

ebookLocation <- "data/ullyses.txt"
dat <- readLines(ebookLocation, n = 100)
words <- unlist(strsplit(dat, split = "[[:space:][:punct:]]"))
words <- tolower(words)
words <- gsub("[0-9]", "", words)
words <- words[words != ""]
wordcount <- table(words)
keyval(
    key = names(wordcount),
    val = as.numeric(wordcount)
)


# Function to do word count -----------------------------------------------

wordcount <- function(location, n = -1L){
    dat <- readLines(location, n = n)
    words <- unlist(strsplit(dat, split = "[[:space:][:punct:]]"))
    words <- tolower(words)
    words <- gsub("[0-9]", "", words)
    words <- words[words != ""]
    words <- words[!is.na(words)]
    x <- table(words)
    keyval(
        key = names(x),
        val = as.numeric(x)
    )
}

x <- wordcount("data/ullyses.txt", n = -1)
lapply(x, head, 10)
lapply(x, tail, 10)
