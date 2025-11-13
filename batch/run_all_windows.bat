@echo off
set PROJECT_ROOT=%~dp0..\
set SAS_EXE="C:\Program Files\SASHome\SASFoundation\9.4\sas.exe"

%SAS_EXE% -sysin "%PROJECT_ROOT%\etl\raw_to_sdtm.sas" -log "%PROJECT_ROOT%\outputs\logs\raw_to_sdtm.log"
%SAS_EXE% -sysin "%PROJECT_ROOT%\etl\sdtm_to_adam.sas" -log "%PROJECT_ROOT%\outputs\logs\sdtm_to_adam.log"
%SAS_EXE% -sysin "%PROJECT_ROOT%\validation\checks_integrity.sas" -log "%PROJECT_ROOT%\outputs\logs\checks_integrity.log"
%SAS_EXE% -sysin "%PROJECT_ROOT%\regulatory\define_build.sas" -log "%PROJECT_ROOT%\outputs\logs\define_build.log"
