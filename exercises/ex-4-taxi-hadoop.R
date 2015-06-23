library(rmr2)
library(rhdfs)
hdfs.init()

rmr.options(backend = "hadoop")

hdfs.ls("taxi")$file
homeFolder <- file.path("/user", Sys.getenv("USER"))
taxi.hdp <- file.path(homeFolder, "taxi")


headerInfo <- read.csv("data/dictionary_trip_data.csv", stringsAsFactors = FALSE)
colClasses <- as.character(as.vector(headerInfo[1, ]))

taxi.format <- make.input.format(format = "csv", sep = ",",
                                 col.names = names(headerInfo),
                                 colClasses = colClasses,
                                 stringsAsFactors = FALSE
)

taxi.map <- function(k, v){
  original <- v[[6]]
  date <- as.Date(original, origin = "1970-01-01")
  wkday <- weekdays(date)
  hour <- format(as.POSIXct(original), "%H")
  dat <- data.frame(date, hour)
  z <- aggregate(date ~ hour, dat, FUN = length)
  keyval(z[[1]], z[[2]])
}

taxi.reduce <- function(k, v){
  data.frame(hour = k, trips = sum(v), row.names = k)
}

m <- mapreduce(taxi.hdp, input.format = taxi.format,
               map = taxi.map,
               reduce = taxi.reduce
)

dat <- values(from.dfs(m))

library("ggplot2")
p <- ggplot(dat, aes(x = hour, y = trips, group = 1)) +
  geom_smooth(method = loess, span = 0.5,
              col = "grey50", fill = "yellow") +
  geom_line(col = "blue") +
  expand_limits(y = 0) +
  ggtitle("Sample of taxi trips in New York")


p
