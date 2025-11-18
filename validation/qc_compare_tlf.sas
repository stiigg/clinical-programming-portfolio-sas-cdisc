/* validation/qc_compare_tlf.sas
   Compare production and QC TLF datasets with consistent logging. */

%macro qc_compare_tlf(tlf_id=);
  %local base_ds qc_ds status;
  %let base_ds = tlf.&tlf_id.;
  %let qc_ds   = qc.qc_&tlf_id.;
  %let status  = MISSING;

  %if %sysfunc(exist(&base_ds.)) and %sysfunc(exist(&qc_ds.)) %then %do;
    ods listing close;
    ods output CompareSummary=work._qc_compare_summary;
    proc compare base=&base_ds. compare=&qc_ds. criterion=1e-10;
    run;
    ods listing;

    data qc.qc_cmp_&tlf_id.;
      set work._qc_compare_summary;
    run;

    %if &sysinfo = 0 %then %let status = PASS;
    %else %let status = FAIL;
  %end;
  %else %if %sysfunc(exist(&base_ds.)) = 0 %then %let status = PROD_MISSING;
  %else %if %sysfunc(exist(&qc_ds.)) = 0 %then %let status = QC_MISSING;

  data qc.qc_results_&tlf_id.;
    length tlf_id $32 status $12 run_set_id $64;
    tlf_id     = "&tlf_id.";
    status     = "&status.";
    run_set_id = "&RUN_SET.";
    reviewed_dtm = datetime();
    format reviewed_dtm datetime19.;
  run;
%mend qc_compare_tlf;
