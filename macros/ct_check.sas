/* ct_check.sas
   Controlled terminology checker for ADaM datasets. */

%macro ct_check(adam_dataset=, ct_spec_file=, out=qc.ct_issues);
  %local lib mem ct_vars nvars;
  %if %length(&adam_dataset.)=0 %then %do;
    %put ERROR: adam_dataset must be provided.;
    %return;
  %end;
  %if %length(&ct_spec_file.)=0 %then %let ct_spec_file=&reference_dir./ct_evs.csv;

  %let lib=%upcase(%scan(&adam_dataset., 1, .));
  %let mem=%upcase(%scan(&adam_dataset., 2, .));

  %if %length(&mem)=0 %then %do;
    %let mem=&lib.;
    %let lib=WORK;
  %end;

  %if %sysfunc(exist(&lib..&mem.))=0 %then %do;
    %put WARNING: Dataset &adam_dataset. does not exist. Skipping CT check.;
    %return;
  %end;

  %local ct_ext;
  %let ct_ext=%upcase(%scan(&ct_spec_file., -1, .));
  %if &ct_ext = XLSX %then %do;
    proc import datafile="&ct_spec_file." out=_ct_spec dbms=xlsx replace;
      sheet='ControlledTerms';
    run;
  %end;
  %else %do;
    proc import datafile="&ct_spec_file." out=_ct_spec dbms=csv replace;
      guessingrows=max;
    run;
  %end;

  proc sql noprint;
    select distinct strip(variable) into :ct_vars separated by ' '
    from _ct_spec;
  quit;

  %let nvars=%sysfunc(countw(&ct_vars));

  %if &nvars = 0 %then %do;
    %put NOTE: No controlled terminology entries found in &ct_spec_file.;
    %return;
  %end;

  %do i=1 %to &nvars.;
    %let var=%scan(&ct_vars., &i.);
    proc sql;
      create table _ct_values_&i as
      select "&var." as variable length=32,
             strip(&var.) as value length=200
      from &adam_dataset.
      where not missing(&var.);
    quit;

    proc sort data=_ct_values_&i nodupkey;
      by variable value;
    run;

    proc sql;
      create table _ct_missing_&i as
      select a.variable, a.value
      from _ct_values_&i as a
      left join _ct_spec as b
        on upcase(a.variable)=upcase(b.variable)
       and strip(a.value)=strip(b.value)
      where missing(b.value);
    quit;
  %end;

  data &out.;
    set
    %do i=1 %to &nvars.;
      _ct_missing_&i
    %end;
    ;
  run;

  %if %sysfunc(exist(&out.)) %then %do;
    %let dsid=%sysfunc(open(&out.));
    %if &dsid > 0 %then %do;
      %let nobs=%sysfunc(attrn(&dsid, NOBS));
      %let rc=%sysfunc(close(&dsid));
      %if &nobs>0 %then %put WARNING: Controlled terminology issues detected in &adam_dataset.;;
    %end;
  %end;
%mend;
