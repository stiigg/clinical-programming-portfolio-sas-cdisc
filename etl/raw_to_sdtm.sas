/* raw_to_sdtm.sas
   Driver program to convert raw clinical data to SDTM domains. */

%include "config/config_study.sas";
%include "config/config_run_auto.sas";
%include "macros/run_provenance.sas";
%include "macros/logging_counts.sas";

%include "macros/cdisc_init.sas";
%cdisc_init(study_config="config/config_study.sas");

%include "macros/cdisc_logging.sas";
%include "macros/qc_compare.sas";
%include "macros/sdtm_generic.sas";
%include "macros/sdtm_domain_dm.sas";
%include "macros/sdtm_domain_ae.sas";
%include "etl/process_domains.sas";

%start_log(step_name=raw_to_sdtm);
%process_domains(type=SDTM);
%end_log(step_name=raw_to_sdtm);
