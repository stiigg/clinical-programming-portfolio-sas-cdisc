/* jenner-check bundle: macros/qc_compare.sas (%qc_compare)
   from stiigg/clinical-programming-portfolio-sas-cdisc
   Caller exercises the repo's %qc_compare macro -- the independent
   programming / dual-programmer reconciliation pattern the portfolio's
   validation/ layer relies on (validation/adam_qc_main.sas and
   validation/sdtm_qc_main.sas both run production vs. QC datasets
   through the same PROC COMPARE shape). Here it's run on two small
   DM-shaped datasets, one a QC re-derivation of the other with a
   deliberately altered AGE for one subject, so the diff is genuine.
   %qc_compare is copied verbatim. */

data base_dm;
  length USUBJID $10 ARMCD $2 SEX $1 AGE 8;
  input USUBJID $ ARMCD $ SEX $ AGE;
  datalines;
S001 B M 45
S002 B M 26
S003 B F 63
S004 A F 41
S005 B F 65
;
run;

/* QC re-derivation: independent program, one transcription slip on S003 */
data qc_dm;
  length USUBJID $10 ARMCD $2 SEX $1 AGE 8;
  input USUBJID $ ARMCD $ SEX $ AGE;
  datalines;
S001 B M 45
S002 B M 26
S003 B F 36
S004 A F 41
S005 B F 65
;
run;

/* ---- macros/qc_compare.sas (%qc_compare, verbatim) ---- */
%macro qc_compare(base=, compare=, id=USUBJID, out=);
  %if %length(&out)=0 %then %let out=work._qc_diff;
  proc sort data=&base. out=_base; by &id.; run;
  proc sort data=&compare. out=_comp; by &id.; run;
  proc compare base=_base compare=_comp listall criterion=1e-8 out=&out. outnoequal;
    id &id.;
  run;
%mend;

%qc_compare(base=base_dm, compare=qc_dm, id=USUBJID, out=work.dm_diffs);

proc print data=work.dm_diffs noobs;
  title 'qc_compare: base_dm vs qc_dm diffs';
run;
