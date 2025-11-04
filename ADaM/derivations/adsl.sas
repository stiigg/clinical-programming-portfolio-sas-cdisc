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
  create table work._adsl_pre as
  select d.USUBJID,
         d.STUDYID,
         d.SITEID,
         d.SUBJID,
         d.ARMCD,
         d.ARM,
         d.SEX,
         d.RACE,
         d.ETHNIC,
         d.COUNTRY,
         d.AGE as AGE_REPORTED,
         input(d.BRTHDTC, yymmdd10.) as BRTHDT format=date9.,
         input(d.RFSTDTC, yymmdd10.) as DM_TRFSTD format=date9.,
         input(d.RFENDTC, yymmdd10.) as DM_TRFEND format=date9.,
         input(d.RFXSTDTC, yymmdd10.) as RANDDT_RAW format=date9.,
         coalescec(d.PPWHY,'') as PPWHY length=200,
         x.TRTSDT as EX_TRTSDT,
         x.TRTENDT as EX_TRTENDT
  from SDTM.DM d
  left join work._ex x
    on d.USUBJID=x.USUBJID;
quit;

data ADaM.ADSL;
  set work._adsl_pre;
  length AGEU $5 AGEGR1 $20 TRTSDT_SRC TRTEDT_SRC RANDDT_SRC $20
         TRTSDT_IMPFL TRTEDT_IMPFL $1 EFFFL PPSFL $1;
  format TRTSDT TRTEDT RANDDT date9.;
  label STUDYID    = 'Study Identifier'
        SITEID     = 'Study Site Identifier'
        SUBJID     = 'Subject Identifier for the Study'
        ARMCD      = 'Planned Arm Code'
        ARM        = 'Description of Planned Arm'
        TRTSDT     = 'Date of First Exposure to Treatment'
        TRTEDT     = 'Date of Last Exposure to Treatment'
        RANDDT     = 'Date of Randomization'
        TRTSDT_SRC = 'Source variable for TRTSDT'
        TRTSDT_IMPFL = 'Imputation flag for TRTSDT'
        TRTEDT_SRC = 'Source variable for TRTEDT'
        TRTEDT_IMPFL = 'Imputation flag for TRTEDT'
        RANDDT_SRC = 'Source variable for RANDDT'
        EFFFL      = 'Efficacy Population Flag'
        PPSFL      = 'Per-Protocol Population Flag'
        PPWHY      = 'Reason Not in Per-Protocol Population'
        AGE        = 'Age at Treatment Start'
        AGEU       = 'Age Units'
        AGEGR1     = 'Age Group 1'
        SEX        = 'Sex'
        RACE       = 'Race'
        ETHNIC     = 'Ethnicity'
        COUNTRY    = 'Country';

  TRTSDT = coalesce(EX_TRTSDT, DM_TRFSTD);
  TRTEDT = coalesce(EX_TRTENDT, DM_TRFEND);
  TRTSDT_SRC = ifc(not missing(EX_TRTSDT), 'SDTM.EX.EXSTDTC', ifc(not missing(DM_TRFSTD), 'SDTM.DM.RFSTDTC', ''));
  TRTSDT_IMPFL = ifc(missing(EX_TRTSDT) and not missing(DM_TRFSTD), 'Y', ifc(not missing(TRTSDT), 'N', ''));
  TRTEDT_SRC = ifc(not missing(EX_TRTENDT), 'SDTM.EX.EXENDTC', ifc(not missing(DM_TRFEND), 'SDTM.DM.RFENDTC', ''));
  TRTEDT_IMPFL = ifc(missing(EX_TRTENDT) and not missing(DM_TRFEND), 'Y', ifc(not missing(TRTEDT), 'N', ''));

  RANDDT = RANDDT_RAW;
  RANDDT_SRC = ifc(not missing(RANDDT), 'SDTM.DM.RFXSTDTC', '');

  if not missing(BRTHDT) then do;
    age_base_date = coalesce(TRTSDT, RANDDT);
    if not missing(age_base_date) then do;
      age_calc = int(intck('day', BRTHDT, age_base_date) / 365.25);
      if age_calc >= 0 then AGE = age_calc;
    end;
  end;
  if missing(AGE) and not missing(AGE_REPORTED) then AGE = floor(AGE_REPORTED);
  if not missing(AGE) then AGEU = 'YEARS';

  if not missing(AGE) then do;
    if AGE < 18 then AGEGR1 = '<18';
    else if 18 <= AGE < 65 then AGEGR1 = '18-64';
    else if 65 <= AGE < 75 then AGEGR1 = '65-74';
    else AGEGR1 = '75+';
  end;

  EFFFL = ifc(not missing(RANDDT), 'Y', 'N');

  if missing(PPWHY) then PPSFL = 'Y';
  else PPSFL = 'N';

  drop EX_TRTSDT EX_TRTENDT DM_TRFSTD DM_TRFEND RANDDT_RAW AGE_REPORTED BRTHDT age_base_date age_calc;
run;

proc sort data=ADaM.ADSL;
  by STUDYID USUBJID;
run;

proc datasets lib=work nolist;
  delete _ex _adsl_pre;
quit;

%popflags(in=ADaM.ADSL, out=ADaM.ADSL);

data ADaM.ADSL;
  set ADaM.ADSL;
  length PPSFL $1;
  if missing(PPSFL) then PPSFL = ifc(PPFL='Y','Y','N');
  if PPFL='Y' and missing(PPWHY) then PPWHY='';
  if missing(EFFFL) then EFFFL = ifc(ITTFL='Y','Y','N');
run;

%qcflags(in=ADaM.ADSL, out=ADaM.ADSL_QC);

proc freq data=ADaM.ADSL_QC;
  tables QC_MISSKEY*QC_FLAG / missing;
run;

%export_xpt(data=ADaM.ADSL, outpath="../exports");
%specdiff(domain=ADSL, spec=../metadata/spec/adam_spec.csv, out=../reports/specdiff/ADSL_specdiff.csv);
%audit_end(domain=ADSL);
