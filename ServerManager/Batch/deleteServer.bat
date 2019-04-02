@echo off
@setlocal EnableDelayedExpansion
cd %~dp0

set LOGFILE=%~n0.log

set portNumber=%1

for /f "tokens=1-5*" %%a in ('netstat -ano ^| findstr "LISTENING" ^| findstr ":%portNumber%"') do (
	rem 	echo a=%%a / b=%%b / c=%%c / d=%%d / e=%%e >> %LOGFILE%
	taskkill /PID %%e /F
)

exit 0

