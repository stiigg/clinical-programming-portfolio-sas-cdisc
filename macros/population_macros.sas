/* population_macros.sas
   Centralized population derivation and WHERE clause helpers. */

%macro derive_pop_flags(adsl_in=adam.adsl, adsl_out=adam.adsl);
  %if not %sysfunc(exist(&adsl_in.)) %then %do;
    %put WARNING: [RUN=&RUN_ID.] Cannot derive populations because &adsl_in. is missing.;
    %return;
  %end;

  data &adsl_out.;
    set &adsl_in.;
    length ITTFL SAFETYFL PPFL $1;

    if missing(ITTFL) then ITTFL = ifc(not missing(RANDDT), 'Y', 'N');
    if missing(SAFETYFL) then SAFETYFL = ifc(not missing(TRTDT), 'Y', 'N');
    if missing(PPFL) then PPFL = ifc(ITTFL='Y' and upcase(PROTVIOL) ne 'Y', 'Y', 'N');
  run;

  %if %sysfunc(macroexist(log_counts)) %then %do;
    %log_counts(lib=%scan(&adsl_out., 1, .), ds=%scan(&adsl_out., 2, .), label=Post-derive_pop_flags);
  %end;
%mend derive_pop_flags;

%macro get_pop_where(pop=);
  %local cond;
  %let pop=%upcase(&pop.);
  %if &pop = ITT %then %let cond = ITTFL='Y';
  %else %if &pop = SAF or &pop = SAFETY %then %let cond = SAFETYFL='Y';
  %else %if &pop = PP %then %let cond = PPFL='Y';
  %else %let cond = 1=0;
  &cond
%mend get_pop_where;
