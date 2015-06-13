# Wrapper around rmr.options to make setup easier
setRmrOptions <- function(local = TRUE, backend = if(local) "local" else  "hadoop", java.opts = "-Xmx800M"){
    if(backend == "local"){
        rmr.options(backend = "local")
    } else {
        java.args <- c("mapreduce.map.java.opts", "mapreduce.reduce.java.opts")
        rmr.options(backend = "hadoop",
                    backend.parameters = as.list(paste(java.args, java.opts, sep = " = "))
        )
    }
}
