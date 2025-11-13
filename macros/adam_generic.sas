/* adam_generic.sas
   Shared ADaM utilities. */

%macro adam_traceability(domain=, out=);
  %if %length(&out)=0 %then %let out=qc.trace_&domain.;
  %if %sysfunc(exist(meta.traceability)) %then %do;
    data &out.;
      length DOMAIN $32 SOURCE $64 VARIABLE $32;
      set meta.traceability(where=(upcase(domain)="%upcase(&domain.)"));
    run;
  %end;
  %else %do;
    %put NOTE: No traceability dataset found in META library.;
  %end;
%mend;

%macro adam_apply_flags(ds=, flag_var=, condition=);
  data &ds.;
    set &ds.;
    &flag_var. = ifc(&condition., 'Y', 'N');
  run;
%mend;
