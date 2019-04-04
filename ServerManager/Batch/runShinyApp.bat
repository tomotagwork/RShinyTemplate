@echo off
setlocal enabledelayedexpansion
cd %~dp0

call ..\..\env.bat 

set shinyApp=%1
set portNumber=%2
set logFile=%~n0_%shinyApp%_%portNumber%.log

Rscript.exe runShinyApp.R ..\..\ShinyApps\%shinyApp% %portNumber% > %logFile% 2>&1
