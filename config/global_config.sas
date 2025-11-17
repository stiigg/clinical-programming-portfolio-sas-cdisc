/* config/global_config.sas
   Study-wide SAS configuration for the portfolio pipeline. */

%global STUDY_ID PROTOCOL_ID ROOT PROJECT_ROOT RAW_ROOT SDTM_ROOT ADAM_ROOT TLF_ROOT LOG_ROOT
        QC_ROOT REG_ROOT SPECS_ROOT VALIDATION_ROOT studyid sponsor protocol sdtm_version
        adam_version OUTPUT_ROOT LOG_SUBDIR QC_SUBDIR ADAM_LIB SDTM_LIB;

%if %sysevalf(%superq(ROOT)=, boolean) %then %do;
  %put ERROR: ROOT macro variable not provided. Pass -set ROOT <repo_path> or %let ROOT= before including config/global_config.sas.;
  %abort cancel;
%end;

%let PROJECT_ROOT = &ROOT.;
%let STUDY_ID     = DEMO001;
%let PROTOCOL_ID  = DEMO-001;
%let studyid      = &STUDY_ID.;
%let sponsor      = Portfolio Labs;
%let protocol     = &PROTOCOL_ID.;
%let sdtm_version = 3.4;
%let adam_version = 1.1;

%let OUTPUT_ROOT     = &ROOT./outputs;
%let SPECS_ROOT      = &ROOT./specs;
%let RAW_ROOT        = &ROOT./data/raw;
%let SDTM_ROOT       = &ROOT./outputs/sdtm;
%let ADAM_ROOT       = &ROOT./outputs/adam;
%let TLF_ROOT        = &ROOT./outputs/tlf;
%let LOG_ROOT        = &ROOT./outputs/logs;
%let QC_ROOT         = &ROOT./outputs/qc;
%let REG_ROOT        = &ROOT./outputs/regulatory;
%let VALIDATION_ROOT = &ROOT./validation;
%let LOG_SUBDIR      = logs;
%let QC_SUBDIR       = qc;
%let ADAM_LIB        = adam;
%let SDTM_LIB        = sdtm;

options dlcreatedir;
libname raw   "&RAW_ROOT.";
libname sdtm  "&SDTM_ROOT.";
libname adam  "&ADAM_ROOT.";
libname tlf   "&TLF_ROOT.";
libname meta  "&SPECS_ROOT.";
libname specs "&SPECS_ROOT.";
libname qc    "&QC_ROOT.";
libname reg   "&REG_ROOT.";
libname logs  "&LOG_ROOT.";

options nomprint nomlogic nocenter mstored symbolgen linesize=200 pagesize=60;

%put NOTE: ROOT set to &ROOT.;
%put NOTE: STUDY_ID=&STUDY_ID. PROTOCOL_ID=&PROTOCOL_ID.;
