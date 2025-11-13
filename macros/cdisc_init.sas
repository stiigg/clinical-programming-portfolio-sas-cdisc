/* cdisc_init.sas
   Initializes the SAS session for the metadata-driven clinical pipeline. */

%macro cdisc_init(study_config=, project_root=);
  %global project_root studyid sponsor protocol sdtm_version adam_version;

  %if %length(&project_root) %then %let project_root=&project_root;
  %if %sysevalf(%superq(project_root)=, boolean) %then %do;
    %if %length(&study_config)=0 %then %let study_config=config/config_study.sas;
    %if %sysfunc(fileexist("&study_config.")) %then %do;
      %include "&study_config.";
    %end;
    %else %do;
      %put ERROR: Study configuration &study_config. not found.;
    %end;
  %end;

  %if %sysfunc(fileexist("&project_root./config/config_global.sas")) %then %do;
    %include "&project_root./config/config_global.sas";
  %end;
  %else %do;
    %put ERROR: Global configuration not found at &project_root./config/config_global.sas.;
  %end;
%mend;
