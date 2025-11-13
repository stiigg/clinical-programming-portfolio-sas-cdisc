/* sdtm_qc_main.sas
   Independent QC driver for SDTM domains. */

%include "macros/cdisc_init.sas";
%cdisc_init(study_config="config/config_study.sas");

%include "macros/qc_compare.sas";
%include "macros/cdisc_logging.sas";

%start_log(step_name=sdtm_qc);

/* Example: independently re-create AE domain using raw data */
proc import datafile="&raw_dir./ae.csv" dbms=csv out=qc.ae_qc replace;
  guessingrows=max;
run;

data qc.ae_qc;
  set qc.ae_qc;
  length STUDYID $20 DOMAIN $2;
  STUDYID = "&studyid.";
  DOMAIN = 'AE';
run;

%qc_compare(base=sdtm.ae, compare=qc.ae_qc, id=USUBJID AETERM AESTDTC, out=qc.qc_diff_ae);

%end_log(step_name=sdtm_qc);
