library(rmr2)
library(rhdfs)
hdfs.init()

rmr.options(backend = "local")
rmr.options(backend.parameters = list("mapreduce.map.java.opts=-Xmx800M",
                                      "mapreduce.reduce.java.opts=-Xmx800M"))

# Word count --------------------------------------------------------------

# library(stringr)

ebookLocation <- "" ## << Specify the file location of your ebook

x <- mapreduce(input = ebookLocation,
               input.format  =  "text",

               map = function(k, v){
                   words <- unlist(strsplit(v, split = "[[:space:][:punct:]]"))
                   words <- tolower(words)
                   words <- gsub("[0-9]", "", words)
                   words <- words[words != ""]
                   wordcount <- table(words)
                   keyval(
                       key = ...,  ## << Specify the key function (replace the ...)
                       val = ...   ## << Specify the val function (replace the ...)
                   )
               },

               reduce = function(k, counts){
                   keyval(key = k,
                          val = ...(counts))  ## << Specify the val function (replace the ...)
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
