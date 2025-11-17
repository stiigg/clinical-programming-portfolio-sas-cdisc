/* sdtm_to_adam.sas
   Driver program to convert SDTM datasets to ADaM analysis datasets. */

%include "&ROOT./config/global_config.sas";
%include "&ROOT./config/select_run.sas";
%include "macros/run_provenance.sas";
%include "macros/logging_counts.sas";
%include "macros/population_macros.sas";
%include "macros/endpoint_macros.sas";

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
