# The purpose of this file is to unzip the data from the files downloaded from
# the CitiBike website.
# https://stackoverflow.com/questions/33203800/unzip-a-zip-file

files <- list.files(path="Zip/", pattern=".zip$")
outDir <- "Raw/"
for (i in files) {
  unzip(paste0("Zip/",i), exdir=outDir)
}