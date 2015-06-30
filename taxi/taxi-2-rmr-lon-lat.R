library(rmr2)


# Define compute context --------------------------------------------------

### local
rmr.options(backend = "local")
taxi.hdp <- "data/trip_data_1_sample.csv"

### hadoop
rmr.options(backend = "hadoop")
homeFolder <- file.path("/user", Sys.getenv("USER"))
taxi.hdp <- file.path(homeFolder, "taxi", "sample")
rmr.options(backend.parameters = list(
  "mapreduce.map.java.opts=-Xmx800M", "mapreduce.reduce.java.opts=-Xmx800M"))



# Define input format -----------------------------------------------------

headerInfo <- read.csv("data/dictionary_trip_data.csv", stringsAsFactors = FALSE)
colClasses <- as.character(as.vector(headerInfo[1, ]))

taxi.format <- make.input.format(format = "csv", sep = ",",
                                 col.names = names(headerInfo),
                                 colClasses = colClasses,
                                 stringsAsFactors = FALSE
)


# Helper functions to compute great circle distance -----------------------


# Calculates the geodesic distance between two points specified by 
# radian latitude/longitude using the Spherical Law of Cosines (slc)
# Source: http://www.r-bloggers.com/great-circle-distance-calculations-in-r/
gcd.slc <- function(long1, lat1, long2, lat2) {
  R <- 6371 # Earth mean radius [km]
  d <- acos(sin(lat1)*sin(lat2) + cos(lat1)*cos(lat2) * cos(long2-long1)) * R
  return(d) # Distance in km
}

# Convert degrees to radians
deg2rad <- function(deg) return(deg*pi/180)


# Mapper: compute trip time for subset of trips originating at JFK --------

taxi.map <- function(k, v){
  #   browser()
  lon <- deg2rad(v$pickup_longitude)
  lat <- deg2rad(v$pickup_latitude)
  jfk_lon <- deg2rad(-73.779564)
  jfk_lat <- deg2rad(40.646908)
  distToJfk <- gcd.slc(lon, lat, jfk_lon, jfk_lat)
  
  lon <- deg2rad(v$dropoff_longitude)
  lat <- deg2rad(v$dropoff_latitude)
  ts_lon <- deg2rad(-73.985131)
  ts_lat <- deg2rad(40.758895)
  distToTimesSquare <- gcd.slc(lon, lat, jfk_lon, jfk_lat)
  
  original <- v[distToJfk < 1.6 & distToTimesSquare < 1.6, ]
  time <- as.POSIXct(original$dropoff_datetime) - as.POSIXct(original$pickup_datetime)
  time <- as.numeric(time)
  
  keep <- time > 600 # 10 minutes artificial threshold - noisy data
  original <- original[keep, ]
  time <- time[keep]
  
  if(nrow(original) == 0){
    z <- data.frame(wkday="None", hour="00", 
                    time = matrix(c(time.1=0, time.2=0), nrow=1),
                    stringsAsFactors = FALSE
    )
  } else {
    date <- as.Date(original[[6]], origin = "1970-01-01")
    wkday <- weekdays(date)
    hour <- format(as.POSIXct(original[[6]]), "%H")
#     browser()
    dat <- data.frame(wkday, hour, time)
    z <- aggregate(time ~ wkday + hour, dat, 
                   FUN = function(x)cbind(sum(x), length(x)))
  }
  keyval(z[, 1:2], z[, 3])
}

# Reducer -----------------------------------------------------------------

taxi.reduce <- function(k, v){
#   browser()
  time = sum(v[, 1])
  count = sum(v[, 2])
  cbind(k, duration = time/count / 60) # convert seconds to minutes
}



# Mapreduce ---------------------------------------------------------------

m <- mapreduce(taxi.hdp, input.format = taxi.format,
               map = taxi.map,
               reduce = taxi.reduce
)
keys(from.dfs(m))
dat <- values(from.dfs(m))
dat


# Plot results ------------------------------------------------------------

library("ggplot2")
ggplot(dat, aes(x = hour, y = duration, group = wkday)) +
  geom_point(col = "blue") +
  geom_line() +
  expand_limits(y = 0) +
  facet_grid(wkday ~ .) +
  ggtitle("Sample of taxi trips in New York")


