/* etl/run_study.sas
   Master dispatcher that drives SDTM, ADaM, and TLF generation for a run config. */
%let _runparm = %superq(SYSPARM);
%if %sysevalf(%superq(_runparm)=, boolean) %then %do;
  %put ERROR: SYSPARM not provided. Invoke SAS with -sysparm <run_name> (e.g. SCLC_LOCK_2025Q4).;
  %abort cancel;
%end;

%global PROJECTROOT;
%if %sysevalf(%superq(PROJECTROOT)=, boolean) %then %do;
  %let _sysin = %sysfunc(getoption(sysin));
  %let PROJECTROOT = %sysfunc(prxchange('s/[\\/]+etl[\\/]+run_study\.sas$//i', 1, &_sysin.));
%end;

%if %sysevalf(%superq(PROJECTROOT)=, boolean) %then %do;
  %put ERROR: Unable to resolve PROJECTROOT. Pass -set PROJECTROOT <repo_root> or update config/config_study.sas.;
  %abort cancel;
%end;

%include "&PROJECTROOT./config/config_study.sas";
%include "&PROJECTROOT./config/run_&_runparm..sas";
%include "&PROJECTROOT./macros/run_init.sas";
%run_init;

%if %sysevalf(%superq(RUN_SET)=, boolean) %then %let RUN_SET=&RUN.;

%if %upcase(&RUN_SDTM)=Y %then %do;
  %include "&PROJECTROOT./etl/run_sdtm.sas";
%end;
%else %put NOTE: RUN_SDTM=&RUN_SDTM. so SDTM build skipped.;

%if %upcase(&RUN_ADAM)=Y %then %do;
  %include "&PROJECTROOT./etl/run_adam.sas";
%end;
%else %put NOTE: RUN_ADAM=&RUN_ADAM. so ADaM build skipped.;

%if %upcase(&RUN_TLF)=Y %then %do;
  %include "&PROJECTROOT./etl/run_tlf.sas";
%end;
%else %put NOTE: RUN_TLF=&RUN_TLF. so TLF build skipped.;

%if %upcase(&RUN_QC)=Y %then %do;
  %include "&PROJECTROOT./validation/run_qc.sas";
%end;
%else %put NOTE: RUN_QC=&RUN_QC. so QC harness skipped.;
