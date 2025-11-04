/*-----------------------------------------------------------------------------
Program:     ADaM/derivations/advs.sas
Purpose:     Derive ADVS from SDTM with traceability and QC hooks
Inputs:      SDTM.* , ADSL (where applicable)
Outputs:     ADaM.ADVS (plus /logs and /reports outputs)
Traceability:
  - Source SDTM domains: VS, DM
  - Derivations documented in metadata/advs_meta.md
  - Spec version: metadata/spec/adam_spec.csv (SpecID=YYYYMMDD)
Owner:       Clinical Programmer   Version: 0.1.0   Last updated: 2024-06-08
-----------------------------------------------------------------------------*/
%include "../macros/_setup.sas";
%audit_start(domain=ADVS, program=%sysfunc(getoption(sysin)));

%assert(%sysfunc(exist(SDTM.VS)), msg=SDTM.VS missing, level=ERROR);

proc import datafile="../metadata/codelists.csv" out=work._codelists dbms=csv replace;
  guessingrows=max;
run;

proc sql;
  create table work._unit_map as
  select strip(VALUE) as VSORRESU length=200,
         strip(STANDARD_VALUE) as VSSTDU length=200
  from work._codelists
  where upcase(DOMAIN)="ADVS" and upcase(VARIABLE)="VSORRESU";
quit;

proc sql;
  create table work._vs_bds as
  select a.USUBJID,
         a.VSTESTCD as PARAMCD,
         a.VSTEST as PARAM,
         inputn(cats(a.VISITNUM),'best.') as AVISITN,
         coalescec(a.VISIT,'') as AVISIT,
         input(a.VSDTC, yymmdd10.) as ADT format=date9.,
         a.VSORRES as AVALC,
         inputn(cats(a.VSSTRESN),'best.') as AVAL,
         coalescec(a.VSORRESU,'') as ORRESU,
         coalescec(a.VSSTRESU,'') as STRESU,
         coalescec(u.VSSTDU, a.VSSTRESU) as UNIT length=200
  from SDTM.VS a
  left join work._unit_map u
    on upcase(a.VSORRESU)=upcase(u.VSORRESU);
quit;

%baseline_bds(in=work._vs_bds, out=work._vs_with_base);

data ADaM.ADVS;
  set work._vs_with_base;
run;

%qcflags(in=ADaM.ADVS, out=ADaM.ADVS_QC);

proc datasets lib=work nolist;
  delete _codelists _unit_map _vs_bds _vs_with_base;
quit;

%export_xpt(data=ADaM.ADVS, outpath="../exports");
%specdiff(domain=ADVS, spec=../metadata/spec/adam_spec.csv, out=../reports/specdiff/ADVS_specdiff.csv);
%audit_end(domain=ADVS);
