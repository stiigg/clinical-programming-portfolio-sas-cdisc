/* qc_compare.sas
   QC helper macros for independent programming comparisons. */

%macro qc_compare(base=, compare=, id=USUBJID, out=);
  %if %length(&out)=0 %then %let out=work._qc_diff;
  proc sort data=&base. out=_base; by &id.; run;
  proc sort data=&compare. out=_comp; by &id.; run;
  proc compare base=_base compare=_comp listall criterion=1e-8 out=&out. outnoequal;
    id &id.;
  run;
%mend;

%macro freq_check(ds=, var=);
  proc freq data=&ds.;
    tables &var. / missing;
  run;
%mend;

%macro range_check(ds=, var=, low=., high=.);
  data _range_chk;
    set &ds.;
    if not missing(&var.) then do;
      if (&low ne . and &var. < &low) or (&high ne . and &var. > &high) then output;
    end;
  run;
  proc print data=_range_chk(obs=20);
    title "Out-of-range checks for &var.";
  run;
%mend;
