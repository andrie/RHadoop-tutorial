library(rmr2)
rmr.options(backend = "local")

logistic.regression <- function(input, iterations, dims, alpha){

    plane <- t(rep(0, dims))
    g <- function(z) 1 / (1 + exp(-z))

    lr.map <- function(., M) {
        Y <- M[,1]
        X <- M[,-1]
        keyval(
            1,
            Y * X * g(-Y * as.numeric(X %*% t(plane)))
        )
    }

    lr.reduce <- function(k, Z){
        keyval(k, t(as.matrix(apply(Z, 2, sum))))
    }

    for (i in 1:iterations) {
        x <- mapreduce(
            input,
            map = lr.map,
            reduce = lr.reduce,
            combine = TRUE
        )
        gradient <- values(from.dfs(x))
        plane <- plane + alpha * gradient
    }
    plane
}



# Create design matrix ----------------------------------------------------

iris2 <- transform(iris,
                   Virginica = Species == "virginica",
                   Species = NULL
)


dat <- cbind(Virginica = iris2$Virginica * 2 - 1,
             model.matrix(Virginica ~ ., iris2)
)
str(dat)
head(dat)

# Send design matrix to dfs -----------------------------------------------

hdp.iris2 <- to.dfs(dat)
hdp.iris2()
from.dfs(hdp.iris2)
model <- logistic.regression(hdp.iris2, dims = 5, iterations = 5, alpha = 0.1)

model


# Inspect confusion matrix ------------------------------------------------

# table(iris2$Virginica,
#       as.logical(round(
#           predict(model, iris2, type = "response")
#           , 2))
# )
