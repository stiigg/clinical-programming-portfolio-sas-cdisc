/*-----------------------------------------------------------------------------
Program:     ADaM/derivations/adtte.sas
Purpose:     Derive ADTTE from SDTM with traceability and QC hooks
Inputs:      SDTM.* , ADSL (where applicable)
Outputs:     ADaM.ADTTE (plus /logs and /reports outputs)
Traceability:
  - Source SDTM domains: DS, AE, DM
  - Derivations documented in metadata/adtte_meta.md
  - Spec version: metadata/spec/adam_spec.csv (SpecID=YYYYMMDD)
Owner:       Clinical Programmer   Version: 0.1.0   Last updated: 2024-06-08
-----------------------------------------------------------------------------*/
%include "../macros/_setup.sas";
%audit_start(domain=ADTTE, program=%sysfunc(getoption(sysin)));

%assert(%sysfunc(exist(ADaM.ADSL)), msg=ADaM.ADSL missing. Run ADSL first., level=ERROR);
%assert(%sysfunc(exist(SDTM.DS)), msg=SDTM.DS missing, level=ERROR);

proc sql;
  create table work._death as
  select USUBJID,
         input(DSSTDTC, yymmdd10.) as EVENTDT format=date9.,
         DSDECOD
  from SDTM.DS
  where upcase(DSDECOD) in ("DEATH","PROGRESSION");
quit;

proc sql;
  create table work._tte as
  select a.USUBJID,
         a.TRTSDT_FINAL as TRTSDT format=date9.,
         b.EVENTDT,
         b.DSDECOD
  from ADaM.ADSL a
  left join work._death b
    on a.USUBJID=b.USUBJID;
quit;

data ADaM.ADTTE;
  set work._tte;
  length CNSR 8 AVALC $200;
  if not missing(EVENTDT) then do;
    CNSR=0;
    ADT=EVENTDT;
    AVAL = EVENTDT - TRTSDT + 1;
    AVALC=DSDECOD;
  end;
  else do;
    CNSR=1;
    ADT=TRTSDT;
    AVAL=0;
    AVALC='CENSORED';
  end;
  ASEQ=_N_;
run;

%qcflags(in=ADaM.ADTTE, out=ADaM.ADTTE_QC);

proc datasets lib=work nolist;
  delete _death _tte;
quit;

%export_xpt(data=ADaM.ADTTE, outpath="../exports");
%specdiff(domain=ADTTE, spec=../metadata/spec/adam_spec.csv, out=../reports/specdiff/ADTTE_specdiff.csv);
%audit_end(domain=ADTTE);
