
/* qc_macros.sas */
%macro compare(ds1=, ds2=, id=USUBJID);
  proc sort data=&ds1.; by &id.; run;
  proc sort data=&ds2.; by &id.; run;
  proc compare base=&ds1. compare=&ds2. listall criterion=1e-8;
    id &id.;
  run;
%mend;

%macro freqcheck(ds=, var=);
  proc freq data=&ds.;
    tables &var. / missing;
  run;
%mend;

%macro rangecheck(ds=, var=, low=., high=.);
  data _chk;
    set &ds.;
    if not missing(&var.) then do;
      if (&low ne . and &var. < &low) or (&high ne . and &var. > &high) then output;
    end;
  run;
  proc print data=_chk(obs=20);
    title "Out-of-range checks for &var.";
  run;
%mend;
