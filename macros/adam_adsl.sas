/* adam_adsl.sas */

%macro adam_adsl;
  %put NOTE: Deriving ADaM ADSL from SDTM DM with SCLC extensions.;
  proc sql;
    create table adam.adsl as
    select d.USUBJID,
           d.STUDYID,
           '' as SITEID length=12,
           d.SUBJID,
           d.ARMCD,
           d.ARM,
           d.SEX,
           d.AGE,
           d.AGEU,
           calculated TRTSDT format=date9.,
           calculated TRTEDT format=date9.,
           calculated RANDDT format=date9.
    from (
      select *,
             input(RFSTDTC, yymmdd10.) as TRTSDT,
             input(RFENDTC, yymmdd10.) as TRTEDT,
             input(RANDDTC, yymmdd10.) as RANDDT
      from sdtm.dm
    ) as d;
  quit;

  data adam.adsl;
    set adam.adsl;
    length STGGRP $3 SCLC_SUBTYPE $12 CNSBLFL DLL3POS IOPRIOR TARLAT_ELIG $1;
    length DT2L_START 8;
    format DT2L_START date9.;
    DT2L_START = TRTEDT;

    if upcase(substr(ARMCD, 1, 2)) = 'LS' then STGGRP='LS';
    else if not missing(ARMCD) then STGGRP='ES';

    if index(upcase(coalescec(ARM, '')), 'CNS') > 0 then CNSBLFL='Y';
    else CNSBLFL='N';

    if index(upcase(coalescec(ARM, '')), 'DLL3') > 0 then DLL3POS='Y';
    else DLL3POS='N';

    if index(upcase(coalescec(ARM, '')), 'IO') > 0 then IOPRIOR='Y';
    else IOPRIOR='N';

    if missing(SCLC_SUBTYPE) then SCLC_SUBTYPE='OTHER';

    if DLL3POS='Y' and IOPRIOR='N' then TARLAT_ELIG='Y';
    else TARLAT_ELIG='N';
  run;

  %derive_pop_flags(adsl_in=adam.adsl, adsl_out=adam.adsl);

  proc sort data=adam.adsl;
    by USUBJID;
  run;

  %qc_compare(base=adam.adsl, compare=adam.adsl, id=USUBJID, out=qc.adsl_self);
%mend;
