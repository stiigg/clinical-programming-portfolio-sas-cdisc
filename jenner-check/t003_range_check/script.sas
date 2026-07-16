/* jenner-check bundle: macros/qc_compare.sas (%range_check)
   from stiigg/clinical-programming-portfolio-sas-cdisc
   Caller exercises the repo's %range_check QC macro against a 20-row
   inline sample shaped exactly like data/raw/vs.csv (systolic/diastolic
   BP readings, same columns/values as the repo's actual raw VS extract).
   %range_check itself is copied verbatim; only the source of VS data
   is switched from a proc import to an equivalent inline DATALINES
   step, since the runner uploads source only, no data files. */

/* sample shaped like data/raw/vs.csv */
data vs;
  length USUBJID $10 VSTEST $10 VSDTC $10 VSSTRESU $5;
  infile datalines dsd firstobs=2;
  input USUBJID $ VSTEST $ VSORRES VSDTC $ VSSTRESU $;
  datalines;
USUBJID,VSTEST,VSORRES,VSDTC,VSSTRESU
S001,SYSBP,140,2025-04-16,mmHg
S001,DIABP,79,2025-04-05,mmHg
S002,SYSBP,123,2025-04-24,mmHg
S002,DIABP,60,2025-04-21,mmHg
S003,SYSBP,124,2025-04-20,mmHg
S003,DIABP,83,2025-04-12,mmHg
S004,SYSBP,115,2025-04-17,mmHg
S004,DIABP,64,2025-04-16,mmHg
S005,SYSBP,104,2025-04-18,mmHg
S005,DIABP,82,2025-04-03,mmHg
S006,SYSBP,137,2025-04-12,mmHg
S006,DIABP,87,2025-04-02,mmHg
S007,SYSBP,108,2025-04-14,mmHg
S007,DIABP,66,2025-04-09,mmHg
S008,SYSBP,133,2025-04-04,mmHg
S008,DIABP,83,2025-04-03,mmHg
S009,SYSBP,108,2025-04-16,mmHg
S009,DIABP,87,2025-04-05,mmHg
S010,SYSBP,114,2025-04-25,mmHg
S010,DIABP,94,2025-04-16,mmHg
;
run;

data vs_sysbp;
  set vs;
  where VSTEST = 'SYSBP';
run;

/* ---- macros/qc_compare.sas (%range_check, verbatim) ---- */
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

/* flag systolic BP readings outside a normal 90-135 mmHg window */
%range_check(ds=vs_sysbp, var=VSORRES, low=90, high=135);
