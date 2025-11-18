/* population_macros.sas
   Centralized population derivation and WHERE clause helpers. */

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

  %if %sysfunc(macroexist(log_counts)) %then %do;
    %log_counts(lib=%scan(&adsl_out., 1, .), ds=%scan(&adsl_out., 2, .), label=Post-derive_pop_flags);
  %end;
%mend derive_pop_flags;

%macro get_pop_where(pop=);
  %local _flag;
  %let _flag=;
  %if %sysfunc(exist(specs.spec_popflags)) %then %do;
    proc sql noprint;
      select strip(FLAGVAR)
        into :_flag trimmed
      from specs.spec_popflags
      where upcase(POP)=upcase("&pop.");
    quit;
  %end;
  %if %sysevalf(%superq(_flag)=, boolean) %then %do;
    %if %upcase(&pop.) = ITT %then %let _flag = ITTFL;
    %else %if %upcase(&pop.) = SAF or %upcase(&pop.) = SAFETY %then %let _flag = SAFETYFL;
    %else %if %upcase(&pop.) = PPS or %upcase(&pop.) = PP %then %let _flag = PPFL;
  %end;

  %if %sysevalf(%superq(_flag)=, boolean) %then 0;
  %else %unquote(&_flag)='Y';
%mend get_pop_where;
