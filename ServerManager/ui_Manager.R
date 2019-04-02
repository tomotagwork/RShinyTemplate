tabItem_Manager <- tabItem("tab_Manager",
                           h3("Shinyサーバー管理"),
                           h4("サーバー作成/破棄"),
                           fluidRow(
                             column(3,
                                    textInput("textIn_UserID_Manager",
                                              label="UserID:",
                                              value="")
                                    ),
                             column(3,
                                    passwordInput("textIn_Password_Manager",
                                                  label="Password:")
                                    )
                           ),
                           fluidRow(
                             column(4,
                                    selectInput("selectIn_ShinyApp_Manager",
                                                label="Choose a Shiny App",
                                                choices=c(""),
                                                selected="")
                             ),
                             column(2,
                                    br(),
                                    actionButton("button_Create_Manager", label="Create"),
                                    shinyBS::bsModal("modal_Create_Manager",
                                                     title="サーバー作成リクエスト",
                                                     trigger="button_Create_Manager",
                                                     size="small",
                                                     wellPanel(
                                                       uiOutput("modal_Create_Body_Manager")
                                                     )
                                    )
                             ),
                             column(2,
                                    br(),
                                    actionButton("button_Delete_Manager", label="Delete"),
                                    shinyBS::bsModal(id="modal_Delete_Manager",
                                                     title="サーバー破棄リクエスト",
                                                     trigger="button_Delete_Manager",
                                                     size="small",
                                                     wellPanel(
                                                       uiOutput("modal_Delete_Body_Manager")
                                                    )
                                    )
                             )
                           ),
                           textOutput("textOut_message_Manager"),
                           br(),

                           actionButton("button_Refresh_Manager", label="Refresh"),
                           textOutput("textOut_messageRefresh_Manager"),
                           br(),

                           uiOutput("uiOut_ServerCount_Manager"),
                           br(),

                           dataTableOutput("tableServerInfo_Manager")
                           #tag$head(tags$style(type='text/css', '#tableServerInfo_Manager{ overflow-x: scroll; }'))
                           
                           )
