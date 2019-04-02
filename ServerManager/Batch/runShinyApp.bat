@echo off
setlocal enabledelayedexpansion
cd %~dp0

call ..\..\env.bat 

set shinyApp=%1
set portNumber=%2
set logFile=%~n0_%shinyApp%.log

Rscript.exe runShinyApp.R %shinyApp% %portNumber% > %logFile% 2>&1
