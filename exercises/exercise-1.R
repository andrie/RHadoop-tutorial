library(rmr2)
library(rhdfs)
hdfs.init()

rmr.options(backend = "local")
rmr.options(backend.parameters = list("mapreduce.map.java.opts=-Xmx800M",
                                      "mapreduce.reduce.java.opts=-Xmx800M"))

# Exercise
#
# Use mapreduce to compute the mean of 1:1000



# R -----------------------------------------------------------------------

x <- 1:1000
# map
y <- sapply(x, sum)
# reduce
sum(y) / length(y)
Reduce(`+`, y) / length(y)


# rmr ---------------------------------------------------------------------

small.ints = to.dfs(1:1000)

a <- mapreduce(
    input = small.ints,
    map    = ...   ## <<< Your task is to write the mapper fucntion
    reduce = ...   ## <<< Your task is to write the reducer function
)

a()
from.dfs(a)
