@echo off
@setlocal EnableDelayedExpansion
cd %~dp0

set LOGFILE=%~n0.log
set ProcessName=Rscript.exe

rem Header
echo ProcessName,PID,ListenAddressPort

for /f "skip=1 tokens=1,2,3,4,5* usebackq" %%a in (`netstat -abno`) do (
	rem echo -----
	rem echo f1: %%a, / f2: %%b / f3: %%c / f4: %%d / f5: %%e

	if "%%a" == "TCP" (
		if "%%d" == "LISTENING" (
			set tempPort=%%b
			set tempPID=%%e
		) else (
			set tempPort=""
			set tempPID=""
		)
	) else if "%%a" == "[!ProcessName!]" (
		if NOT !tempPID! == "" (
			echo !ProcessName!,!tempPID!,!tempPort!
		)
		set tempPort=""
		set tempPID=""
	)
)


exit 0