message_Login <- ""
makeReactiveBinding("message_Login")

time_Login <- Sys.time()
makeReactiveBinding("time_Login")

observeEvent(input$buttonLogin_Login, {
  tryCatch({
    message_Login <<- "..."
    
    input_userID <- input$textIn_UserID_Login
    input_password <- input$textIn_Password_Login
    
    listResult <- func_authenticate(session, input_userID, input_password)
    message_Login <<- listResult$message
    if (listResult$isAuthenticated) {
      userID_server <<- input_userID
      password_server <<- input_password
      isAuthenticated_server <<- TRUE
    } else {
      isAuthenticated_server <<- FALSE
      
    }
    
  }, error = function(e){
    message_Login <<- paste0("read file Error / ", e)
    
  }, finally = {
    time_Login <<- Sys.time()
  })

})

output$textOut_message_Login <- renderText({
  paste0(format(time_Login, "%Y/%m/%d %H:%M:%S"), ": " , message_Login)
})
  
  