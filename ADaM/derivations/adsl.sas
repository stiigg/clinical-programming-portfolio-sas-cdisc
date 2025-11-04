/*-----------------------------------------------------------------------------
Program:     ADaM/derivations/adsl.sas
Purpose:     Derive ADSL from SDTM with traceability and QC hooks
Inputs:      SDTM.* , ADSL (where applicable)
Outputs:     ADaM.ADSL (plus /logs and /reports outputs)
Traceability:
  - Source SDTM domains: DM, EX
  - Derivations documented in metadata/adsl_meta.md
  - Spec version: metadata/spec/adam_spec.csv (SpecID=YYYYMMDD)
Owner:       Clinical Programmer   Version: 0.1.0   Last updated: 2024-06-08
-----------------------------------------------------------------------------*/
%include "../macros/_setup.sas";
%audit_start(domain=ADSL, program=%sysfunc(getoption(sysin)));

%assert(%sysfunc(exist(SDTM.DM)), msg=SDTM.DM missing, level=ERROR);

%if %sysfunc(exist(SDTM.EX)) %then %do;
  %mergecheck(base=SDTM.DM, add=SDTM.EX, by=USUBJID, allow_many=YES);

  proc sql;
    create table work._ex as
    select USUBJID,
           input(min(EXSTDTC), yymmdd10.) as TRTSDT format=date9.,
           input(max(EXENDTC), yymmdd10.) as TRTENDT format=date9.
    from SDTM.EX
    group by USUBJID;
  quit;
%end;
%else %do;
  data work._ex;
    length USUBJID $200 TRTSDT TRTENDT 8;
    stop;
  run;
%end;

proc sql;
  create table ADaM.ADSL as
  select d.USUBJID,
         d.STUDYID,
         d.ARMCD,
         d.ARM,
         input(d.RFSTDTC, yymmdd10.) as TRTSDT format=date9.,
         input(d.RFENDTC, yymmdd10.) as TRTEDT format=date9.,
         input(d.RFXSTDTC, yymmdd10.) as RANDDT format=date9.,
         coalescec(d.PPWHY,'') as PPWHY length=200,
         coalesce(x.TRTSDT, input(d.RFSTDTC, yymmdd10.)) as TRTSDT_FINAL format=date9.,
         coalesce(x.TRTENDT, input(d.RFENDTC, yymmdd10.)) as TRTENDT_FINAL format=date9.
  from SDTM.DM d
  left join work._ex x
    on d.USUBJID=x.USUBJID;
quit;

proc datasets lib=work nolist;
  delete _ex;
quit;

%popflags(in=ADaM.ADSL, out=ADaM.ADSL);

%qcflags(in=ADaM.ADSL, out=ADaM.ADSL_QC);

proc freq data=ADaM.ADSL_QC;
  tables QC_MISSKEY*QC_FLAG / missing;
run;

%export_xpt(data=ADaM.ADSL, outpath="../exports");
%specdiff(domain=ADSL, spec=../metadata/spec/adam_spec.csv, out=../reports/specdiff/ADSL_specdiff.csv);
%audit_end(domain=ADSL);
