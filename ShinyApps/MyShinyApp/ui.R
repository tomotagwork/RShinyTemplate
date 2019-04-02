source("ui_env.R", local=TRUE)

source("ui_info.R", local=TRUE)
source("ui_Login.R", local=TRUE)
source("ui_Menu01.R", local=TRUE)
#source("ui_Menu02.R", local=TRUE)
#source("ui_Menu03.R", local=TRUE)
source("ui_ReportDownload.R", local=TRUE)


dashboardPage(
  dashboardHeader(title = "My ShinyApp"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Information", icon=icon("info"), tabName="tab_info"
      ),
      menuItem(menuStrLogin, icon=icon("user"), tabName="tab_Login"
      ),
      menuItem(menuStrCategory01, icon=icon("line-chart"), 
               menuSubItem(menuStrMenu01, tabName="tab_Menu01"),
               menuSubItem(menuStrMenu02, tabName="tab_Menu02")
      ),
      menuItem(menuStrCategory02, icon=icon("line-chart"), 
               menuSubItem(menuStrMenu01, tabName="tab_Menu03")
      ),
      menuItem(menuStrReportDownload, icon=icon("download"), tabName="tab_ReportDownload"
      )
      
    )
  ),
  dashboardBody(
    #tag$script(HTML(strJavaScript01)),
    
    tabItems(
      tabItem_info,
      tabItem_Login,
      
      tabItem_Menu01,
      #tabItem_Menu02,
      #tabItem_Menu03,
      
      tabItem_ReportDownload
      
    )
  ),
  skin="blue"
)