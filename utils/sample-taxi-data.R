folder <- "C:/Users/adevries/OneDrive - Microsoft/Conferences/2015-07-UseR!2015/UseR!2015-RHadoop/RScripts/RHadoop/data"


infile <- file.path(folder, "trip_data_1.csv")
outfile <- file.path(folder, "trip_data_1_sample.csv")


file.remove(outfile)

con <- file(infile, open = "r")
conout <- file(outfile, open = "a")


n <- 1000
header <- readLines(con, n = 1)
writeLines(header, con = conout)

eof <- FALSE
i <- 0
while(!eof){
  dat <- readLines(con, n = n)
  if(length(dat) != n) eof <- TRUE
  keep <- sample(dat, 1)
  writeLines(keep, con = conout)
  i <- i + 1
  if (i %% 1000 == 0) message(i)
}
close(conout)
close(con)


dat <- readLines(outfile)
head(dat)
tail(dat)
