@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
  echo Usage: %~nx0 RUN_NAME ^(e.g. SCLC_LOCK_2025Q4^)
  exit /b 1
)

set "PROJECT_ROOT=%~dp0.."
for %%I in ("%PROJECT_ROOT%") do set "PROJECT_ROOT=%%~fI"
set "LOG_DIR=%PROJECT_ROOT%\outputs\logs"
set "RUN_NAME=%~1"

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

if not defined SAS_EXE set "SAS_EXE=sas.exe"

"%SAS_EXE%" -sysin "%PROJECT_ROOT%\etl\run_study.sas" ^
            -set PROJECTROOT "%PROJECT_ROOT%" ^
            -sysparm "%RUN_NAME%" ^
            -log "%LOG_DIR%\%RUN_NAME%_master.log" ^
            -print "%LOG_DIR%\%RUN_NAME%_master.lst" ^
            -nosplash -noterminal
