# # Read a sample of data
# taxifile <- "data/trip_data_1.csv"
# dat <- read.csv(taxifile, nrow = 1e5, stringsAsFactors = FALSE)
#
#
# # Transform
# dat[["date"]] <- as.Date(dat[["pickup_datetime"]])
# dat[["wkday"]] <- weekdays(dat[["date"]])
# dat[["hour"]] <- strftime(dat[["date"]], format = "%H")
#
# # Aggregate
# aggregate(date ~ wkday + hour, dat, FUN = length)



#  ------------------------------------------------------------------------


# taxifile <- "data/trip_data_1.csv"
# dat <- read.csv(taxifile, nrow = 1e5, stringsAsFactors = FALSE)

# library(rmr2)
# rmr.options(backend = "local")
# taxi.hdp <- to.dfs(dat)
# taxi.hdp()


#  ------------------------------------------------------------------------

library(rmr2)
library(rhdfs)
rmr.options(backend = "hadoop")
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
taxi.hdp <- "taxi/trip_data_1_small.csv"
hdfs.ls("taxi")
# x <- from.dfs(taxi.hdp, format = taxi.format)
# head(values(x))

# taxi.hdp <- "taxi/trip_data_1_small.csv"

z <- mapreduce(input = taxi.hdp,
               input.format = taxi.format,
               map = taxi.map,
               reduce = taxi.reduce
#                combine = TRUE
)

zz <- from.dfs(z)
values(zz)
