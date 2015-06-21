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
head(x)


## @knitr from.dfs-2 ------------------------------------------------------

x <- from.dfs(taxi.hdp, format = taxi.format)
head(
    values(x)
)


## @knitr mapreduce-1-a ---------------------------------------------------

x <- mapreduce(taxi.hdp, input.format = taxi.format)
x
x()

## @knitr mapreduce-1-b ---------------------------------------------------
x <- mapreduce(taxi.hdp, input.format = taxi.format)
head(
    values(from.dfs(x))
)



## @knitr mapreduce-2 -----------------------------------------------------
x <- mapreduce(taxi.hdp, input.format = taxi.format,
               map = function(k, v){
                   original <- v[[6]]
                   original
               })
head(
    values(from.dfs(x))
)

## @knitr mapreduce-3 -----------------------------------------------------
x <- mapreduce(taxi.hdp, input.format = taxi.format,
               map = function(k, v){
                   original <- v[[6]]
                   date <- as.Date(original, origin = "1970-01-01")
                   wkday <- weekdays(date)
                   keyval(wkday, 1)
               })
head(
    keys(from.dfs(x)),
    20
)
head(
    values(from.dfs(x)),
    20
)

## @knitr mapreduce-4 -----------------------------------------------------
x <- mapreduce(taxi.hdp, input.format = taxi.format,
               map = function(k, v){
                   original <- v[[6]]
                   date <- as.Date(original, origin = "1970-01-01")
                   wkday <- weekdays(date)
                   keyval(wkday, 1)
               },
               reduce = function(k, v){
                   keyval(k, sum(v))
               })
head(
    keys(from.dfs(x))
)
head(
    values(from.dfs(x))
)

## @knitr mapreduce-5 -----------------------------------------------------
x <- mapreduce(taxi.hdp, input.format = taxi.format,
               map = function(k, v){
                   original <- v[[6]]
                   date <- as.Date(original, origin = "1970-01-01")
                   wkday <- weekdays(date)
                   dat <- data.frame(date, wkday)
                   z <- aggregate(date ~ wkday, dat, FUN = length)
                   keyval(z[[1]], z[[2]])
               })
keys(from.dfs(x))
values(from.dfs(x))

## @knitr mapreduce-6 -----------------------------------------------------
x <- mapreduce(taxi.hdp, input.format = taxi.format,
               map = function(k, v){
                   original <- v[[6]]
                   date <- as.Date(original, origin = "1970-01-01")
                   wkday <- weekdays(date)
                   dat <- data.frame(date, wkday)
                   z <- aggregate(date ~ wkday, dat, FUN = length)
                   keyval(z[[1]], z[[2]])
               },
               reduce = function(k, v){
                   data.frame(hour = k, trips = sum(v), row.names = k)
               })
keys(from.dfs(x))
values(from.dfs(x))

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
x <- mapreduce(taxi.hdp, input.format = taxi.format,
               map = taxi.map,
               reduce = taxi.reduce
               )
keys(from.dfs(x))
dat <- values(from.dfs(x))
dat

## @knitr mapreduce-7-plot ------------------------------------------------


library(ggplot2)
ggplot(dat, aes(x = hour, y = trips, group = 1)) +
    geom_line(col = "blue") +
    expand_limits(y = 0) +
    geom_smooth(method = loess, span = 0.5, alpha = 0.2, col = "grey50") +
    ggtitle("Sample of taxi trips in New York")
