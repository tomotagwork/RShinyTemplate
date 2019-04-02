# server.R

source("server_env.R", local=TRUE)

### shinyServer ###################################################################
shinyServer(function(input, output, session){
  userID_server <- ""
  password_server <- ""
  isAuthenticated_server <- FALSE
  makeReactiveBinding("isAuthenticated_server")
  
  
  source("server_Login.R", local=TRUE)
  source("server_Menu01.R", local=TRUE)
  source("server_ReportDownload.R", local=TRUE)
  
})