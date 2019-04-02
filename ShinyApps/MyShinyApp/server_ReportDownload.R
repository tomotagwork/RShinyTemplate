############################################################################################
# UI
############################################################################################
output$uiOut_Main_ReportDownload <- renderUI({
  listUI <- list()
  
  if(!isAuthenticated_server) {
    ####################### Create UI without Login
    listUI <- func_createWithoutLoginUI()
    
  } else {
    ####################### Create Main UI after Login
    listUI <- list(
      actionButton("button_Refresh_ReportDownload", label="Refresh"),
      textOutput("textOut_messageRefresh_ReportDownload"),
      uiOutput("uiOut_ListFiles_ReportDownload"),
      br(),
      textOutput("textOut_targetFile_ReportDownload"),
      
      br(),
      fluidRow(
        column(6,
               downloadButton("downloadButton_ReportDownload", label="Download")
        ),
        column(6,
               actionButton("button_DeleteFile_ReportDownload", label="Delete"),
               textOutput("textOut_messageDeleteFile_ReportDownload"),
               bsModal("modal_DeleteFile_ReportDownload", "delete file", "button_DeleteFile_ReportDownload",
                       size="small", 
                       wellPanel(p("ˆÈ‰º‚Ìƒtƒ@ƒCƒ‹‚ðíœ‚µ‚Ä‚æ‚ë‚µ‚¢‚Å‚·‚©?"),
                                 textOutput("textOut_DeleteFileDialogue_ReportDownload"),
                                 br(),
                                 actionButton("button_DeleteFile_OK_ReportDownload", label="OK"),
                                 actionButton("button_DeleteFile_CANCEL_ReportDownload", label="Cancel")
                       )
               )
               
        )
      ),
      br(),
      textOutput("textOut_message_ReportDownload")
    )
  }
  
  return(listUI)
  
})


############################################################################################
# Parameters
############################################################################################
listHtmlFiles_ReportDownload <- func_getHtmlFileList(htmlFileDir)
makeReactiveBinding("listHtmlFiles_ReportDownload")

messageRefresh_ReportDownload <- ""
makeReactiveBinding("messageRefresh_ReportDownload")

messageDeleteFile_ReportDownload <- ""
makeReactiveBinding("messageDeleteFile_ReportDownload")

messageSubmit_ReportDownload <- ""
makeReactiveBinding("messageSubmit_ReportDownload")

dfRawData_ReportDownload <- data.frame()
makeReactiveBinding("dfRawData_ReportDownload")

exportFileName_ReportDownload <- ""
makeReactiveBinding("exportFileName_ReportDownload")

#strCreateReportCommand_ReportDownload <- "./Batch/createReport_ReportDownload.bat"


############################################################################################
# Refresh (List Created File)
############################################################################################
observeEvent(input$button_Refresh_ReportDownload,{
  listHtmlFiles_ReportDownload <<- func_getHtmlFileList(htmlFileDir)
  messageRefresh_ReportDownload <<- paste0(format(Sys.time(), "%Y/%m/%d %H:%M:%S"), " : ", "Refreshed")
  messageDeleteFile_ReportDownload <<- ""
})

output$textOut_messageRefresh_ReportDownload <- renderText({
  paste0(messageRefresh_ReportDownload)
})


output$uiOut_ListFiles_ReportDownload <- renderUI({
  if (length(listHtmlFiles_ReportDownload)>0) {
    radioButtons("radioButtons_HtmlFiles_ReportDownload", "Createed Files",
                 choices=listHtmlFiles_ReportDownload, width="100%"
    )
  } else {
    p("no files")
  }
})




############################################################################################
# Download File
############################################################################################
output$textOut_targetFile_ReportDownload <- renderText({
  fileName <- stringr::str_replace_all(input$radioButtons_HtmlFiles_ReportDownload, ".*/", "")
  paste0("target file : ", fileName)
})

output$downloadButton_ReportDownload <- downloadHandler(
  filename <- function(){
    stringr::str_replace_all(input$radioButtons_HtmlFiles_ReportDownload, ".*/", "")
  },
  content <- function(file){
    file.copy(input$radioButtons_HtmlFiles_ReportDownload, file)
  }
)

############################################################################################
# Delete File
############################################################################################
output$textOut_DeleteFileDialogue_ReportDownload <- renderText({
  fileName <- stringr::str_replace_all(input$radioButtons_HtmlFiles_ReportDownload, ".*/", "")
})

observeEvent(input$button_DeleteFile_OK_ReportDownload,{
  messageDeleteFile_ReportDownload <<- "..."
  
  fileFullPath <- input$radioButtons_HtmlFiles_ReportDownload
  file.remove(fileFullPath)
  
  ### refresh file list
  listHtmlFiles_ReportDownload <<- func_getHtmlFileList(htmlFileDir)
  messageRefresh_ReportDownload <<- paste0(format(Sys.time(), "%Y/%m/%d %H:%M:%S"), " : ", "Refreshed")
  
  fileName <- stringr::str_replace_all(input$radioButtons_HtmlFiles_ReportDownload, ".*/", "")
  messageDeleteFile_ReportDownload <<- paste0(format(Sys.time(), "%Y/%m/%d %H:%M:%S"), " : ", fileName, " deleted!")
  
  toggleModal(session, "modal_DeleteFile_ReportDownload", toggle="close")
  
})


observeEvent(input$button_DeleteFile_CANCEL_ReportDownload,{
  messageDeleteFile_ReportDownload <<- paste0(format(Sys.time(), "%Y/%m/%d %H:%M:%S"), " : ",  "Canceled!")
  toggleModal(session, "modal_DeleteFile_ReportDownload", toggle="close")
})

output$textOut_messageDeleteFile_ReportDownload <- renderText({
  paste0(messageDeleteFile_ReportDownload)
})
