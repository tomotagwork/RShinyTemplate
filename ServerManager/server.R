# server.R


### Options ###################################################################
options(scipen=100)
options(digits.secs=6)


### Common Functions ###################################################################
func_getShinyAppList <- function(){
  listResult <- list.dirs(shinyAppDir, recursive=FALSE, full.names=FALSE)
  if(length(listResult)<=0){
    listResult <- c("")
  }
  return (listResult)
}

func_getPortList <- function(){
  dfPortList <- data.frame()
  if (file.exists(portListFileName) && file.info(portListFileName)$size > 0){
    dfPortList <- fread(portListFileName, data.table=FALSE, sep=",")
    dfPortList <- dplyr::arrange(dfPortList, portNumber)
  }
  return(dfPortList)
}

func_getServerInfoFileList <- function(){
  dfTargetFilesInfo <- data.frame()
  all_files <- list.files(serverInfoDir)
  if(length(all_files)>0){
    target_files <- all_files[grep("\\.csv$", all_files)]
    dfTargetFilesInfo <- file.info(paste0(serverInfoDir, target_files))
    dfTargetFilesInfo$fileFullPath <- rownames(dfTargetFilesInfo)
    dfTargetFilesInfo$fileName <- stringr::str_replace_all(dfTargetFilesInfo$fileFullPath, ".*/", "")
    
    if (nrow(dfTargetFilesInfo)>0){
      #order by modified time(descending order)
      dfTargetFilesInfo <- dplyr::arrange(dfTargetFilesInfo, desc(mtime))
      
      #add column for display text
      dfTargetFilesInfo$dispText <- paste0(dfTargetFilesInfo$fileName, " (", dfTargetFilesInfo$mtime, " / ",
                                           as.integer(dfTargetFilesInfo$size/1024),"KB)")
    }
  }
  return(dfTargetFilesInfo)
}

func_getProcessInfo <- function(){
  dfResult <- data.frame()
  
  #get Listen port and PID from netstat command
  netstatInfo <- system2("netstat", args=c("-anop", "TCP"), stdout=TRUE, invisible=TRUE)
  netstatInfo <- netstatInfo[stringr::str_detect(netstatInfo, "LISTEN")]
  #temp <- temp[stringr::str_detect(temp, paste0(":",portTest))]
  netstatInfo <- stringr::str_split(netstatInfo, "[ ]+", simplify=TRUE)
  listListenPort <- stringr::str_split(netstatInfo[,3], ":", simplify=TRUE)[,2]
  dfNetstatInfo <- data.frame(PID=as.integer(netstatInfo[,6]), portNumber=as.integer(listListenPort))
  
  #get PID and ProcessName
  dfPsInfo <- ps::ps()
  dfPsInfo <- data.frame(ProcessName=dfPsInfo$name, PID=dfPsInfo$pid)
  
  #merge (ProcessName, PID, portNumber)
  dfProcessInfo <- dplyr::right_join(dfPsInfo, dfNetstatInfo, by=c("PID"))
  
  if (nrow(dfProcessInfo)) {
    #extract Rscript.exe
    dfProcessInfo <- dplyr::filter(dfProcessInfo, ProcessName=="Rscript.exe")
    
    if (nrow(dfProcessInfo)) {
      #extract Rscript.exe
      dfResult <- dfProcessInfo
      
    }
    
  }
  
  
  return(dfResult)
}

func_getServerInfo <- function(){
  dfResult <- data.frame()
  
  tryCatch({
    #get All Port List
    dfPortList <- func_getPortList()
    
    #get ServerInfoFiles
    dfServerInfoFiles <- func_getServerInfoFileList()
    
    #extract port and shinyapp name from filename
    tempString <- stringr::str_replace(dfServerInfoFiles$fileName, ".csv$", "")
    if(length(tempString)>0){
      dfServerInfoFiles$portNumber <- as.numeric(stringr::str_split(tempString, "_", simplify=TRUE)[,1])
      dfServerInfoFiles$shinyApp <- stringr::str_split(tempString, "_", simplify=TRUE)[,2]
    }
    
    #get active users for each port
    dfUserList <- data.frame()
    if (nrow(dfServerInfoFiles)>0){
      for(i in 1:nrow(dfServerInfoFiles)){
        serverInfoFile <- dfServerInfoFiles$fileFullPath[i]
        portNumber <- dfServerInfoFiles$portNumber[i]
        shinyApp <- dfServerInfoFiles$shinyApp[i]
        if (file.exists(serverInfoFile) && (file.info(serverInfoFile)$size > 0)){
          dfTempUserList <- fread(serverInfoFile, data.table=FALSE, sep=",")
          if(nrow(dfTempUserList)>0){
            dfTempUserList$portNumber <- portNumber
            dfTempUserList$shinyApp <- shinyApp
            if(nrow(dfUserList)>0){
              dfUserList <- rbind(dfUserList, dfTempUserList)
            } else {
              dfUserList <- dfTempUserList
            }
          }
        }
      }
    }
    
    #remove admin user
    if (nrow(dfUserList)>0){
      dfUserList <- dplyr::filter(dfUserList, userID!=AdminUserID)
    }
    
    #get ProcessInfo with listening target ports actually
    dfProcessInfo <- func_getProcessInfo()
    
    #merge all data
    dfResult <- dfPortList
    if (nrow(dfUserList)>0){
      dfResult <- dplyr::left_join(dfResult, dfUserList, by="portNumber")
    } else {
      dfResult$userID <- NA
      dfResult$shinyApp <- NA
    }
    if (nrow(dfProcessInfo)>0){
      dfResult <- dplyr::left_join(dfResult, dfProcessInfo, by="portNumber")
    } else {
      dfResult$PID <- NA
    }
    
    #get URL
    dfResult$URL <- paste0("http://", serverAddress, ":", dfResult$portNumber)
    
    #set status
    dfResult$status <- ifelse(is.na(dfResult$userID),
                              ifelse(is.na(dfResult$PID), "down", "zombie"),
                              ifelse(is.na(dfResult$PID), "starting", "up")
    )
    
  }, error = function(e) {
    print(paste0("error / ", e))
    
  }, warning = function(e) {
    print(paste0("warning / ", e))
    
  })
  
  return(dfResult)
}


func_adminAuthenticate <- function(userID, password){
  if ((userID == AdminUserID) && (password == AdminPassword)) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}

func_addLinkToURL <- function(strURL){
  strTaggedString <- paste0('<a href="', strURL, '" target="_blank">', strURL, '</a>')
  return(strTaggedString)
}


### shinyServer ###################################################################
shinyServer(function(input, output, session){
  source("server_Manager.R", local=TRUE)
  
})