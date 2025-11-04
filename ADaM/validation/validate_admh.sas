/* Validation: ADaM/validation/validate_admh.sas */
%include "../macros/_setup.sas";

%qcflags(in=ADaM.ADMH, out=work._qc_admh);

proc sql noprint;
  select sum(QC_MISSKEY) into :_admh_missing trimmed from work._qc_admh;
quit;

%if %sysevalf(%superq(_admh_missing)=,boolean) %then %let _admh_missing=0;
%assert(%sysevalf(%superq(_admh_missing)=0), msg=ADMH has missing USUBJID (&_admh_missing), level=ERROR);

proc datasets lib=work nolist;
  delete _qc_admh;
quit;
