/* Validation: ADaM/validation/validate_advs.sas */
%include "../macros/_setup.sas";

%qcflags(in=ADaM.ADVS, out=work._qc_advs);

proc sql noprint;
  select sum(QC_FLAG) into :_advs_flags trimmed from work._qc_advs;
  select count(*) into :_advs_missing_base trimmed
  from ADaM.ADVS where missing(BASE) and not missing(AVAL);
quit;

%if %sysevalf(%superq(_advs_flags)=,boolean) %then %let _advs_flags=0;
%if %sysevalf(%superq(_advs_missing_base)=,boolean) %then %let _advs_missing_base=0;

%assert(%sysevalf(%superq(_advs_flags)=0), msg=ADVS has QC issues (&_advs_flags records), level=ERROR);
%assert(%sysevalf(%superq(_advs_missing_base)=0), msg=ADVS records missing baseline (&_advs_missing_base), level=WARN);

proc datasets lib=work nolist;
  delete _qc_advs;
quit;
