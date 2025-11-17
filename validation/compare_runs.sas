/* compare_runs.sas
   Regression harness to compare ADaM datasets between two runs. */

%include "config/config_study.sas";
%include "config/config_run_auto.sas";

%let BASE_RUN_ID = %sysfunc(coalescec(&BASE_RUN_ID., LOCK_2025Q1));
%let CURR_RUN_ID = &RUN_ID.;

%let _out_root=&OUTPUT_ROOT.;
libname adam_base "&_out_root./&BASE_RUN_ID./adam";
libname adam_curr "&_out_root./&CURR_RUN_ID./adam";

%macro compare_adam(ds=);
  %if %sysfunc(exist(adam_base.&ds.)) and %sysfunc(exist(adam_curr.&ds.)) %then %do;
    %let cmp_out=&_out_root./&QC_SUBDIR./comp_&ds._&BASE_RUN_ID._vs_&CURR_RUN_ID.;
    proc compare base=adam_base.&ds.
                 compare=adam_curr.&ds.
                 out="&cmp_out."
                 criterion=1e-12 noprint;
    run;

    %if &sysinfo ne 0 %then %put WARNING: Differences detected in ADaM &ds.;
    %else %put NOTE: ADaM &ds. matches between runs.;
  %end;
  %else %put WARNING: Missing dataset for comparison: &ds.;
%mend compare_adam;

%compare_adam(ds=adsl);
%compare_adam(ds=adtte);
