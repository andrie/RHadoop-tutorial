## @knitr load-packages
library(rmr2)
library(rhdfs)
hdfs.init()

rmr.options(backend = "local")
rmr.options(backend.parameters = list("mapreduce.map.java.opts=-Xmx800M",
                                      "mapreduce.reduce.java.opts=-Xmx800M"))

## @knitr R ---------------------------------------------------------------

groups <- rbinom(32, n = 50, prob = 0.4)
tapply(groups, groups, length)


## @knitr rmr -------------------------------------------------------------

dfs.groups <- to.dfs(groups)

x <- mapreduce(input = dfs.groups,
               map = function(., v) keyval(v, 1),
               reduce = function(k, vv) keyval(k, length(vv))
)

y <- from.dfs(x)

as.data.frame(y)[order(y[["key"]]), ]
