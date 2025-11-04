/*-----------------------------------------------------------------------------
Macro:       %specdiff
Purpose:     Compare produced ADaM datasets against metadata specifications
Expectations:
  - SPEC CSV contains DOMAIN, VARNAME, TYPE, LEN columns at minimum
-----------------------------------------------------------------------------*/
%macro specdiff(domain=, spec=, out=);
  %if %superq(domain)= %then %do;
    %put ERROR: specdiff requires DOMAIN=.;
    %return;
  %end;
  %if %superq(spec)= %then %let spec=%superq(G_METADATA_SPEC_PATH)/adam_spec.csv;
  %if %superq(out)= %then %let out=%superq(G_REPORT_ROOT)/specdiff/%upcase(&domain)_specdiff.csv;

  proc import datafile="&spec" out=_spec dbms=csv replace;
    guessingrows=max;
  run;

  proc contents data=ADaM.&domain out=_cont(keep=name type length) noprint;
  run;

  proc sql;
    create table _diff as
    select s.DOMAIN,
           s.VARNAME,
           s.TYPE   as SPEC_TYPE,
           s.LEN    as SPEC_LEN,
           c.type   as DATA_TYPE,
           c.length as DATA_LEN
    from _spec s
    left join _cont c
      on upcase(s.VARNAME)=upcase(c.name)
     and upcase(s.DOMAIN)=upcase("&domain");
  quit;

  data _diff;
    set _diff;
    MISSING_IN_DATA = missing(DATA_TYPE);
    LEN_MISMATCH    = not missing(DATA_LEN) and SPEC_LEN ne DATA_LEN;
    TYPE_MISMATCH   = not missing(DATA_TYPE) and SPEC_TYPE ne DATA_TYPE;
  run;

  proc export data=_diff outfile="&out" dbms=csv replace;
  run;

  %let _dsid=%sysfunc(open(_diff));
  %if &_dsid %then %do;
    %let _nobs=%sysfunc(attrn(&_dsid, nlobs));
    %let _rc=%sysfunc(close(&_dsid));
  %end;
  %else %let _nobs=0;

  %assert(&_nobs>0, msg=Spec diff executed for &domain, level=WARN);

  proc datasets lib=work nolist;
    delete _spec _cont _diff;
  quit;
%mend specdiff;
