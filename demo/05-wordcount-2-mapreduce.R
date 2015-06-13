library(rmr2)
library(rhdfs)
hdfs.init()

source("00-rmr-options.R")
setRmrOptions(local = TRUE)

# Word count --------------------------------------------------------------

# library(stringr)

ebookLocation <- "data/ullyses.txt"

x <- mapreduce(input = ebookLocation,
               input.format  =  "text",

               map = function(k, v){
                   words <- unlist(strsplit(v, split = "[[:space:][:punct:]]"))
                   words <- tolower(words)
                   words <- gsub("[0-9]", "", words)
                   words <- words[words != ""]
                   wordcount <- table(words)
                   keyval(
                       key = names(wordcount),
                       val = as.numeric(wordcount)
                   )
               },

               reduce = function(k, counts){
                   keyval(key = k,
                          val = sum(counts))
               }
)


# Retrieve results and prepare to plot ------------------------------------

x
returnValue <- from.dfs(x())
dat <- data.frame(
    word  = keys(returnValue),
    count = values(returnValue)
    )
dat <- dat[order(dat$count, decreasing=TRUE), ]
head(dat, 50)
with(head(dat, 25), plot(count, names = word))
