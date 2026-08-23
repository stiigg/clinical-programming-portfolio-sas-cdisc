/* jenner-check bundle: macros/sdtm_domain_dm.sas + macros/sdtm_generic.sas
   from stiigg/clinical-programming-portfolio-sas-cdisc
   Caller exercises the repo's %sdtm_dm macro against a 10-row inline
   sample shaped exactly like data/raw/dm.csv (same columns/values as the
   repo's actual raw DM extract). Macro bodies below are copied verbatim
   from the source files; the only edit is that %sdtm_dm's proc import of
   &raw_dir./dm.csv is replaced with a DATALINES step producing the same
   _dm_raw shape, since the runner uploads source only, no data files. */

libname sdtm "%sysfunc(pathname(work))";

%let studyid = DEMO001;

/* sample shaped like data/raw/dm.csv */
data _dm_raw;
  length USUBJID $10 SUBJID 8 SEX $1 ARMCD $2 ARM $10 AGE 8 RFSTDTC $10 RFENDTC $10;
  infile datalines dsd firstobs=2;
  input USUBJID $ SUBJID SEX $ ARMCD $ ARM $ AGE RFSTDTC $ RFENDTC $;
  datalines;
USUBJID,SUBJID,SEX,ARMCD,ARM,AGE,RFSTDTC,RFENDTC
S001,1,M,B,DRUGA,45,2025-01-12,2025-06-24
S002,2,M,B,PLACEBO,26,2025-01-15,2025-06-27
S003,3,F,B,DRUGA,63,2025-01-14,2025-06-04
S004,4,F,A,DRUGA,41,2025-01-05,2025-06-26
S005,5,F,B,PLACEBO,65,2025-01-15,2025-06-12
S006,6,M,A,PLACEBO,51,2025-01-24,2025-06-02
S007,7,F,B,PLACEBO,55,2025-01-05,2025-06-21
S008,8,F,A,PLACEBO,73,2025-01-13,2025-06-25
S009,9,F,B,DRUGA,32,2025-01-10,2025-06-13
S010,10,M,A,DRUGA,30,2025-01-21,2025-06-19
;
run;

/* ---- macros/qc_compare.sas (freq_check only, used by sdtm_standard_checks) ---- */
%macro freq_check(ds=, var=);
  proc freq data=&ds.;
    tables &var. / missing;
  run;
%mend;

/* ---- macros/sdtm_generic.sas (verbatim) ---- */
%macro sdtm_date_from_iso(var=, out=);
  %if %length(&out)=0 %then %let out=&var.;
  if not missing(&var.) then do;
    &out. = input(&var., yymmdd10.);
    format &out. yymmdd10.;
  end;
%mend;

%macro sdtm_standard_checks(domain=);
  %put NOTE: Running standard SDTM checks for &domain.;
  %freq_check(ds=sdtm.&domain., var=USUBJID);
%mend;

/* ---- macros/sdtm_domain_dm.sas (verbatim body after the proc import,
        which is replaced above by the inline _dm_raw DATALINES step) ---- */
%macro sdtm_dm;
  data sdtm.dm;
    length STUDYID $20 DOMAIN $2 AGEU $5;
    set _dm_raw;
    STUDYID = "&studyid.";
    DOMAIN = 'DM';
    AGEU = 'YEARS';
    %sdtm_date_from_iso(var=RFSTDTC, out=RFSTD);
    %sdtm_date_from_iso(var=RFENDTC, out=RFEND);
  run;

  proc sort data=sdtm.dm;
    by USUBJID;
  run;

  %sdtm_standard_checks(domain=dm);
%mend;

%sdtm_dm;

proc print data=sdtm.dm noobs;
  var USUBJID ARMCD ARM SEX AGE RFSTD RFEND;
  title "SDTM.DM built via the sdtm_dm macro";
run;
