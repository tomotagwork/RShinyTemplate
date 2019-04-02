library(shiny)
library(shinydashboard)

shinyAppDir = commandArgs(trailingOnly=TRUE)[1] 
#ipaddress = commandArgs(trailingOnly=TRUE)[2] 
port = commandArgs(trailingOnly=TRUE)[2] 

paste0("shinyAppDir: ", shinyAppDir)
#paste0("ipaddresss: ", ipaddress)
paste0("port: ", port)

runApp(appDir=shinyAppDir,host="0.0.0.0", port=as.numeric(port))