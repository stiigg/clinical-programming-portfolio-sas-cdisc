/* sdtm_build_from_metadata.sas
   Wrapper that injects run config prior to executing raw_to_sdtm.sas. */

%include "config/config_study.sas";
%include "config/config_run_auto.sas";
%include "macros/run_provenance.sas";
%include "macros/cdisc_logging.sas";
%include "macros/logging_counts.sas";

%put NOTE: [RUN=&RUN_ID.] Starting SDTM build for TLF set &TLF_SET.;
%include "etl/raw_to_sdtm.sas";
