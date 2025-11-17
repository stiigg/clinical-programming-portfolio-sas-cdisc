/* cdisc_init.sas
   Initializes the SAS session for the metadata-driven clinical pipeline. */

%macro cdisc_init(study_config=, project_root=);
  %global ROOT project_root studyid sponsor protocol sdtm_version adam_version;

  %if %length(&project_root) %then %let ROOT=&project_root.;
  %if %sysevalf(%superq(ROOT)=, boolean) %then %do;
    %if %length(&study_config)=0 %then %let study_config=config/config_study.sas;
    %if %sysfunc(fileexist("&study_config.")) %then %do;
      %include "&study_config.";
      %if %sysevalf(%superq(project_root)=, boolean)=0 %then %let ROOT=&project_root.;
    %end;
    %else %put WARNING: Study configuration &study_config. not found. Set ROOT before calling %nrstr(%cdisc_init).
  %end;

  %if %sysevalf(%superq(ROOT)=, boolean) %then %do;
    %put ERROR: ROOT macro variable not set. Use -set ROOT <repo_path> or %let ROOT= prior to calling %nrstr(%cdisc_init).;
    %abort cancel;
  %end;

  %if %sysevalf(%superq(project_root)=, boolean) %then %let project_root=&ROOT.;

  %if %sysfunc(fileexist("&ROOT./config/global_config.sas")) %then %do;
    %include "&ROOT./config/global_config.sas";
  %end;
  %else %put ERROR: global_config.sas not found under &ROOT./config.;

  %if %sysevalf(%superq(RUN)=, boolean)=0 %then %do;
    %if %sysfunc(fileexist("&ROOT./config/select_run.sas")) %then %include "&ROOT./config/select_run.sas";
  %end;
%mend;
