@echo off
@setlocal EnableDelayedExpansion
cd %~dp0

call env.bat

for /f "tokens=1-5* usebackq" %%a in (`netstat -ano ^| findstr "LISTENING" ^| findstr "0.0.0.0:%serverPortNumber%"`) do (
	rem echo a=%%a / b=%%b / c=%%c / d=%%d / e=%%e
	taskkill /PID %%e /F
)

