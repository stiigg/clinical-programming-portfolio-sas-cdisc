/* macros/derive_tte_from_adae.sas */
%macro derive_tte_from_adae(paramcd=, event_codes=, outds=);
  %if %sysevalf(%superq(outds)=, boolean) %then %let outds=work._ev_ae_&paramcd.;
  %if not %sysfunc(exist(adam.adae)) %then %do;
    data &outds.;
      length USUBJID $20 EVENTCD $32 ENDDT 8;
      format ENDDT date9.;
      stop;
    run;
    %return;
  %end;

  %let _codes = %upcase(&event_codes.);
  data &outds.;
    length ASTDT ASTDTM AENDT AENDTM 8;
    set adam.adae;
    length EVENTCD $32 ENDDT 8;
    format ENDDT date9.;
    EVENTCD = upcase(coalescec(AEDECOD, AESOC, 'AE'));
    ENDDT = coalesce(AENDT, datepart(AENDTM));
    if missing(ENDDT) then ENDDT = coalesce(ASTDT, datepart(ASTDTM));
    %if %sysevalf(%superq(event_codes)=, boolean)=0 %then %do;
      if not findw("&_codes.", strip(EVENTCD), '|', 't') then delete;
    %end;
    keep USUBJID EVENTCD ENDDT;
  run;
%mend;
