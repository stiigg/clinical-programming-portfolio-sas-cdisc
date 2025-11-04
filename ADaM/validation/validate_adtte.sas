/* Validation: ADaM/validation/validate_adtte.sas */
%include "../macros/_setup.sas";

%qcflags(in=ADaM.ADTTE, out=work._qc_adtte);

proc sql noprint;
  select sum(QC_MISSKEY) into :_adtte_missing trimmed from work._qc_adtte;
  select count(*) into :_adtte_bad_cnsr trimmed
  from ADaM.ADTTE where not (CNSR in (0,1));
quit;

%if %sysevalf(%superq(_adtte_missing)=,boolean) %then %let _adtte_missing=0;
%if %sysevalf(%superq(_adtte_bad_cnsr)=,boolean) %then %let _adtte_bad_cnsr=0;

%assert(%sysevalf(%superq(_adtte_missing)=0), msg=ADTTE has missing USUBJID (&_adtte_missing), level=ERROR);
%assert(%sysevalf(%superq(_adtte_bad_cnsr)=0), msg=ADTTE has invalid CNSR values (&_adtte_bad_cnsr), level=ERROR);

proc datasets lib=work nolist;
  delete _qc_adtte;
quit;
