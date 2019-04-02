@echo off
setlocal enabledelayedexpansion
cd %~dp0

call env.bat

for /f "tokens=1-5*" %%a in ('netstat -ano ^| find "LISTENING" ^| find "0.0.0.0:%serverPortNumber%" ') do (
	rem echo a=%%a / b=%%b / c=%%c / d=%%d / e=%%e
	taskkill /PID %%e /F
)

