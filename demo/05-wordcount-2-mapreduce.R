library(rmr2)
library(rhdfs)
hdfs.init()

rmr.options(backend = "local")

# Word count --------------------------------------------------------------

ebookLocation <- "data/ullyses.txt"

m <- mapreduce(input = ebookLocation,
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


x <- from.dfs(m)
dat <- data.frame(
    word  = keys(x),
    count = values(x)
    )
dat <- dat[order(dat$count, decreasing=TRUE), ]
head(dat, 50)
with(head(dat, 25), plot(count, names = word))
