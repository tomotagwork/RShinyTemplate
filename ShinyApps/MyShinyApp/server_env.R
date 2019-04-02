# server_env.R


### Functions ###################################################################
func_authenticate <- function(sessionObj, input_userID, input_password){
  portNumber <- sessionObj$clientData$url_port
  shinyAppName <- stringr::str_replace(getwd(), pattern="^.*/", replacement="")
  
  userFileName <- paste0(portNumber, "_", shinyAppName, ".csv")
  userFileFullPath <- paste0(serverInfoDir, userFileName)
  
  if (file.exists(userFileFullPath) && (file.info(userFileFullPath)$size > 0)){
    dfAuthorizedUser <- fread(userFileFullPath, data.table=FALSE, sep=",")
    isAuthenticated <- FALSE
    if (input_userID %in% dfAuthorizedUser$userID){
      if(dfAuthorizedUser[dfAuthorizedUser$userID==input_userID,]$password[1] == input_password){
        message <- paste0(input_userID, " : Login Successfully!")
        isAuthenticated <- TRUE
        
      } else {
        message <- paste0("Invalid password for user ", input_userID)
        isAuthenticated <- FALSE
        
      }
      
    } else {
      message <- paste0("User ", input_userID, " is not authorized for port ", portNumber)
      isAuthenticated <- FALSE
    }
  } else {
    message <- paste0("No authorized user for port ", portNumber)
    isAuthenticated <- FALSE
    
  }
  
  listResult <- list(message=message, isAuthenticated=isAuthenticated)
  return(listResult)
  
}

func_createWithoutLoginUI <- function(){
  listResult <- list(
    span(p("ログイン処理が必要です。"), style="color:red"),
    span(p("[ログイン]メニューからログイン処理を行ってください。"), style = "color:red")
  )
}

func_getCsvFileList <- function(directory) {
  listResult <- c()
  
  all_files <- list.files(directory)
  target_files <- all_files[grep("\\.csv$|\\.CSV$|\\.txt$|\\.TXT$", all_files)]
  
  if (length(all_files)>0) {
    dfTargetFilesInfo <- file.info(paste0(directory, target_files))
    dfTargetFilesInfo$fileFullPath <- rownames(dfTargetFilesInfo)
    dfTargetFilesInfo$fileName <- stringr::str_replace_all(dfTargetFilesInfo$fileFullPath, ".*/", "")
    
    if (nrow(dfTargetFilesInfo)>0){
      #order by modified time(descending order)
      dfTargetFilesInfo <- dplyr::arrange(dfTargetFilesInfo, desc(mtime))
      
      #add column for display text
      dfTargetFilesInfo$dispText <- paste0(dfTargetFilesInfo$fileName, " (", dfTargetFilesInfo$mtime, " / ",
                                           as.integer(dfTargetFilesInfo$size/1024),"KB)")
      
      listResult <- dfTargetFilesInfo$fileFullPath
      names(listResult) <- dfTargetFilesInfo$dispText
    }
  }
  
  return(listResult)

}

func_getHtmlFileList <- function(directory) {
  listResult <- c()
  
  all_files <- list.files(directory)
  target_files <- all_files[grep("\\.html$|\\.HTML$", all_files)]
  if (length(all_files)>0) {
    dfTargetFilesInfo <- file.info(paste0(directory, target_files))
    dfTargetFilesInfo$fileFullPath <- rownames(dfTargetFilesInfo)
    dfTargetFilesInfo$fileName <- stringr::str_replace_all(dfTargetFilesInfo$fileFullPath, ".*/", "")
    
    if (nrow(dfTargetFilesInfo)>0){
      #order by modified time(descending order)
      dfTargetFilesInfo <- dplyr::arrange(dfTargetFilesInfo, desc(mtime))
      
      #add column for display text
      dfTargetFilesInfo$dispText <- paste0(dfTargetFilesInfo$fileName, " (", dfTargetFilesInfo$mtime, " / ",
                                           as.integer(dfTargetFilesInfo$size/1024),"KB)")
      
      listResult <- dfTargetFilesInfo$fileFullPath
      names(listResult) <- dfTargetFilesInfo$dispText
    }
  }
  
  return(listResult)
  
}
