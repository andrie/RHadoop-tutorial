library(rmr2)
rmr.options(backend = "local")
taxi.format <- make.input.format("csv", sep = ",", colClasses = "character", stringsAsFactors = FALSE, skip=1)
taxi.hdp <- "data/trip_data_1_small.csv"
x <- from.dfs(taxi.hdp, format = taxi.format)
values(x)[[6]]


x <- mapreduce(taxi.hdp, input.format = taxi.format)
values(from.dfs(x))[1:10, ]


x <- mapreduce(taxi.hdp, input.format = taxi.format,
               map = function(k, v){
                   v[[6]]
               })
values(from.dfs(x))[1:10]
