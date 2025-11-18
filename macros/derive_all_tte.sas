/* macros/derive_all_tte.sas */
%macro derive_all_tte;
  %if not %sysfunc(exist(specs.spec_adtte_params)) %then %do;
    %put WARNING: spec_adtte_params not found. Skipping ADTTE derivations.;
    %return;
  %end;

  data adam.adtte;
    length USUBJID $20 PARAMCD $8 PARAM $80 STARTDT ENDDT 8 AVAL 8 EVENTCD $32
           STGGRP $3 SCLC_SUBTYPE $12 CNSBLFL $1 LINE 8 CNSR 8 EVNTFL $1;
    stop;
  run;

  proc sql noprint;
    select distinct PARAMCD into :_tte_params separated by ' '
    from specs.spec_adtte_params;
  quit;

  %if %sysevalf(%superq(_tte_params)=, boolean) %then %do;
    %put NOTE: No PARAMCD entries in spec_adtte_params. Nothing to derive.;
    %return;
  %end;

  %let _n = %sysfunc(countw(&_tte_params., %str( )));
  %do _i = 1 %to &_n.;
    %let _param = %scan(&_tte_params., &_i., %str( ));
    %derive_time_to_event(paramcd=&_param.);
  %end;
%mend;
