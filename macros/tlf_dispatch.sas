/* tlf_dispatch.sas
   Dispatch metadata-driven TLF requests that were staged in work.tlf_runlist. */

%macro tlf_dispatch;
  %if %sysfunc(exist(work.tlf_runlist)) = 0 %then %do;
    %put ERROR: [TLF] work.tlf_runlist not found. Include etl/etl_tlf.sas before calling %tlf_dispatch.;
    %return;
  %end;

  data _null_;
    set work.tlf_runlist;
    call symputx(cats('tlf_id_', _n_), strip(TLF_ID));
    call symputx(cats('program_', _n_), strip(PROGRAM_ID));
    call symputx(cats('population_', _n_), strip(POPULATION));
    call symputx(cats('param_family_', _n_), strip(PARAM_FAMILY));
    call symputx(cats('paramcd_list_', _n_), strip(PARAMCD_LIST));
    call symputx(cats('risk_level_', _n_), strip(RISK_LEVEL));
    call symputx(cats('qc_tier_', _n_), strip(QC_TIER));
    call symputx(cats('qc_method_', _n_), strip(QC_METHOD));
    call symputx(cats('ctq_flag_', _n_), strip(CTQ_FLAG));
    call symputx(cats('prog_name_', _n_), strip(PROG_NAME));
    call symputx(cats('endpoint_', _n_), strip(ENDPOINT));
    call symputx('tlf_n', _n_);
  run;

  %if %sysevalf(%superq(tlf_n)=, boolean) %then %let tlf_n=0;

  %do _i = 1 %to &tlf_n.;
    %let _tlf_id   = &&tlf_id_&_i.;
    %let _program  = &&program_&_i.;
    %let _population = &&population_&_i.;
    %let _param_family = &&param_family_&_i.;
    %let _paramcd_list = &&paramcd_list_&_i.;
    %let _risk_level = &&risk_level_&_i.;
    %let _qc_tier  = &&qc_tier_&_i.;
    %let _qc_method= &&qc_method_&_i.;
    %let _ctq_flag = &&ctq_flag_&_i.;
    %let _prog_name= &&prog_name_&_i.;
    %let _endpoint = &&endpoint_&_i.;

    %log_run_tlf_start(&_tlf_id., &_program., &_population., &_risk_level.);
    %put NOTE: [TLF] &_tlf_id. (&_program., endpoint=&_endpoint., qc_tier=&_qc_tier., qc_method=&_qc_method., ctq=&_ctq_flag.).;

    %if %sysfunc(macroexist(&_program.)) %then %do;
      %&_program.(
        tlf_id=&_tlf_id.,
        population=&_population.,
        param_family=&_param_family.,
        paramcd_list=&_paramcd_list.,
        risk_level=&_risk_level.
      );
    %end;
    %else %put ERROR: [RUN=&RUN_ID.] Unknown PROGRAM_ID=&_program. for TLF=&_tlf_id.;

    %log_run_tlf_end(&_tlf_id., &_program.);
  %end;

  %if &tlf_n. = 0 %then %put NOTE: [TLF] No TLFs dispatched for RUN_SET=&RUN_SET.;
%mend tlf_dispatch;
