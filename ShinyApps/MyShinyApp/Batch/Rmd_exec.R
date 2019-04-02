library(rmarkdown)
library(data.table)
library(stringr)

rmdFile <- commandArgs(trailingOnly = TRUE)[1]
inputFile <- commandArgs(trailingOnly = TRUE)[2]
outputFile <- commandArgs(trailingOnly = TRUE)[3]

render(rmdFile,
       params = list(argTargetFile=inputFile),
       output_file=outputFile
)

        
