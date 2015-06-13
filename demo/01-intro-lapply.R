## @knitr load-packages
library(rmr2)
library(rhdfs)
hdfs.init()

rmr.options(backend = "local")
# rmr.options(backend.parameters = list("mapreduce.map.java.opts=-Xmx800M",
#                                       "mapreduce.reduce.java.opts=-Xmx800M"))

## @knitr R ---------------------------------------------------------------

x <- 1:1000
lapply(x, function(x)cbind(x, x^2))


## @knitr rmr -------------------------------------------------------------

small.ints = to.dfs(1:1000)

a <- mapreduce(
    input = small.ints,
    map = function(k, v) cbind(v, v^2)
)

a()
from.dfs(a)



