/*-----------------------------------------------------------------------------
Program:     ADaM/derivations/admh.sas
Purpose:     Derive ADMH from SDTM with traceability and QC hooks
Inputs:      SDTM.* , ADSL (where applicable)
Outputs:     ADaM.ADMH (plus /logs and /reports outputs)
Traceability:
  - Source SDTM domains: MH, DM
  - Derivations documented in metadata/admh_meta.md
  - Spec version: metadata/spec/adam_spec.csv (SpecID=YYYYMMDD)
Owner:       Clinical Programmer   Version: 0.1.0   Last updated: 2024-06-08
-----------------------------------------------------------------------------*/
%include "../macros/_setup.sas";
%audit_start(domain=ADMH, program=%sysfunc(getoption(sysin)));

%assert(%sysfunc(exist(SDTM.MH)), msg=SDTM.MH missing, level=ERROR);

proc import datafile="../metadata/codelists.csv" out=work._codelists dbms=csv replace;
  guessingrows=max;
run;

proc sql;
  create table work._cat_map as
  select strip(VALUE) as MHCAT length=200,
         strip(STANDARD_VALUE) as CAT_FLAG length=200
  from work._codelists
  where upcase(DOMAIN)="ADMH" and upcase(VARIABLE)="MHCAT";
quit;

proc sql;
  create table work._admh as
  select a.USUBJID,
         a.MHSEQ as SRCSEQ,
         a.MHCAT,
         a.MHTERM,
         a.MHDECOD,
         coalescec(c.CAT_FLAG,'N') as CATFL,
         input(a.MHSTDTC, yymmdd10.) as MHSTDAT format=date9.,
         input(a.MHENDTC, yymmdd10.) as MHENDAT format=date9.
  from SDTM.MH a
  left join work._cat_map c
    on upcase(a.MHCAT)=upcase(c.MHCAT);
quit;

data ADaM.ADMH;
  set work._admh;
run;

%qcflags(in=ADaM.ADMH, out=ADaM.ADMH_QC);

proc datasets lib=work nolist;
  delete _codelists _cat_map _admh;
quit;

%export_xpt(data=ADaM.ADMH, outpath="../exports");
%specdiff(domain=ADMH, spec=../metadata/spec/adam_spec.csv, out=../reports/specdiff/ADMH_specdiff.csv);
%audit_end(domain=ADMH);
