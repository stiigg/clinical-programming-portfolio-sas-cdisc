/* config/run_INTERIM_2025M10.sas
   Exploratory interim run definition for October 2025 snapshot. */

%let RUN         = INTERIM_2025M10;
%let RUN_ID      = DEMO001_INT_2025M10;
%let MODE        = EXPLORATORY;
%let DATA_CUT_DT = 2025-10-15;
%let SAP_VERSION = SAP_v3_2_draftB;
%let TLF_SET     = INTERIM;

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
