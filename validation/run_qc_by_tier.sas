/* validation/run_qc_by_tier.sas
   Execute QC expectations driven by qc.qc_plan_<RUN_SET>. */

%macro run_qc_by_tier;
  %if %sysfunc(exist(qc.qc_plan_&RUN_SET.)) = 0 %then %do;
    %put WARNING: [QC] qc.qc_plan_&RUN_SET. not found. Run etl/etl_tlf.sas before %run_qc_by_tier.;
    %return;
  %end;

  data _null_;
    set qc.qc_plan_&RUN_SET.;
    call symputx(cats('qc_tlf_', _n_), strip(TLF_ID));
    call symputx(cats('qc_prog_', _n_), strip(PROG_NAME));
    call symputx(cats('qc_tier_', _n_), QC_TIER);
    call symputx(cats('qc_method_', _n_), strip(QC_METHOD));
    call symputx(cats('qc_ctq_', _n_), strip(CTQ_FLAG));
    call symputx(cats('qc_endpoint_', _n_), strip(ENDPOINT));
    call symputx('qc_n', _n_);
  run;

  %if %sysevalf(%superq(qc_n)=, boolean) %then %let qc_n=0;

  %do _i = 1 %to &qc_n.;
    %let _qc_tlf   = &&qc_tlf_&_i.;
    %let _qc_prog  = %lowcase(%scan(&&qc_prog_&_i., 1, .));
    %let _qc_tier  = &&qc_tier_&_i.;
    %let _qc_method= &&qc_method_&_i.;
    %let _qc_ctq   = &&qc_ctq_&_i.;
    %let _qc_endpoint = &&qc_endpoint_&_i.;
    %let _qc_prog_path = &VALIDATION_ROOT./&_qc_prog._qc.sas;

    %if &_qc_tier = 1 and %upcase(&_qc_method) = DOUBLE_PROG %then %do;
      %if %sysfunc(fileexist(&_qc_prog_path.)) %then %do;
        %put NOTE: [QC] Tier 1 &_qc_tlf. (&_qc_endpoint.) double programming via &_qc_prog_path.;
        %include "&_qc_prog_path.";
        %qc_compare_tlf(tlf_id=&_qc_tlf.);
      %end;
      %else %put ERROR: [QC] Tier 1 &_qc_tlf. has no QC program &_qc_prog_path.;
    %end;
    %else %if &_qc_tier = 2 and %upcase(&_qc_method) = IND_REVIEW %then %do;
      %put NOTE: [QC] Tier 2 &_qc_tlf. (&_qc_endpoint.) scheduled for independent review (CtQ=&_qc_ctq.).;
    %end;
    %else %if &_qc_tier = 3 %then %do;
      %put NOTE: [QC] Tier 3 &_qc_tlf. (&_qc_endpoint.) targeted QC (CtQ=&_qc_ctq.).;
    %end;
    %else %put NOTE: [QC] No explicit QC rule for &_qc_tlf. (tier=&_qc_tier., method=&_qc_method.).;
  %end;

  proc sort data=qc.qc_plan_&RUN_SET. out=work._qc_plan_sorted;
    by TLF_ID;
  run;

  %local _qc_result_list;
  proc sql noprint;
    select catx('.', libname, memname)
      into :_qc_result_list separated by ' '
      from dictionary.tables
     where upcase(libname) = 'QC' and upcase(memname) like 'QC_RESULTS_%';
  quit;

  %if %sysevalf(%superq(_qc_result_list)=, boolean) %then %do;
    data work._qc_results_all;
      length tlf_id $32 status $12 run_set_id $64 reviewed_dtm 8;
      stop;
    run;
  %end;
  %else %do;
    data work._qc_results_all;
      set &_qc_result_list.;
    run;
  %end;

  proc sort data=work._qc_results_all;
    by tlf_id;
  run;

  data qc.qc_summary_&RUN_SET.;
    merge work._qc_plan_sorted(in=a) work._qc_results_all(in=b);
    by tlf_id;
    if a;
  run;

  proc export data=qc.qc_summary_&RUN_SET.
      outfile="&QC_ROOT./qc_summary_&RUN_SET..csv"
      dbms=csv replace;
  run;
%mend run_qc_by_tier;
