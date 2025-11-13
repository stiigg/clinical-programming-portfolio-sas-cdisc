/* generate_ADRG_outline.sas */

%include "macros/cdisc_init.sas";
%cdisc_init(study_config="config/config_study.sas");

%include "macros/cdisc_logging.sas";

%start_log(step_name=adrg_outline);

data reg.ADRG_outline;
  length Section $64 Detail $200;
  Section='Analysis Datasets'; Detail='ADSL and ADAE produced via metadata-driven macros'; output;
  Section='Quality Controls'; Detail='Independent QC results stored in qc library'; output;
run;

%end_log(step_name=adrg_outline);
