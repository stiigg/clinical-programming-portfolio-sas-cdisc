/* sdtm_to_adam.sas
   Driver program to convert SDTM datasets to ADaM analysis datasets. */

%include "macros/cdisc_init.sas";
%cdisc_init(study_config="config/config_study.sas");

%include "macros/cdisc_logging.sas";
%include "macros/qc_compare.sas";
%include "macros/adam_generic.sas";
%include "macros/ct_check.sas";
%include "macros/adam_adsl.sas";
%include "macros/adam_adae.sas";
%include "etl/process_domains.sas";

%start_log(step_name=sdtm_to_adam);
%process_domains(type=ADaM);
%end_log(step_name=sdtm_to_adam);
