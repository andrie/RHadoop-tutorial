library(rmr2)
library(rhdfs)
rmr.options(backend = "local")
hdfs.init()

taxi.map <- function(k, v){
    # Transform
    original <- v[[6]]
    idx <- !grepl("pickup_datetime", original)
    original <- original[idx]
    date <- as.Date(original, origin = "1970-01-01")
    dat <- data.frame(original,
                      date = date,
                      wkday = weekdays(date),
                      hour = strftime(date, format = "%H")
    )

    # Aggregate
    z <- aggregate(date ~ wkday + hour, dat, FUN = length)
    names(z)[3] <- "count"
    keyval(1, z)
}

taxi.reduce <- function(k, v){
    aggregate(count ~ wkday + hour, v, FUN = sum)
}

taxi.format <- make.input.format("csv", sep = ",", colClasses = "character", stringsAsFactors = FALSE)
taxi.hdp <- "data/trip_data_1_sample.csv"
# taxi.hdp <- from.dfs(taxi.hdp, format = taxi.format)
hdfs.ls("taxi")

z <- mapreduce(input = taxi.hdp,
               input.format = taxi.format,
               map = taxi.map,
               reduce = taxi.reduce
               #                combine = TRUE
)

zz <- from.dfs(z)
values(zz)
