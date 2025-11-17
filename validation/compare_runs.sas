/* compare_runs.sas
   Regression harness to compare ADaM datasets between two runs. */

%include "&ROOT./config/global_config.sas";
%include "&ROOT./config/select_run.sas";

%let BASE_RUN_ID = %sysfunc(coalescec(%superq(BASE_RUN_ID), LOCK_MAIN));
%let CURR_RUN_ID = &RUN_ID.;

libname adam_base "&ADAM_ROOT./&BASE_RUN_ID.";
libname adam_curr "&ADAM_ROOT./&CURR_RUN_ID.";

%macro compare_adam(ds=);
  %if %sysfunc(exist(adam_base.&ds.)) and %sysfunc(exist(adam_curr.&ds.)) %then %do;
    %let cmp_out=%sysfunc(coalescec(&QC_OUT., &QC_ROOT.))/comp_&ds._&BASE_RUN_ID._vs_&CURR_RUN_ID.;
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
