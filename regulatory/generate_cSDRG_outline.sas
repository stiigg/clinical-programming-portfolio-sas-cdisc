/* generate_cSDRG_outline.sas */

%include "macros/cdisc_init.sas";
%cdisc_init(study_config="config/config_study.sas");

%include "macros/cdisc_logging.sas";

%start_log(step_name=csdrg_outline);

data reg.cSDRG_outline;
  length Section $64 Detail $200;
  Section='Study Data Compliance'; Detail='Summaries of SDTM domains generated via metadata-driven pipeline'; output;
  Section='Known Data Issues'; Detail='Refer to qc.ae_duplicates and qc.missing_subjects tables'; output;
run;

%end_log(step_name=csdrg_outline);
