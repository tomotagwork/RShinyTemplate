@echo off
@setlocal EnableDelayedExpansion
cd %~dp0

call ..\..\env.bat

set LOGFILE=%~n0.log

set shinyApp=%1
set portNumber=%2

echo %time% : Create Server %shinyApp% / port:%portNumber% >> %LOGFILE%
runBatch.vbs runShinyApp.bat %shinyApp% %portNumber%
