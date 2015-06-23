##  load-packages
library(rmr2)
library(rhdfs)
hdfs.init()

rmr.options(backend = "local")

##  R ---------------------------------------------------------------

x <- 1:1000
lapply(x, function(x)cbind(x, x^2))


##  rmr -------------------------------------------------------------

small.ints = to.dfs(1:1000)

a <- mapreduce(
    input = small.ints,
    map = function(k, v) cbind(v, v^2)
)

a()
from.dfs(a)



