/* macros/derive_tte_from_adresp.sas */
%macro derive_tte_from_adresp(paramcd=, event_codes=, outds=);
  %if %sysevalf(%superq(outds)=, boolean) %then %let outds=work._ev_resp_&paramcd.;
  %if not %sysfunc(exist(adam.adresp)) %then %do;
    data &outds.;
      length USUBJID $20 EVENTCD $32 ENDDT 8;
      format ENDDT date9.;
      stop;
    run;
    %return;
  %end;

  %let _codes = %upcase(&event_codes.);
  data &outds.;
    length ADT ADTDTM 8;
    set adam.adresp;
    length EVENTCD $32 ENDDT 8;
    format ENDDT date9.;
    if upcase(PARAMCD) = upcase("&paramcd.");
    EVENTCD = coalescec(upcase(AVALC), upcase(PARAMCD));
    ENDDT = coalesce(ADT, datepart(ADTDTM));
    if missing(EVENTCD) then EVENTCD='RESP';
    %if %sysevalf(%superq(event_codes)=, boolean)=0 %then %do;
      if not findw("&_codes.", strip(EVENTCD), '|', 't') then delete;
    %end;
    keep USUBJID EVENTCD ENDDT;
  run;
%mend;
