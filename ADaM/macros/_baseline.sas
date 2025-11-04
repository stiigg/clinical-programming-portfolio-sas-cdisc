/*-----------------------------------------------------------------------------
Macro:       %baseline_bds
Purpose:     Calculate baseline and change values for BDS structures
-----------------------------------------------------------------------------*/
%macro baseline_bds(in=, out=, parm=, visitbase=BASELINE);
  %if %superq(in)= %then %do;
    %put ERROR: baseline_bds requires IN= dataset.;
    %return;
  %end;
  %if %superq(out)= %then %let out=&in;

  %if %superq(parm) ne %then %do;
    data _baseline_subset;
      set &in;
      where upcase(PARAMCD)=upcase("&parm");
    run;
    %let _source=_baseline_subset;
  %end;
  %else %let _source=&in;

  proc sort data=&_source out=_baseline_sorted;
    by USUBJID PARAMCD AVISITN;
  run;

  data &out;
    set _baseline_sorted;
    by USUBJID PARAMCD AVISITN;
    retain BASE AVALB;
    if first.PARAMCD then call missing(BASE, AVALB);
    if upcase(AVISIT)=upcase("&visitbase") then do;
      BASE=AVAL;
      AVALB=AVAL;
    end;
    if not missing(BASE) then CHG = AVAL - BASE;
    else CHG = .;
  run;

  proc datasets lib=work nolist;
    delete _baseline_subset _baseline_sorted;
  quit;
%mend baseline_bds;
