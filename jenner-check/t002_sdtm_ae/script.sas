/* jenner-check bundle: macros/sdtm_domain_ae.sas + macros/sdtm_generic.sas
   from stiigg/clinical-programming-portfolio-sas-cdisc
   Caller exercises the repo's %sdtm_ae macro against an 11-row inline
   sample shaped exactly like data/raw/ae.csv (same columns/values as the
   repo's actual raw AE extract). Macro bodies below are copied verbatim
   from the source files; the only edit is that %sdtm_ae's proc import of
   &raw_dir./ae.csv is replaced with an equivalent DATALINES step, since
   the runner uploads source only, no data files. */

libname sdtm "%sysfunc(pathname(work))";

%let studyid = DEMO001;
%let spec_dir = %sysfunc(pathname(work));   /* &mapping_file. is put-only in this macro, not read */

/* sample shaped like data/raw/ae.csv */
data _ae_raw;
  length USUBJID $10 AETERM $20 AESTDTC $10 AEENDTC $10 AESEV $10 AESER $1 REL $20;
  infile datalines dsd firstobs=2;
  input USUBJID $ AETERM $ AESTDTC $ AEENDTC $ AESEV $ AESER $ REL $;
  datalines;
USUBJID,AETERM,AESTDTC,AEENDTC,AESEV,AESER,REL
S001,DIZZINESS,2025-02-10,2025-02-27,MODERATE,Y,POSSIBLY RELATED
S001,NAUSEA,2025-02-03,2025-02-13,SEVERE,Y,NOT RELATED
S003,NAUSEA,2025-02-09,2025-02-07,MODERATE,N,POSSIBLY RELATED
S003,NAUSEA,2025-02-05,2025-02-23,MODERATE,N,RELATED
S005,FATIGUE,2025-02-12,2025-02-22,SEVERE,Y,POSSIBLY RELATED
S005,NAUSEA,2025-02-07,2025-02-19,MODERATE,Y,POSSIBLY RELATED
S007,HEADACHE,2025-02-22,2025-02-22,SEVERE,N,NOT RELATED
S007,DIZZINESS,2025-02-08,2025-02-22,MODERATE,Y,NOT RELATED
S008,HEADACHE,2025-02-04,2025-02-07,MILD,Y,POSSIBLY RELATED
S009,NAUSEA,2025-02-24,2025-02-16,MILD,N,NOT RELATED
S010,DIZZINESS,2025-02-15,2025-02-03,MODERATE,N,RELATED
;
run;

/* ---- macros/qc_compare.sas (freq_check only, used by sdtm_standard_checks) ---- */
%macro freq_check(ds=, var=);
  proc freq data=&ds.;
    tables &var. / missing;
  run;
%mend;

/* ---- macros/sdtm_generic.sas (verbatim, the parts sdtm_ae depends on) ---- */
%macro sdtm_standard_checks(domain=);
  %put NOTE: Running standard SDTM checks for &domain.;
  %freq_check(ds=sdtm.&domain., var=USUBJID);
%mend;

/* ---- macros/sdtm_domain_ae.sas (verbatim body after the proc import,
        which is replaced above by the inline _ae_raw DATALINES step) ---- */
%macro sdtm_ae;
  %local mapping_file;
  %let mapping_file=&spec_dir./sdtm_mapping.csv;
  %put NOTE: Building AE domain using &mapping_file.;

  data sdtm.ae;
    length STUDYID $20 DOMAIN $2 AESCAT $40;
    set _ae_raw;
    STUDYID = "&studyid.";
    DOMAIN = 'AE';
    AESCAT = 'TREATMENT EMERGENT';
  run;

  proc sort data=sdtm.ae;
    by USUBJID AETERM AESTDTC;
  run;

  %sdtm_standard_checks(domain=ae);
%mend;

%sdtm_ae;

proc print data=sdtm.ae noobs label;
  var USUBJID AETERM AESEV AESER REL AESTDTC AEENDTC;
  title 'SDTM.AE built via the sdtm_ae macro';
run;
