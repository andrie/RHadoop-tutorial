library(rmr2)
library(rhdfs)
hdfs.init()

rmr.options(backend = "local")
rmr.options(backend.parameters = list("mapreduce.map.java.opts=-Xmx800M",
                                      "mapreduce.reduce.java.opts=-Xmx800M"))

# -------------------------------------------------------------------------

X <- matrix(rnorm(2000), ncol = 10)
y <- as.matrix(rnorm(200))
design.mat <- cbind(y, X)
keyed.design <- ...  ## << Your task is to send the design matrix to dfs

# The next is a reusable reduce function that just sums a list of matrices, ignores the key.

Sum <- function(., YY) keyval(1, list(Reduce('+', YY)))

# The big matrix is passed to the mapper in chunks of complete rows. Smaller cross-products are computed for these submatrices and passed on to a single reducer, which sums them together. Since we have a single key a combiner is mandatory and since matrix sum is associative and commutative we certainly can use it here.

XtX <- values(from.dfs(
    mapreduce(input = keyed.design,
              map = function(., Xi) {
                  yi = Xi[, 1]
                  Xi = Xi[, -1]
                  keyval(1, list(...) ## << Replace the ... with a matrix computation X'X
              },
              reduce = Sum,
              combine = TRUE)
))[[1]]

# The same pretty much goes on also for vector y

Xty <- values(from.dfs(
    mapreduce(input = keyed.design,
              map = function(., Xi) {
                  yi = Xi[, 1]
                  Xi = Xi[, -1]
                  keyval(1, list(...)) ## << Replace the ... with a matrix computation X'y
              },
              reduce = Sum,
              combine = TRUE)
))[[1]]


# And finally we just need to call solve.

solve(..., ...)  ## << Solve for b, given X'X and X'y
