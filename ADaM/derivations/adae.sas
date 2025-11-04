/*-----------------------------------------------------------------------------
Program:     ADaM/derivations/adae.sas
Purpose:     Derive ADAE from SDTM with traceability and QC hooks
Inputs:      SDTM.* , ADSL (where applicable)
Outputs:     ADaM.ADAE (plus /logs and /reports outputs)
Traceability:
  - Source SDTM domains: AE, DM
  - Derivations documented in metadata/adae_meta.md
  - Spec version: metadata/spec/adam_spec.csv (SpecID=YYYYMMDD)
Owner:       Clinical Programmer   Version: 0.1.0   Last updated: 2024-06-08
-----------------------------------------------------------------------------*/
%include "../macros/_setup.sas";
%audit_start(domain=ADAE, program=%sysfunc(getoption(sysin)));

%assert(%sysfunc(exist(SDTM.AE)), msg=SDTM.AE missing, level=ERROR);
%assert(%sysfunc(exist(ADaM.ADSL)), msg=ADaM.ADSL missing. Run ADSL first., level=ERROR);

%mergecheck(base=SDTM.AE, add=ADaM.ADSL, by=USUBJID, allow_many=YES);

proc import datafile="../metadata/codelists.csv" out=work._codelists dbms=csv replace;
  guessingrows=max;
run;

proc sql;
  create table work._sev_map as
  select strip(VALUE) as AESEV length=200,
         strip(STANDARD_VALUE) as AESEV_STD length=200
  from work._codelists
  where upcase(DOMAIN)="ADAE" and upcase(VARIABLE)="AESEV";

  create table work._ser_map as
  select strip(VALUE) as AESER length=200,
         strip(STANDARD_VALUE) as AESER_STD length=200
  from work._codelists
  where upcase(DOMAIN)="ADAE" and upcase(VARIABLE)="AESER";
quit;

proc sql;
  create table work._adae_base as
  select a.USUBJID,
         a.AESEQ,
         a.AETERM,
         a.AEDECOD,
         a.AESEV,
         coalescec(s.AESEV_STD, a.AESEV) as AESEV_STD length=200,
         a.AESER,
         coalescec(r.AESER_STD, a.AESER) as AESER_STD length=200,
         input(a.AESTDTC, yymmdd10.) as ASTDT format=date9.,
         input(a.AEENDTC, yymmdd10.) as AENDT format=date9.,
         b.TRTSDT_FINAL,
         b.SAFFL
  from SDTM.AE a
  left join ADaM.ADSL b
    on a.USUBJID=b.USUBJID
  left join work._sev_map s
    on upcase(a.AESEV)=upcase(s.AESEV)
  left join work._ser_map r
    on upcase(a.AESER)=upcase(r.AESER);
quit;

data ADaM.ADAE;
  set work._adae_base;
run;

%qcflags(in=ADaM.ADAE, out=ADaM.ADAE_QC);

proc datasets lib=work nolist;
  delete _codelists _sev_map _ser_map _adae_base;
quit;

%export_xpt(data=ADaM.ADAE, outpath="../exports");
%specdiff(domain=ADAE, spec=../metadata/spec/adam_spec.csv, out=../reports/specdiff/ADAE_specdiff.csv);
%audit_end(domain=ADAE);
