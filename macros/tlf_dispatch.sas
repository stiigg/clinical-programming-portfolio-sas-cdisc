/* tlf_dispatch.sas */
%macro tlf_dispatch(run_set=&RUN_SET.);
  %if %sysfunc(exist(work.tlf_runlist)) = 0 %then %do;
    %put ERROR: [TLF] work.tlf_runlist not found. Run etl/etl_tlf.sas first.;
    %return;
  %end;

  data _null_;
    set work.tlf_runlist;
    call symputx(cats('outid_', _n_), strip(OUTID));
    call symputx(cats('type_', _n_), strip(ANALYSIS_TYPE));
    call symputx(cats('dataset_', _n_), strip(DATASET));
    call symputx(cats('paramcd_', _n_), strip(PARAMCD));
    call symputx(cats('pop_', _n_), strip(POPULATION));
    call symputx(cats('subgrp_', _n_), strip(SUBGRP_ID));
    call symputx(cats('tier_', _n_), strip(TIER));
    call symputx('n_tlf', _n_);
  run;

  %if %sysevalf(%superq(n_tlf)=, boolean) %then %let n_tlf=0;

  %do _i = 1 %to &n_tlf.;
    %let _outid   = &&outid_&_i.;
    %let _type    = &&type_&_i.;
    %let _dataset = &&dataset_&_i.;
    %let _paramcd = &&paramcd_&_i.;
    %let _pop     = &&pop_&_i.;
    %let _subgrp  = &&subgrp_&_i.;

    %put NOTE: [TLF] Dispatch &_outid. type=&_type. param=&_paramcd. pop=&_pop. subgrp=&_subgrp.;

    %if %upcase(&_type.) = TTE_KM %then %do;
      %tlf_km(outid=&_outid., ds=&_dataset., paramcd=&_paramcd., pop=&_pop., subgrp=&_subgrp.);
    %end;
    %else %if %upcase(&_type.) = RESP_RATE %then %do;
      %tlf_resp_rate(outid=&_outid., ds=&_dataset., paramcd=&_paramcd., pop=&_pop., subgrp=&_subgrp.);
    %end;
    %else %put WARNING: [TLF] Unsupported ANALYSIS_TYPE=&_type. for OUTID=&_outid.;
  %end;

  %if &n_tlf = 0 %then %put NOTE: [TLF] No TLFs dispatched for RUN_SET=&run_set.;
%mend;
