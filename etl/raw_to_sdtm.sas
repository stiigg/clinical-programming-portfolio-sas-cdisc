/* raw_to_sdtm.sas
   Driver program to convert raw clinical data to SDTM domains. */

%include "&ROOT./config/global_config.sas";
%include "&ROOT./config/select_run.sas";
%include "macros/run_provenance.sas";
%include "macros/logging_counts.sas";

%include "macros/cdisc_logging.sas";
%include "macros/qc_compare.sas";
%include "macros/sdtm_generic.sas";
%include "macros/sdtm_domain_dm.sas";
%include "macros/sdtm_domain_ae.sas";
%include "etl/process_domains.sas";

%start_log(step_name=raw_to_sdtm);
%process_domains(type=SDTM);
%end_log(step_name=raw_to_sdtm);
