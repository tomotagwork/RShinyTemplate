#source('ui_info.R', local=TRUE)
source('ui_Manager.R', local=TRUE)

dashboardPage(
  dashboardHeader(title = "Server Manager"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Manager", icon=icon("gear"), tabName="tab_Manager"
      )
    )
  ),
  dashboardBody(
    tabItems(
      tabItem_Manager
      #tabItem("tab_Manager",
      #        h3("Shiny Server Management"))
    )
  ),
  skin="blue"
)