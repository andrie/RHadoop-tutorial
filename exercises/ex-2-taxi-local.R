##  load-packages ---------------------------------------------------
library(rmr2)
rmr.options(backend = "local")


taxi.hdp <- "data/trip_data_1_sample.csv"

##  make.input.format-with-colnames-1 -------------------------------

headerInfo <- read.csv("data/dictionary_trip_data.csv", stringsAsFactors = FALSE)
headerInfo
colClasses <- as.character(as.vector(headerInfo[1, ]))
names(headerInfo)
colClasses

taxi.format <- make.input.format(format = "csv", sep = ",",
                                 col.names = names(headerInfo),
                                 colClasses = colClasses,
                                 stringsAsFactors = FALSE
)

x <- from.dfs(taxi.hdp, format = taxi.format)
str(values(x))


taxi.map <- function(k, v){
    original <- v[[6]]
    date <- as.Date(original, origin = "1970-01-01")
    wkday <- weekdays(date)
    dat <- data.frame(date, wkday)
    z <- aggregate(date ~ wkday, dat, FUN = length)
    keyval(z[[1]], z[[2]])
}

taxi.reduce <- function(k, v){
    data.frame(weekday = k, trips = sum(v), row.names = k)
}

m <- mapreduce(taxi.hdp, input.format = taxi.format,
               map = taxi.map,
               reduce = taxi.reduce
)
keys(from.dfs(m))
values(from.dfs(m))

