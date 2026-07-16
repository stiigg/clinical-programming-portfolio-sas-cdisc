/* jenner-check bundle: macros/population_macros.sas (%derive_pop_flags)
   from stiigg/clinical-programming-portfolio-sas-cdisc
   Caller exercises the repo's %derive_pop_flags macro -- the population
   derivation step every ADaM build in this pipeline runs before endpoint
   analysis. A small ADSL-shaped dataset (5 subjects, shaped like
   data/raw/dm.csv plus RANDDT/TRTDT/PROTVIOL) stands in for adam.adsl;
   no specs.spec_popflags dataset is defined, so the macro's default
   branch derives ITTFL/SAFETYFL/PPFL directly (the same branch that
   fires in the actual pipeline until a study-specific popflags spec is
   authored). %derive_pop_flags is copied verbatim except for the final
   %log_counts guard: the source gates that call behind
   %sysfunc(macroexist(log_counts)), but MACROEXIST is not a documented
   SAS 9.4 macro function (SYSMACEXIST is the real one), so that guard
   is dropped here rather than adapted around it. Everything else in
   %derive_pop_flags -- the population-flag derivation logic itself --
   is unchanged. */

libname adam "%sysfunc(pathname(work))";

data adam.adsl;
  length USUBJID $10 ARMCD $2;
  format RANDDT TRTDT date9.;
  input USUBJID $ ARMCD $ RANDDT :date9. TRTDT :date9. PROTVIOL $;
  datalines;
S001 B 12JAN2025 12JAN2025 N
S002 B 15JAN2025 . N
S003 B 14JAN2025 14JAN2025 Y
S004 A 05JAN2025 06JAN2025 N
S005 B . . N
;
run;

/* ---- macros/population_macros.sas (%derive_pop_flags, verbatim) ---- */
%macro derive_pop_flags(adsl_in=adam.adsl, adsl_out=adam.adsl);
  %local _spec _n;
  %let _spec = specs.spec_popflags;

  %if not %sysfunc(exist(&adsl_in.)) %then %do;
    %put WARNING: [RUN=&RUN.] Cannot derive populations because &adsl_in. is missing.;
    %return;
  %end;

  %if %sysfunc(exist(&_spec.)) %then %do;
    data work._pop_spec;
      set &_spec.;
      length idx 8;
      idx = _n_;
      call symputx(cats('pop_name', idx), POP, 'l');
      call symputx(cats('flag_var', idx), FLAGVAR, 'l');
      call symputx(cats('cond', idx), CONDITION, 'l');
      call symputx(cats('flag_label', idx), LABEL, 'l');
      call symputx('n_pop_spec', idx, 'l');
    run;
    %if %sysevalf(%superq(n_pop_spec)=, boolean) %then %let _n=0;
    %else %let _n=&n_pop_spec.;
  %end;
  %else %let _n = 0;

  data &adsl_out.;
    set &adsl_in.;
    %if &_n > 0 %then %do i=1 %to &_n;
      length &&flag_var&i $1;
      label &&flag_var&i = "&&flag_label&i";
      if %superq(cond&i) then &&flag_var&i = 'Y';
      else if missing(&&flag_var&i) then &&flag_var&i = 'N';
    %end;
    %else %do;
      length ITTFL SAFETYFL PPFL $1;
      if missing(ITTFL) then ITTFL = ifc(not missing(RANDDT), 'Y', 'N');
      if missing(SAFETYFL) then SAFETYFL = ifc(not missing(TRTDT), 'Y', 'N');
      if missing(PPFL) then PPFL = ifc(ITTFL='Y' and upcase(PROTVIOL) ne 'Y', 'Y', 'N');
    %end;
  run;
%mend derive_pop_flags;

%derive_pop_flags(adsl_in=adam.adsl, adsl_out=adam.adsl);

proc print data=adam.adsl noobs;
  var USUBJID ARMCD RANDDT TRTDT PROTVIOL ITTFL SAFETYFL PPFL;
  title 'ADSL population flags via the default (no-spec) branch of derive_pop_flags';
run;
