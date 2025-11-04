/* Validation: ADaM/validation/validate_adlb.sas */
%include "../macros/_setup.sas";

%qcflags(in=ADaM.ADLB, out=work._qc_adlb);

proc sql noprint;
  select sum(QC_FLAG) into :_adlb_flags trimmed from work._qc_adlb;
  select count(*) into :_adlb_dup trimmed
  from (
    select USUBJID, PARAMCD, AVISITN, count(*) as n
    from ADaM.ADLB
    group by USUBJID, PARAMCD, AVISITN
    having calculated n>1
  );
quit;

%if %sysevalf(%superq(_adlb_flags)=,boolean) %then %let _adlb_flags=0;
%if %sysevalf(%superq(_adlb_dup)=,boolean) %then %let _adlb_dup=0;

%assert(%sysevalf(%superq(_adlb_flags)=0), msg=ADLB has QC issues (&_adlb_flags records), level=ERROR);
%assert(%sysevalf(%superq(_adlb_dup)=0), msg=ADLB has duplicate keys (&_adlb_dup combinations), level=ERROR);

proc datasets lib=work nolist;
  delete _qc_adlb;
quit;
