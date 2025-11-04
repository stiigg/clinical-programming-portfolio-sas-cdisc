/*-----------------------------------------------------------------------------
Program:     ADaM/derivations/adlb.sas
Purpose:     Derive ADLB from SDTM with traceability and QC hooks
Inputs:      SDTM.* , ADSL (where applicable)
Outputs:     ADaM.ADLB (plus /logs and /reports outputs)
Traceability:
  - Source SDTM domains: LB, DM
  - Derivations documented in metadata/adlb_meta.md
  - Spec version: metadata/spec/adam_spec.csv (SpecID=YYYYMMDD)
Owner:       Clinical Programmer   Version: 0.1.0   Last updated: 2024-06-08
-----------------------------------------------------------------------------*/
%include "../macros/_setup.sas";
%audit_start(domain=ADLB, program=%sysfunc(getoption(sysin)));

%assert(%sysfunc(exist(SDTM.LB)), msg=SDTM.LB missing, level=ERROR);

proc import datafile="../metadata/codelists.csv" out=work._codelists dbms=csv replace;
  guessingrows=max;
run;

proc sql;
  create table work._unit_map as
  select strip(VALUE) as LBORRESU length=200,
         strip(STANDARD_VALUE) as LBSTDU length=200
  from work._codelists
  where upcase(DOMAIN)="ADLB" and upcase(VARIABLE)="LBORRESU";
quit;

proc sql;
  create table work._lb_bds as
  select a.USUBJID,
         a.LBSEQ,
         a.LBTESTCD as PARAMCD,
         a.LBTEST as PARAM,
         inputn(cats(a.VISITNUM),'best.') as AVISITN,
         coalescec(a.VISIT,'') as AVISIT,
         input(a.LBDTC, yymmdd10.) as ADT format=date9.,
         input(a.LBENDTC, yymmdd10.) as AENDT format=date9.,
         inputn(cats(a.LBSTRESN),'best.') as AVAL,
         coalescec(a.LBSTRESC,'') as AVALC,
         coalescec(a.LBORRESU,'') as ORRESU,
         coalescec(u.LBSTDU, a.LBSTRESU) as UNIT length=200,
         a.LBNRIND,
         (not missing(a.LBSTNRHI) and inputn(cats(a.LBSTRESN),'best.')>inputn(cats(a.LBSTNRHI),'best.')) as HIGHFL,
         (not missing(a.LBSTNRLO) and inputn(cats(a.LBSTRESN),'best.')<inputn(cats(a.LBSTNRLO),'best.')) as LOWFL
  from SDTM.LB a
  left join work._unit_map u
    on upcase(a.LBORRESU)=upcase(u.LBORRESU);
quit;

%baseline_bds(in=work._lb_bds, out=work._lb_with_base);

data ADaM.ADLB;
  set work._lb_with_base;
run;

%qcflags(in=ADaM.ADLB, out=ADaM.ADLB_QC);

proc datasets lib=work nolist;
  delete _codelists _unit_map _lb_bds _lb_with_base;
quit;

%export_xpt(data=ADaM.ADLB, outpath="../exports");
%specdiff(domain=ADLB, spec=../metadata/spec/adam_spec.csv, out=../reports/specdiff/ADLB_specdiff.csv);
%audit_end(domain=ADLB);
