/* etl/etl_tlf.sas */
%macro _ensure_run_set;
  %global RUN_SET;
  %if %sysevalf(%superq(RUN_SET)=, boolean) %then %let RUN_SET=&RUN.;
  %put NOTE: [TLF] RUN_SET resolved to &RUN_SET.;
%mend _ensure_run_set;

%_ensure_run_set;

%if %sysfunc(fileexist("&PROJECTROOT./specs/spec_tlf.csv")) %then %do;
  proc import datafile="&PROJECTROOT./specs/spec_tlf.csv"
    out=work.meta_tlf dbms=csv replace;
    guessingrows=max;
  run;
%end;
%else %do;
  data work.meta_tlf;
    length OUTID RUN_SET ANALYSIS_TYPE DATASET PARAMCD POPULATION SUBGRP_ID LAYOUT_ID $64 TIER 8;
    stop;
  run;
%end;

data work.tlf_runlist;
  set work.meta_tlf;
  where upcase(RUN_SET) = upcase("&RUN_SET.");
  length DATASET $32 POPULATION $32 SUBGRP_ID $64;
  if missing(DATASET) then DATASET='ADTTE';
  if missing(POPULATION) then POPULATION='ITT';
  if missing(TIER) then TIER=3;
run;

proc sort data=work.tlf_runlist;
  by TIER OUTID;
run;
