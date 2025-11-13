/* adam_adsl.sas */

%macro adam_adsl;
  %put NOTE: Deriving ADaM ADSL from SDTM DM;
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
           calculated TRTEDT format=date9.
    from (
      select *,
             input(RFSTDTC, yymmdd10.) as TRTSDT,
             input(RFENDTC, yymmdd10.) as TRTEDT
      from sdtm.dm
    ) as d;
  quit;

  data adam.adsl;
    set adam.adsl;
    length SAFFL EFFFL PPSFL $1;
    SAFFL = 'Y';
    EFFFL = 'Y';
    PPSFL = 'Y';
  run;

  proc sort data=adam.adsl;
    by USUBJID;
  run;

  %qc_compare(base=adam.adsl, compare=adam.adsl, id=USUBJID, out=qc.adsl_self);
%mend;
