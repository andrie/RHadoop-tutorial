iris2 <- transform(iris,
                   Setosa = Species == "virginica",
                   Species = NULL
)

model <- glm(Setosa ~ ., data = iris2, family = binomial)
table(iris2$Setosa,
      as.logical(round(
          predict(model, iris2, type = "response")
          , 2))
)
