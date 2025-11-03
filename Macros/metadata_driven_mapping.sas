
/******************************************************************************************
 * metadata_driven_mapping.sas
 ******************************************************************************************/
%global root raw sdtm adam specs;
%let root = <ABSOLUTE_PATH_TO_PROJECT>;
%let raw  = &root./SDTM/raw_data;
%let sdtm = &root./SDTM/SDTM_domains;
%let adam = &root./ADaM/analysis_datasets;
%let specs= &root./ADaM/specifications;

options mprint mlogic symbolgen validvarname=upcase;

%macro import_csv(ds=, file=, guessingrows=MAX);
  proc import datafile="&file." out=&ds. dbms=csv replace;
    guessingrows=&guessingrows.;
  run;
%mend;

%macro export_csv(ds=, file=);
  proc export data=&ds. outfile="&file." dbms=csv replace;
  run;
%mend;

/* Build length statements from spec (TARGET_VAR, TYPE, LENGTH) */
%macro _build_lengths(spec=);
  proc sql noprint;
    select cats(
      case 
        when upcase(type)='CHAR' then 'length '||strip(target_var)||' $'||strip(length)||';'
        when upcase(type)='NUM'  then 'length '||strip(target_var)||' '||strip(length)||';'
        else '' end
    )
    into :lenstmts separated by ' '
    from &spec.;
  quit;
%mend;

/* Apply spec: assign variables using SOURCE_EXPR */
%macro apply_spec(source=, spec=, out=);
  %_build_lengths(spec=&spec.);
  data &out.;
    set &source.;
    &lenstmts.;
    /* Collect assignment statements */
    %local n;
    data _null_;
      set &spec. end=last;
      call symputx(cats('t', _n_), target_var, 'L');
      call symputx(cats('e', _n_), source_expr, 'L');
      if last then call symputx('nobs', _n_);
    run;
    %do i=1 %to &nobs.;
      %let t = &&t&i.;
      %let e = &&e&i.;
      &t. = &&e&i.;
    %end;
  run;
%mend;

%macro iso2date(var);
  if not missing(&var) then &var._dt = input(&var., yymmdd10.);
  format &var._dt yymmdd10.;
%mend;

%macro check_keys(ds=, keys=);
  proc sort data=&ds. out=_chk nodupkey;
    by &keys.;
  run;
  %let nobs1 = %sysfunc(attrn(%sysfunc(open(&ds.)), nobs));
  %let nobs2 = %sysfunc(attrn(%sysfunc(open(_chk)), nobs));
  %put NOTE: &ds. observations=&nobs1., unique by (&keys.)=&nobs2.;
%mend;
