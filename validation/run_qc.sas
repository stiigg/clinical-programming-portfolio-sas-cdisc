/* validation/run_qc.sas */
%include "&PROJECTROOT./validation/run_compare_runs.sas";

%macro run_qc;
  %if %sysevalf(%superq(BASE_RUN)=, boolean) %then %let BASE_RUN=&RUN.;
  %if %sysevalf(%superq(NEW_RUN)=, boolean) %then %let NEW_RUN=&RUN.;
  %if %sysevalf(%superq(MAX_TIER)=, boolean) %then %let MAX_TIER=2;

  %run_compare_runs(base_run=&BASE_RUN., new_run=&NEW_RUN., max_tier=&MAX_TIER.);
%mend;

%run_qc;
