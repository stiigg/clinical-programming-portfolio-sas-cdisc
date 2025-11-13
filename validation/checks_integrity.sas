/* checks_integrity.sas
   Data integrity checks shared across SDTM and ADaM layers. */

%include "macros/cdisc_init.sas";
%cdisc_init(study_config="config/config_study.sas");

%include "macros/cdisc_logging.sas";
%include "macros/qc_compare.sas";

%start_log(step_name=data_integrity);

/* Duplicate AE records */
proc sql;
  create table qc.ae_duplicates as
  select USUBJID, AETERM, count(*) as DUP_COUNT
  from sdtm.ae
  group by USUBJID, AETERM
  having calculated DUP_COUNT > 1;
quit;

/* Subjects missing in ADSL */
proc sql;
  create table qc.missing_subjects as
  select a.USUBJID
  from sdtm.dm as a
  left join adam.adsl as b
    on a.USUBJID = b.USUBJID
  where b.USUBJID is null;
quit;

%end_log(step_name=data_integrity);
