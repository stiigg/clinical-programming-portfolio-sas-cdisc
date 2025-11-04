/* Validation: ADaM/validation/validate_adae.sas */
%include "../macros/_setup.sas";

%qcflags(in=ADaM.ADAE, out=work._qc_adae);

proc sql noprint;
  select sum(QC_MISSKEY) into :_adae_missing trimmed from work._qc_adae;
quit;

%if %sysevalf(%superq(_adae_missing)=,boolean) %then %let _adae_missing=0;
%assert(%sysevalf(%superq(_adae_missing)=0), msg=ADAE has subjects with missing keys (&_adae_missing), level=ERROR);

proc sql;
  create table work._orphans as
  select distinct a.USUBJID
  from ADaM.ADAE a
  left join ADaM.ADSL b
    on a.USUBJID=b.USUBJID
  where b.USUBJID is null;
quit;

%if %sysfunc(exist(work._orphans)) %then %do;
  data _null_;
    if 0 then set work._orphans nobs=n;
    call symputx('_adae_orphans', n, 'l');
    stop;
  run;
%end;
%else %let _adae_orphans=0;

%assert(%sysevalf(%superq(_adae_orphans)=0), msg=ADAE subjects missing from ADSL (&_adae_orphans), level=ERROR);

proc datasets lib=work nolist;
  delete _qc_adae _orphans;
quit;
