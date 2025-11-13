/* adam_qc_main.sas
   Independent QC driver for ADaM datasets. */

%include "macros/cdisc_init.sas";
%cdisc_init(study_config="config/config_study.sas");

%include "macros/qc_compare.sas";
%include "macros/cdisc_logging.sas";

%start_log(step_name=adam_qc);

/* Re-derive ADSL using simplified logic */
proc sql;
  create table qc.adsl_qc as
  select USUBJID, STUDYID, SEX, AGE, 'Y' as SAFFL length=1
  from sdtm.dm;
quit;

%qc_compare(base=adam.adsl, compare=qc.adsl_qc, id=USUBJID, out=qc.qc_diff_adsl);

%end_log(step_name=adam_qc);
