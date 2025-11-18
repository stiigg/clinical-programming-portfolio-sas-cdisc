/* etl/etl_tlf.sas
   Load TLF metadata (including QC tiers) and persist the run-specific QC plan. */

%macro _ensure_run_set;
  %global RUN_SET;
  %if %sysevalf(%superq(RUN_SET)=, boolean) %then %let RUN_SET=&RUN.;
  %put NOTE: [TLF] RUN_SET resolved to &RUN_SET.;
%mend _ensure_run_set;

%_ensure_run_set;

proc import datafile="&SPECS_ROOT./spec_tlf.csv"
  out=work.meta_tlf dbms=csv replace;
  guessingrows=max;
run;

data work.meta_tlf;
  set work.meta_tlf;
  length run_set_clean $64 prog_name_clean $128 endpoint_clean $128 qc_method_clean $32
         ctq_flag_clean $1 risk_notes_clean $300;
  run_set_clean    = coalescec(strip(RUN_SET), strip(TLF_SET), "&RUN_SET.");
  prog_name_clean  = strip(coalescec(PROG_NAME, cats('prog_', lowcase(strip(TLF_ID)), '.sas')));
  endpoint_clean   = strip(coalescec(ENDPOINT, OUTPUT_NAME));
  qc_method_clean  = strip(upcase(coalescec(QC_METHOD, 'IND_REVIEW')));
  ctq_flag_clean   = strip(upcase(coalescec(CTQ_FLAG, 'N')));
  risk_notes_clean = strip(RISK_NOTES);
run;

data work.tlf_runlist;
  set work.meta_tlf;
  where upcase(run_set_clean) = upcase("&RUN_SET.") and upcase(RUN_ACTIVE) = 'Y';
  length run_set $64 endpoint $128 prog_name $128 qc_method $32 ctq_flag $1 risk_notes $300;
  run_set   = run_set_clean;
  endpoint  = endpoint_clean;
  prog_name = prog_name_clean;
  qc_method = qc_method_clean;
  ctq_flag  = ctq_flag_clean;
  risk_notes= risk_notes_clean;
run;

proc sort data=work.tlf_runlist;
  by order_no;
run;

data qc.qc_plan_&RUN_SET.;
  set work.tlf_runlist;
  length run_set_id $64;
  run_set_id = "&RUN_SET.";
  format created_dtm datetime19.;
  created_dtm = datetime();
run;

%let _tlf_dsid = %sysfunc(open(work.tlf_runlist));
%if &_tlf_dsid %then %do;
  %let _tlf_nobs = %sysfunc(attrn(&_tlf_dsid., nobs));
  %let _rc = %sysfunc(close(&_tlf_dsid.));
  %if &_tlf_nobs = 0 %then %put NOTE: [TLF] No active TLF metadata found for RUN_SET=&RUN_SET.;
%end;
%else %put WARNING: [TLF] work.tlf_runlist not available when checking counts.;
