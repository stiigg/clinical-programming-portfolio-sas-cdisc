/* jenner-check bundle: macros/tte_censoring_rules.sas (%OS_DEFAULT)
   from stiigg/clinical-programming-portfolio-sas-cdisc
   Caller exercises the repo's %OS_DEFAULT overall-survival censoring
   rule -- the rule %derive_time_to_event falls back to whenever a
   PARAMCD's spec row leaves CNSR_RULE blank or names an undefined
   macro. Six inline event-shaped rows (a mix of DEATH and non-DEATH
   EVENTCD values, some with STARTDT/ENDDT gaps) exercise both the
   CNSR/EVNTFL assignment and the shared %_tte_finalize AVAL-from-dates
   fallback. Both macros are copied verbatim. */

data _events;
  length USUBJID $10 EVENTCD $16;
  format STARTDT ENDDT date9.;
  input USUBJID $ EVENTCD $ STARTDT :date9. ENDDT :date9. AVAL CNSR;
  datalines;
S001 DEATH     12JAN2025 24JUN2025 . .
S002 PD        15JAN2025 27JUN2025 . .
S003 DEATH     14JAN2025 04JUN2025 . .
S004 CENSORED  05JAN2025 26JUN2025 . .
S005 PD        15JAN2025 12JUN2025 . .
S006 CENSORED  24JAN2025 02JUN2025 . .
;
run;

/* ---- macros/tte_censoring_rules.sas (%OS_DEFAULT + %_tte_finalize, verbatim) ---- */
%macro _tte_finalize(ds=);
  data &ds.;
    set &ds.;
    length EVNTFL $1;
    if missing(CNSR) then CNSR=1;
    if missing(EVNTFL) then EVNTFL=ifc(CNSR=0, 'Y', 'N');
    if missing(AVAL) and not missing(ENDDT) and not missing(STARTDT) then
      AVAL = ENDDT - STARTDT + 1;
  run;
%mend;

%macro OS_DEFAULT(ds=);
  data &ds.;
    set &ds.;
    length EVNTFL $1;
    if upcase(EVENTCD) = 'DEATH' then do;
      CNSR=0;
      EVNTFL='Y';
    end;
    else do;
      CNSR=1;
      EVNTFL='N';
    end;
  run;
  %_tte_finalize(ds=&ds.);
%mend;

%OS_DEFAULT(ds=_events);

proc print data=_events noobs;
  var USUBJID EVENTCD STARTDT ENDDT AVAL CNSR EVNTFL;
  title 'OS_DEFAULT censoring: DEATH events uncensored, everything else censored';
run;
