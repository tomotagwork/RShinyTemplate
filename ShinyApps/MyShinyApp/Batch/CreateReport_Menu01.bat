@echo off
@setlocal EnableDelayedExpansion
cd %~dp0

call ..\..\..\env.bat 

rem #####################################################
rem # Parameters
rem #####################################################
set inputFileName=%1
set outputFileName=%2
set inputDir=.\tempData
set outputDir=.\htmlFile
set RMDFile=Menu01.Rmd
set LOGFILE=%~n0.log


rem #####################################################
rem # execute R script
rem #####################################################

echo. >> %LOGFILE%
echo %date% %time% R script / begin / %inputFilename% %outputFileName%>> %LOGFILE%

Rscript.exe Rmd_exec.R %RMDFile% %inputDir%\%inputFileName% %outputDir%\%outputFileName% >> %LOGFILE% 2>>&1

echo %date% %time% R script / end / %inputFilename% %outputFileName% >> %LOGFILE% 
echo. >> %LOGFILE%

del %inputDir%\%inputFileName%

exit 0