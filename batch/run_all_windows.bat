@echo off
setlocal ENABLEDELAYEDEXPANSION

set PROJECT_ROOT=%~dp0..\
set CONFIG_DIR=%PROJECT_ROOT%config
set LOG_DIR=%PROJECT_ROOT%outputs\logs
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

set RUN_ENV=%1
if "%RUN_ENV%"=="" set RUN_ENV=env_lock_2025Q1.yaml

python "%CONFIG_DIR%\build_run_config.py" "%CONFIG_DIR%\%RUN_ENV%"
if errorlevel 1 (
    echo Failed to generate config_run_auto.sas from %RUN_ENV%
    exit /b 1
)

set SAS_EXE="C:\Program Files\SASHome\SASFoundation\9.4\sas.exe"

%SAS_EXE% -sysin "%PROJECT_ROOT%etl\run_all.sas" ^
          -log "%LOG_DIR%\run_all.log" ^
          -nosplash -noterminal

endlocal
