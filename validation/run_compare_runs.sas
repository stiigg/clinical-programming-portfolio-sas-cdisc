/* validation/run_compare_runs.sas */
%macro run_compare_runs(base_run=, new_run=, max_tier=1);
  %if %sysevalf(%superq(base_run)=, boolean) or %sysevalf(%superq(new_run)=, boolean) %then %do;
    %put ERROR: BASE_RUN and NEW_RUN must be provided.;
    %return;
  %end;
  %if %sysevalf(%superq(max_tier)=, boolean) %then %let max_tier=1;

  libname base_tlf "&PROJECTROOT./outputs/&base_run./tlf";
  libname new_tlf  "&PROJECTROOT./outputs/&new_run./tlf";

  %if not %sysfunc(exist(specs.spec_validate)) %then %do;
    %put WARNING: specs.spec_validate missing. Skipping regression compare.;
    %return;
  %end;

  data work._validate;
    set specs.spec_validate;
    where TIER <= &max_tier.;
  run;

  data _null_;
    set work._validate;
    call symputx(cats('val_outid_', _n_), strip(OUTID));
    call symputx('n_val', _n_);
  run;

  %if %sysevalf(%superq(n_val)=, boolean) %then %let n_val=0;

  %do _i = 1 %to &n_val.;
    %let _outid = &&val_outid_&_i.;
    %if %sysfunc(exist(base_tlf.&_outid.)) and %sysfunc(exist(new_tlf.&_outid.)) %then %do;
      proc compare base=base_tlf.&_outid. compare=new_tlf.&_outid.
        out=qc.compare_&_outid. outbase outcomp outdiff noprint;
      run;
      %put NOTE: [QC] Compared &_outid. between &base_run. and &new_run.;
    %end;
    %else %put WARNING: [QC] Missing dataset &_outid. in base_tlf or new_tlf.;
  %end;
%mend;
