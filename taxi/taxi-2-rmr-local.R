## @knitr load-packages ---------------------------------------------------
library(rmr2)
rmr.options(backend = "local")

## @knitr make.input.format -----------------------------------------------
taxi.format <- make.input.format("csv", sep = ",",
                                 colClasses = "character",
                                 stringsAsFactors = FALSE
)




## @knitr from.dfs-1 ------------------------------------------------------

taxi.hdp <- "data/trip_data_1_sample.csv"
x <- from.dfs(taxi.hdp, format = taxi.format)
str(x)


## @knitr from.dfs-2 ------------------------------------------------------

x <- from.dfs(taxi.hdp, format = taxi.format)
head(
    values(x)
)

## @knitr make.input.format-with-colnames-1 -------------------------------

headerInfo <- read.csv("data/dictionary_trip_data.csv", stringsAsFactors = FALSE)
headerInfo
colClasses <- as.character(as.vector(headerInfo[1, ]))
names(headerInfo)
colClasses

## @knitr make.input.format-with-colnames-2 -------------------------------

taxi.format <- make.input.format(format = "csv", sep = ",",
                                 col.names = names(headerInfo),
#                                  colClasses = colClasses,
                                 stringsAsFactors = FALSE
)

x <- from.dfs(taxi.hdp, format = taxi.format)
str(values(x))


## @knitr mapreduce-1-a ---------------------------------------------------

m <- mapreduce(taxi.hdp, input.format = taxi.format)
m
m()

## @knitr mapreduce-1-b ---------------------------------------------------
m <- mapreduce(taxi.hdp, input.format = taxi.format)
head(
    values(from.dfs(m))
)



## @knitr mapreduce-2 -----------------------------------------------------
taxi.map <- function(k, v){
    original <- v[[6]]
    original
}
m <- mapreduce(taxi.hdp, input.format = taxi.format,
               map = taxi.map
)
head(
    values(from.dfs(m))
)

## @knitr mapreduce-3 -----------------------------------------------------
taxi.map <- function(k, v){
    original <- v[[6]]
    date <- as.Date(original, origin = "1970-01-01")
    wkday <- weekdays(date)
    keyval(wkday, 1)
}
m <- mapreduce(taxi.hdp, input.format = taxi.format,
               map = taxi.map
)
head(
    keys(from.dfs(m)),
    20
)
head(
    values(from.dfs(m)),
    20
)

## @knitr mapreduce-4 -----------------------------------------------------
taxi.map <- function(k, v){
    original <- v[[6]]
    date <- as.Date(original, origin = "1970-01-01")
    wkday <- weekdays(date)
    keyval(wkday, 1)
}
taxi.reduce <- function(k, v){
    keyval(k, sum(v))
}
m <- mapreduce(taxi.hdp, input.format = taxi.format,
               map = taxi.map,
               reduce = taxi.reduce
)
head(
    keys(from.dfs(m))
)
head(
    values(from.dfs(m))
)

## @knitr mapreduce-5 -----------------------------------------------------
taxi.map <- function(k, v){
    original <- v[[6]]
    date <- as.Date(original, origin = "1970-01-01")
    wkday <- weekdays(date)
    dat <- data.frame(date, wkday)
    z <- aggregate(date ~ wkday, dat, FUN = length)
    keyval(z[[1]], z[[2]])
}
m <- mapreduce(taxi.hdp, input.format = taxi.format,
               map = taxi.map
)
keys(from.dfs(m))
values(from.dfs(m))

## @knitr mapreduce-6 -----------------------------------------------------
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

## @knitr mapreduce-7-a ---------------------------------------------------
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

## @knitr mapreduce-7-b ---------------------------------------------------
m <- mapreduce(taxi.hdp, input.format = taxi.format,
               map = taxi.map,
               reduce = taxi.reduce
)
keys(from.dfs(m))
dat <- values(from.dfs(m))
dat

## @knitr mapreduce-7-plot-1 ----------------------------------------------

library("ggplot2")
p <- ggplot(dat, aes(x = hour, y = trips, group = 1)) +
    geom_smooth(method = loess, span = 0.5,
                col = "grey50", fill = "yellow") +
    geom_line(col = "blue") +
    expand_limits(y = 0) +
    ggtitle("Sample of taxi trips in New York")


## @knitr mapreduce-7-plot-2 ----------------------------------------------
p
