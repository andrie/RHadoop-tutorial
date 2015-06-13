library(rmr2)
library(rhdfs)
hdfs.init()

rmr.options(backend = "local")
rmr.options(backend.parameters = list("mapreduce.map.java.opts=-Xmx800M",
                                      "mapreduce.reduce.java.opts=-Xmx800M"))

# -------------------------------------------------------------------------

groups <- rbinom(32, n = 50, prob = 0.4)
tapply(groups, groups, length)


dfs.groups <- to.dfs(groups)

x <- mapreduce(input = dfs.groups,
               map = function(., v) ...,    ## <<< Your task is to write the mapper
               reduce = function(k, vv) ... ## <<< Your task is to write the reducer
)

y <- from.dfs(x)

as.data.frame(y)[order(y[["key"]]), ]
