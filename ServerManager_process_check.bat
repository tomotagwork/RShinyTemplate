@echo off
setlocal enabledelayedexpansion
cd %~dp0

call env.bat
set logFile=%~n0.log

netstat -ano | find "LISTENING" | find "0.0.0.0:%serverPortNumber%" > NUL
if not ERRORLEVEL 1 (
	goto RUNNING
) else (
	goto NOT_RUNNING
)

:RUNNING
	echo status: running
	goto END

:NOT_RUNNING
	echo status: stopped
	echo %date% %time% start server manager >> %logFile%

	runBatch.vbs runShinyApp.bat %serverManagerApp% %serverPortNumber%
	
	goto END

:END
	echo process_check end