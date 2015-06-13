gdescent <- function(input, iterations, dims, alpha){

    plane = t(rep(0, dims))
    M <- input
    for (i in 1:iterations) {
        # map
        Y <- M[, 1]
        X <- M[, -1]
        map <- Y * X * plogis(-Y * as.numeric(X %*% t(plane)))
        # reduce
        gradient <- colSums(map)

        plane <- plane + alpha * gradient
    }
    plane
}


#  ------------------------------------------------------------------------

library(ggplot2)
mean(diamonds$price)
quantile(diamonds$price)
glm(price > 5324 ~ ., data = diamonds, family = binomial)
iris2 <- transform(iris,
                   Virginica = Species == "versicolor",
                   Species = NULL
)
str(iris2)

dat <- cbind(Virginica = iris2$Virginica * 2 - 1,
             model.matrix(Virginica ~ ., iris2)
)
gdescent(dat, dims = 5, iterations = 1000, alpha = 0.01)

coef(glm(Virginica ~ ., data = iris2, family = binomial))
