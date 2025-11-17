@echo off
setlocal ENABLEDELAYEDEXPANSION

set PROJECT_ROOT=%~dp0..\
set LOG_DIR=%PROJECT_ROOT%outputs\logs
set RUN_NAME=%1

if "%RUN_NAME%"=="" (
    echo Usage: %~nx0 RUN_NAME ^(e.g. LOCK_MAIN^)
    exit /b 1
)

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

set SAS_EXE="C:\Program Files\SASHome\SASFoundation\9.4\sas.exe"

%SAS_EXE% -sysin "%PROJECT_ROOT%etl\run_all.sas" ^
          -set ROOT "%PROJECT_ROOT:~0,-1%" ^
          -set RUN "%RUN_NAME%" ^
          -log "%LOG_DIR%\%RUN_NAME%_master.log" ^
          -print "%LOG_DIR%\%RUN_NAME%_master.lst" ^
          -nosplash -noterminal

endlocal
