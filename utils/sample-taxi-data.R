infolder  <- "C:/Users/adevries/downloads/Taxi/Foil2013"
outfolder <- "C:/Users/adevries/documents/github/RHadoop-tutorial/RHadoop-tutorial/data"

zips <- list.files(infolder, pattern = "trip_data.*", full.names = TRUE)

downSample <- function(infile, outfile, n = 1000, keepHeader = TRUE){
  message(basename(outfile))
  con <- file(infile, open = "r")
  conout <- file(outfile, open = "a")
  
  on.exit({
    close(con)
    close(conout)
  })
  
  if(keepHeader){
    header <- readLines(con, n = 1)
    writeLines(header, con = conout)
  }
  
  eof <- FALSE
  i <- 0
  while(!eof){
    dat <- readLines(con, n = n)
    if(length(dat) != n) eof <- TRUE
    keep <- sample(dat, 1)
    writeLines(keep, con = conout)
    i <- i + 1
    if (i %% n == 0) message(i/n)
  }

}

#  ------------------------------------------------------------------------


for(infile in zips){
  outfile <- file.path(outfolder, gsub("\\.csv$", "_sample.csv", basename(infile)))
  downSample(infile, outfile)
}

# file.remove(outfile)


dat <- readLines(outfile)
length(dat)
head(dat)
tail(dat)
