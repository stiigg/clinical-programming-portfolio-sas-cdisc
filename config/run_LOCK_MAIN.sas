/* config/run_LOCK_MAIN.sas
   Production run definition for the primary database lock. */

%let RUN         = LOCK_MAIN;
%let RUN_ID      = DEMO001_LOCK_2025Q1;
%let MODE        = PROD;
%let DATA_CUT_DT = 2025-03-31;
%let SAP_VERSION = SAP_v3_2;
%let TLF_SET     = PRIMARY;

%let INCLUDE_SD  = Y;
%let INCLUDE_AD  = Y;
%let INCLUDE_TLF = Y;

%let SDTM_OUT = &SDTM_ROOT./&RUN_ID.;
%let ADAM_OUT = &ADAM_ROOT./&RUN_ID.;
%let TLF_OUT  = &TLF_ROOT./&RUN_ID.;
%let LOG_OUT  = &LOG_ROOT./&RUN_ID.;
%let QC_OUT   = &QC_ROOT./&RUN_ID.;

libname sdtm "&SDTM_OUT.";
libname adam "&ADAM_OUT.";
libname tlf  "&TLF_OUT.";
libname logs "&LOG_OUT.";
libname qc   "&QC_OUT.";
