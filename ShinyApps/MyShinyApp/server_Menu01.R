############################################################################################
# UI
############################################################################################

output$uiOut_Main_Menu01 <- renderUI({
  listUI <- list()
  
  if(!isAuthenticated_server) {
    ####################### Create UI without Login
    listUI <- func_createWithoutLoginUI()
    
  } else {
    ####################### Create Main UI after Login
    listUI <- list(
      h3("ファイルアップロード"),
      fileInput("fileInput_Upload_Menu01", "Upload csv File",
                multiple = FALSE,
                accept = c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv")),
      hr(),
      h3("データ加工"),
      actionButton("button_Refresh_Menu01", label="Refresh"),
      textOutput("textOut_messageRefresh_Menu01"),
      br(),
      uiOutput("uiOut_ListFiles_Menu01"),
      hr(),
      textOutput("textOut_targetFile_Menu01"),
      br(),
      fluidRow(
        column(6,
               actionButton("button_Submit_Menu01", label="Submit"),
               textOutput("textOut_messageSubmit_Menu01"),
               bsModal("modal_Submit_Menu01", "read file", "button_Submit_Menu01",
                       size="small", 
                       wellPanel(p("データ取得中..."),
                                 p("しばらくお待ち下さい。"))
               )
        ),
        column(6,
               actionButton("button_DeleteFile_Menu01", label="Delete"),
               textOutput("textOut_messageDeleteFile_Menu01"),
               bsModal("modal_DeleteFile_Menu01", "delete file", "button_DeleteFile_Menu01",
                       size="small", 
                       wellPanel(p("以下のファイルを削除してよろしいですか?"),
                                 textOutput("textOut_DeleteFileDialogue_Menu01"),
                                 br(),
                                 actionButton("button_DeleteFile_OK_Menu01", label="OK"),
                                 actionButton("button_DeleteFile_CANCEL_Menu01", label="Cancel")
                       )
               )
               
        )
      ),
      br(),
      tabBox(
        title=NULL, width=NULL,
        id="tabBox_Menu01",
        tabPanel("DataTable", "",
                 uiOutput("uiOut_DTDownload_Menu01"),
                 br(),
                 tags$head(tags$style(type='text/css', '#dataTable_rawData_Menu01{ overflow-x: scroll; }')),
                 dataTableOutput("dataTable_rawData_Menu01")
        ),
        tabPanel("PivotTable", "",
                 tags$head(tags$style(type='text/css', '#pivot_rawData_Menu01{ overflow-x: scroll; }')),
                 rpivotTableOutput("pivot_rawData_Menu01")
        )
      ),
      
      hr(),
      
      h3("レポート生成"),
      fluidRow(
        column(4,
               textInput("textIn_ExportFileKeyword_Menu01", label="Keyword")
        ),
        column(2,
              br(),
              actionButton("buttonExport_Menu01", label="Export"),
              bsModal("modalExport_Menu01", "Create Report", "buttonExport_Menu01",
                      size="small", 
                      wellPanel(
                        p("バックグラウンドで静的HTMLファイルを生成中です。"),
                        p("しばらく待ってからダウンロードページを確認して下さい。")
                      )
              )
        )
      ),
      textOutput("textOut_ExportFileName_Menu01"),
      p("(同一名のファイルがある場合は上書きされます)")
    )
  }
  
  return(listUI)
  
})


############################################################################################
# Parameters
############################################################################################
listUploadFiles_Menu01 <- func_getCsvFileList(uploadFileDir)
makeReactiveBinding("listUploadFiles_Menu01")

messageRefresh_Menu01 <- ""
makeReactiveBinding("messageRefresh_Menu01")

messageDeleteFile_Menu01 <- ""
makeReactiveBinding("messageDeleteFile_Menu01")

messageSubmit_menu01 <- ""
makeReactiveBinding("messageSubmit_menu01")

dfRawData_Menu01 <- data.frame()
makeReactiveBinding("dfRawData_Menu01")

exportFileName_Menu01 <- ""
makeReactiveBinding("exportFileName_Menu01")

strCreateReportCommand_Menu01 <- "./Batch/createReport_Menu01.bat"

############################################################################################
# Upload File
############################################################################################
observeEvent(input$fileInput_Upload_Menu01, {
  inputFile <- input$fileInput_Upload_Menu01$datapath
  targetFile <- paste0(uploadFileDir, input$fileInput_Upload_Menu01$name)
  file.rename(inputFile, targetFile)
  
  ### refresh file list
  listUploadFiles_Menu01 <<- func_getCsvFileList(uploadFileDir)
  messageRefresh_Menu01 <<- paste0(format(Sys.time(), "%Y/%m/%d %H:%M:%S"), " : ", "Refreshed")
  messageDeleteFile_Menu01 <<- ""
})


############################################################################################
# Refresh (List Uploaded File)
############################################################################################
observeEvent(input$button_Refresh_Menu01,{
  listUploadFiles_Menu01 <<- func_getCsvFileList(uploadFileDir)
  messageRefresh_Menu01 <<- paste0(format(Sys.time(), "%Y/%m/%d %H:%M:%S"), " : ", "Refreshed")
  messageDeleteFile_Menu01 <<- ""
})

output$textOut_messageRefresh_Menu01 <- renderText({
  paste0(messageRefresh_Menu01)
})


output$uiOut_ListFiles_Menu01 <- renderUI({
  if (length(listUploadFiles_Menu01)>0) {
    radioButtons("radioButtons_UploadFiles_Menu01", "Uploaded Files",
                 choices=listUploadFiles_Menu01, width="100%"
    )
  }
})

output$textOut_targetFile_Menu01 <- renderText({
  fileName <- stringr::str_replace_all(input$radioButtons_UploadFiles_Menu01, ".*/", "")
  paste0("target file : ", fileName)
})


############################################################################################
# Delete File
############################################################################################
output$textOut_DeleteFileDialogue_Menu01 <- renderText({
  fileName <- stringr::str_replace_all(input$radioButtons_UploadFiles_Menu01, ".*/", "")
})

observeEvent(input$button_DeleteFile_OK_Menu01,{
  messageDeleteFile_Menu01 <<- "..."
  
  fileFullPath <- input$radioButtons_UploadFiles_Menu01
  file.remove(fileFullPath)
  
  ### refresh file list
  listUploadFiles_Menu01 <<- func_getCsvFileList(uploadFileDir)
  messageRefresh_Menu01 <<- paste0(format(Sys.time(), "%Y/%m/%d %H:%M:%S"), " : ", "Refreshed")
  
  fileName <- stringr::str_replace_all(input$radioButtons_UploadFiles_Menu01, ".*/", "")
  messageDeleteFile_Menu01 <<- paste0(format(Sys.time(), "%Y/%m/%d %H:%M:%S"), " : ", fileName, " deleted!")
  
  toggleModal(session, "modal_DeleteFile_Menu01", toggle="close")
  
})


observeEvent(input$button_DeleteFile_CANCEL_Menu01,{
  messageDeleteFile_Menu01 <<- paste0(format(Sys.time(), "%Y/%m/%d %H:%M:%S"), " : ",  "Canceled!")
  toggleModal(session, "modal_DeleteFile_Menu01", toggle="close")
})

output$textOut_messageDeleteFile_Menu01 <- renderText({
  paste0(messageDeleteFile_Menu01)
})


############################################################################################
# Submit (data processing)
############################################################################################
observeEvent(input$button_Submit_Menu01, {
  messageSubmit_menu01 <<- "..."
  dfData <- data.frame()
  
  tryCatch({
    fileFullPath <- input$radioButtons_UploadFiles_Menu01
    dfData <- fread(fileFullPath, data.table=FALSE, sep=",", fill=TRUE)
    
    ### no processing in this example ###
    
    messageSubmit_Menu01 <<- paste0(format(Sys.time(), "%Y/%m/%d %H:%M:%S"), " : ",  "Completed!")
    
  }, error = function(e){
    
    dfData <- data.frame()
    messageSubmit_Menu01 <<- paste0(format(Sys.time(), "%Y/%m/%d %H:%M:%S"), " : ",  e)
    
  })
  
  dfRawData_Menu01 <<- dfData
  toggleModal(session, "modal_Submit_Menu01", toggle="close")
  
})

output$textOut_messageSubmit_Menu01 <- renderText({
  paste0(messageSubmit_menu01)
})


############################################################################################
# dataTable
############################################################################################
output$uiOut_DTDownload_Menu01 <- renderUI({
  if (nrow(dfRawData_Menu01)>0){
    downloadButton("downloadButton_RawData_Menu01", label="Download")
  } else {
    p("<no data>")
  }
})

output$downloadButton_RawData_Menu01 <- downloadHandler(
  filename = function(){
    fileName <- "rawdata.csv"
  },
  content = function(file){
    write.csv(dfRawData_Menu01, file, row.names = FALSE)
  }
)

output$dataTable_rawData_Menu01 <- renderDataTable({
  if (nrow(dfRawData_Menu01)>0) {
    dfRawData_Menu01
  }
}, server=TRUE,
  rownames=FALSE,
  class='display nowrap',
  escape=FALSE,
  filter="top",
  extensions=c("Buttons","FixedColumns", "FixedHeader"),
  options=list(pageLength = 10,
               colReorder = FALSE,
               dom = "Blfrtip",
               buttons = list(list(extend="colvis", text="column select")),
               #scrollX=TRUE,
               #fixedColumns=list(leftColumns=2),
               fixedHeader=FALSE
  )
)


############################################################################################
# pivotTable
############################################################################################
output$pivot_rawData_Menu01 <- renderRpivotTable({
  if (nrow(dfRawData_Menu01)>0) {
    rpivotTable(dfRawData_Menu01, 
                rows = c(colnames(dfRawData_Menu01)[1]), 
                cols = c(""),
                width = "100%",
                height = "100%",
                rendererName = "Heatmap", 
                aggregatorName = "Count"
    )
  }
})



############################################################################################
# Export
############################################################################################
output$textOut_ExportFileName_Menu01 <- renderText({
  exportFileName_Menu01 <<- paste0("Menu01_", input$textIn_ExportFileKeyword_Menu01, ".html")
  paste0(exportFileName_Menu01, "ファイルとして生成")
})


observeEvent(input$buttonExport_Menu01,{
  inputFileName <- stringr::str_replace_all(input$radioButtons_UploadFiles_Menu01, ".*/", "")
  listData <- list(fileName=inputFileName,
                   data=dfRawData_Menu01)
  dataFileName <- paste0(format(Sys.time(), "%Y%m%d_%H%M%OS"), ".rdata")
  dataFileFullPath <- paste0(tempFileDir, dataFileName)
  save(listData, file=dataFileFullPath)
  
  strCommand <- paste0(strCreateReportCommand_Menu01, " ", dataFileName, " ", exportFileName_Menu01)
  system(strCommand, wait=FALSE)
  
})
