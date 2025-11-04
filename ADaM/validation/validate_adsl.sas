/* Validation: ADaM/validation/validate_adsl.sas */
%include "../macros/_setup.sas";

%qcflags(in=ADaM.ADSL, out=work._qc_adsl);

proc sql noprint;
  select sum(QC_FLAG) into :_adsl_flags trimmed from work._qc_adsl;
quit;

%if %sysevalf(%superq(_adsl_flags)=,boolean) %then %let _adsl_flags=0;
%assert(%sysevalf(%superq(_adsl_flags)=0), msg=ADSL has QC flag issues (&_adsl_flags observations), level=ERROR);

proc datasets lib=work nolist;
  delete _qc_adsl;
quit;
