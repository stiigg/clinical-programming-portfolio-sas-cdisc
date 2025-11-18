/* macros/derive_time_to_event.sas */
%macro derive_time_to_event(paramcd=);
  %local start_var end_domains event_codes cnsr_rule param line;
  %if %sysevalf(%superq(paramcd)=, boolean) %then %do;
    %put WARNING: PARAMCD not provided to %nrstr(%derive_time_to_event).;
    %return;
  %end;

  proc sql noprint;
    select PARAM, START_VAR, END_DOMAINS, EVENT_CODES, CNSR_RULE, LINE
      into :param trimmed,
           :start_var trimmed,
           :end_domains trimmed,
           :event_codes trimmed,
           :cnsr_rule trimmed,
           :line trimmed
    from specs.spec_adtte_params
    where upcase(PARAMCD)=upcase("&paramcd.");
  quit;

  %if &sqlobs = 0 %then %do;
    %put WARNING: No metadata found for PARAMCD=&paramcd..;
    %return;
  %end;
  %if %sysevalf(%superq(line)=, boolean) %then %let line=.;

  data work._events_&paramcd.;
    length USUBJID $20 EVENTCD $32 ENDDT 8;
    format ENDDT date9.;
    stop;
  run;

  %let _n_dom = %sysfunc(countw(&end_domains., |));
  %do _i = 1 %to &_n_dom.;
    %let _dom = %scan(&end_domains., &_i., |);
    %if %upcase(&_dom.) = ADRESP %then %do;
      %derive_tte_from_adresp(paramcd=&paramcd., event_codes=&event_codes., outds=work._ev_resp_&paramcd.);
      proc append base=work._events_&paramcd. data=work._ev_resp_&paramcd. force; run;
    %end;
    %else %if %upcase(&_dom.) = ADAE %then %do;
      %derive_tte_from_adae(paramcd=&paramcd., event_codes=&event_codes., outds=work._ev_ae_&paramcd.);
      proc append base=work._events_&paramcd. data=work._ev_ae_&paramcd. force; run;
    %end;
  %end;

  proc sql;
    create table work._adtte_&paramcd. as
    select a.USUBJID,
           "&paramcd." length=8 as PARAMCD,
           "&param." length=80 as PARAM,
           a.&start_var as STARTDT,
           e.ENDDT,
           (e.ENDDT - a.&start_var + 1) as AVAL,
           e.EVENTCD,
           a.STGGRP,
           a.SCLC_SUBTYPE,
           a.CNSBLFL,
           &line as LINE
    from adam.adsl as a
    left join work._events_&paramcd. as e
      on a.USUBJID = e.USUBJID;
  quit;

  %if %sysevalf(%superq(cnsr_rule)=, boolean) %then %let cnsr_rule=OS_DEFAULT;
  %if not %sysfunc(macroexist(&cnsr_rule.)) %then %let cnsr_rule=OS_DEFAULT;
  %&cnsr_rule.(ds=work._adtte_&paramcd.);

  proc append base=adam.adtte data=work._adtte_&paramcd. force; run;
%mend;
