#################################################################
# Initialize
#################################################################
time_Manager <- Sys.time()

message_Manager <- ""
makeReactiveBinding("message_Manager")

dfServerInfo_Manager <- func_getServerInfo()
makeReactiveBinding("dfServerInfo_Manager")

isAdmin_Manager <- FALSE

listShinyAppList_Manager <- func_getShinyAppList()

updateSelectInput(session,
                  "selectIn_ShinyApp_Manager",
                  choices = listShinyAppList_Manager,
                  seleted = listShinyAppList_Manager[1])

#################################################################
# Create 
#################################################################
output$modal_Create_Body_Manager <- renderUI({
  dfAvailablePort <- dplyr::filter(dfServerInfo_Manager, status=="down")
  dfMyServer <- dplyr::filter(dfServerInfo_Manager, userID=input$textIn_UserID_Manager)
  listMyApp <- c()
  if(nrow(dfMyServer)>0){
    listMyApp <- dfMyServer$shinyApp
  }
  
  #Check
  if (nrow(dfAvailablePort)<=0){
    modalMessage <- paste0("Error: サーバー数上限に達しているため作成できません")
    listResult <- list(
      p(modalMessage)
    )
    
  } else if (input$textIn_UserID_Manager == "" || input$textIn_Password_Manager == "") {
    modalMessage <- paste0("Error: ユーザーID、パスワードを指定して下さい")
    listResult <- list(
      p(modalMessage)
    )
    
  } else if (input$selectIn_ShinyApp_Manager %in% listMyApp) {
    modalMessage <- paste0("Error: ユーザー[", input$textIn_UserID_Manager,"]用のサーバー[",input$selectIn_ShinyApp_Manager,"]は既に作成済みです")
    listResult <- list(
      p(modalMessage)
    )
    
  } else {
    listResult <- list (
      p("サーバーを作成/起動してよろしいですか？"),
      br(),
      actionButton("modal_Create_OK_Manager", label="OK"),
      actionButton("modal_Create_CANCEL_Manager", label="Cancel")
    )
  }
  
  listResult
  
})

observeEvent(input$modal_Create_OK_Manager, {
  message_Manager <<- "..."
  selectedShinyApp <- input$selectIn_ShinyApp_Manager
  
  #Refresh
  isAdmin_Manager <<- func_adminAuthenticate(input$textIn_UserID_Manager, input$textIn_Password_Manager)
  dfServerInfo_Manager <<- data.frame()
  dfServerInfo_Manager <<- func_getServerInfo()
  
  dfAvailablePort <- dplyr::filter(dfServerInfo_Manager, status=="down")
  
  tryCatch({
    #Assign Port
    assignedPort <- dfAvailablePort$portNumber[1]
    
    #Write ServerInfo file
    serverInfoFileName <- paste0(serverInfoPath, assignedPort, "_", selectedShinyApp, ".csv")
    dfServerInfoData <- data.frame(userID=c(input$textIn_UserID_Manager), password=c(input$textIn_Password_Manager))
    write.table(dfServerInfoData, file=serverInfoFileName, sep=",", col.names = TRUE, row.names = FALSE)
    
    #Execute batch for create server
    system2(strCreateServerCommand, args=c(selectedShinyApp, assignedPort), wait=FALSE)
    
    message_Manager <<- pate0("リクエストを受け付けました")
    
    #Refresh
    dfServerInfo_Manager <<- data.frame()
    dfServerInfo_Manager <<- func_getServerInfo()
    
  }, error = function(e){
    message_Manager <<- paste0("system command Error / ",e)
    
  }, warinig = function(e){
    message_Manager <<- paste0("system command Warning / ",e)
    
  })
  
  toggleModal(session, "modal_Create_Manager", toggle="close")
  
})

observeEvent(input$modal_Create_CANCEL_Manager, {
  time_Manager <<- Sys.time()
  message_Manager <<- paste0("Canceled!")
  
  toggleModal(session, "modal_Create_Manager", toggle="close")
  
})

#################################################################
# Delete
#################################################################

output$modal_Delete_Body_Manager <- renderUI({
  dfMyServer <- dplyr::filter(dfServerInfo_Manager, userID=input$textIn_UserID_Manager & shinyApp==input$selectIn_ShinyApp_Manager)
  
  #Check
  if (input$textIn_UserID_Manager == "" || input$textIn_Password_Manager == "") {
    modalMessage <- paste0("Error: ユーザーID、パスワードを指定して下さい")
    listResult <- list(
      p(modalMessage)
    )
    
  } else if (nrow(dfMyServer)<=0) {
    modalMessage <- paste0("Error: ユーザー[", input$textIn_UserID_Manager,"]管理のサーバー[",input$selectIn_ShinyApp_Manager,"]はありません")
    listResult <- list(
      p(modalMessage)
    )
    
  } else if (!(input$textIn_Password_Manager %in% dfMyServer$password)) {
    modalMessage <- paste0("Error: パスワードの指定がサーバーを作成した時のパスワードと違います")
    listResult <- list(
      p(modalMessage)
    )
    
  } else {
    listResult <- list (
      p("サーバーを破棄してよろしいですか？"),
      br(),
      actionButton("modal_Delete_OK_Manager", label="OK"),
      actionButton("modal_Delete_CANCEL_Manager", label="Cancel")
    )
  }
  
})

observeEvent(input$modal_Delete_OK_Manager, {
  message_Manager <<- "..."
  selectedShinyApp <- input$selectIn_ShinyApp_Manager
  
  #Refresh
  isAdmin_Manager <<- func_adminAuthenticate(input$textIn_UserID_Manager, input$textIn_Password_Manager)
  dfServerInfo_Manager <<- data.frame()
  dfServerInfo_Manager <<- func_getServerInfo()
  
  dfMyServer <- dplyr::filter(dfServerInfo_Manager, userID=input$textIn_UserID_Manager & shinyApp==input$selectIn_ShinyApp_Manager)

  tryCatch({
    #Target Port
    targetPort <- dfMyServer$portNumber[1]
    
    #Execute batch for delete server
    system2(strDeleteServerCommand, args=c(targetPort), wait=TRUE)
    
    #Delete ServerInfo file
    serverInfoFileName <- paste0(serverInfoPath, targetPort, "_", selectedShinyApp, ".csv")
    if (file.exists(serverInfoFileName)) {
      file.remove(serverInfoFileName)
    }
    
    message_Manager <<- pate0("リクエストを受け付けました")
    
    #Refresh
    dfServerInfo_Manager <<- data.frame()
    dfServerInfo_Manager <<- func_getServerInfo()
    
  }, error = function(e){
    message_Manager <<- paste0("system command Error / ",e)
    
  }, warinig = function(e){
    message_Manager <<- paste0("system command Warning / ",e)
    
  })
  
  toggleModal(session, "modal_Delete_Manager", toggle="close")
  
})

observeEvent(input$modal_Delete_CANCEL_Manager, {
  time_Manager <<- Sys.time()
  message_Manager <<- paste0("Canceled!")
  
  toggleModal(session, "modal_Delete_Manager", toggle="close")
  
})

output$textOut_message_Manager <- renderText({
  pate0(format(time_Manager, "%Y/%m/%d %H:%M:%S"), " : ", message_Manager)
})

#################################################################
# Refresh
#################################################################
observeEvent(input$button_Refresh_Manager,{
  isAdmin_Manager <<- func_adminAuthenticate(input$textIn_UserID_Manager, input$textIn_Password_Manager)
  dfServerInfo_Manager <<- data.frame()
  dfServerInfo_Manager <<- func_getServerInfo()
})

output$uiOut_ServerCount_Manager <- renderUI({
  totalServerCount <- length(unique(dfServerInfo_Manager$portNumber))
  downSwerverRecord <- dplyr::filter(dfServerInfo_Manager, status=="down")
  activeServerCount <- totalServerCount - nrow(downSwerverRecord)
  
  h4(strong(paste0("# of Active Servers: ", activeServerCount, " / ", totalServerCount)))
})

#################################################################
# DataTable
#################################################################
output$tableServerInfo_Manager <- renderDataTable({
  dfServerInfo_Manager_filter <- data.frame(c("nodata"))
  if(nrow(dfServerInfo_Manager)>0){
    dfServerInfo_Manager_filter <- dfServerInfo_Manager
    dfServerInfo_Manager_filter$URL <- func_addLinkToURL(dfServerInfo_Manager_filter$URL)
    if (!(isAdmin_Manager)) {
      dfServerInfo_Manager_filter <- dplyr::select(dfServerInfo_Manager_filter, userID, shinyApp, PID, status, URL)
      dfServerInfo_Manager_filter <- dplyr::filter(dfServerInfo_Manager_filter, status != "down")
    }
  }
  dfServerInfo_Manager_filter
  
}, server=TRUE,
   rownames=FALSE,
   class="display nowrap",
   escape=FALSE,
   filter="top",
   extensions=c("Buttons", "FixedColumns","FixedHeader"),
   options=list(pageLength=10,
                colRecorder=FALSE,
                dom="lfrtip")
)


