library(rmr2)
library(rhdfs)
hdfs.init()

source("00-rmr-options.R")
setRmrOptions(local = !TRUE)

# -------------------------------------------------------------------------

X <- matrix(rnorm(2000), ncol = 10)
y <- as.matrix(rnorm(200))
design.mat <- cbind(y, X)
keyed.design <- to.dfs(design.mat)

# The next is a reusable reduce function that just sums a list of matrices, ignores the key.

Sum <- function(., YY) keyval(1, list(Reduce('+', YY)))

# The big matrix is passed to the mapper in chunks of complete rows. Smaller cross-products are computed for these submatrices and passed on to a single reducer, which sums them together. Since we have a single key a combiner is mandatory and since matrix sum is associative and commutative we certainly can use it here.

XtX <- values(from.dfs(
    mapreduce(input = keyed.design,
              map = function(., Xi) {
                  yi = Xi[, 1]
                  Xi = Xi[, -1]
                  keyval(1, list(t(Xi) %*% Xi))
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
                  keyval(1, list(t(Xi) %*% yi))
              },
              reduce = Sum,
              combine = TRUE)
))[[1]]


# And finally we just need to call solve.

solve(XtX, Xty)
