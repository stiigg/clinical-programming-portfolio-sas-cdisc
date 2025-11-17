/* run_all.sas
   Orchestrates SDTM, ADaM, and TLF generation for a selected run config. */

%include "&ROOT./config/global_config.sas";
%include "&ROOT./config/select_run.sas";

%include "macros/run_provenance.sas";
%include "macros/cdisc_logging.sas";
%include "macros/logging_counts.sas";
%include "macros/population_macros.sas";
%include "macros/endpoint_macros.sas";
%include "macros/tlf_dispatch.sas";
%include "macros/tlf_programs_stub.sas";

%run_init(study_id=&STUDY_ID., run_id=&RUN_ID., mode=&MODE., sap_ver=&SAP_VERSION.,
         data_cut=&DATA_CUT_DT., log_root=&LOG_OUT.);

%if %upcase(&INCLUDE_SD) = Y %then %do;
  %include "etl/sdtm_build_from_metadata.sas";
%end;
%else %put NOTE: [RUN=&RUN_ID.] INCLUDE_SD=&INCLUDE_SD. so skipping SDTM build.;

%if %upcase(&INCLUDE_AD) = Y %then %do;
  %include "etl/adam_build_all.sas";
%end;
%else %put NOTE: [RUN=&RUN_ID.] INCLUDE_AD=&INCLUDE_AD. so skipping ADaM build.;

%if %upcase(&INCLUDE_TLF) = Y %then %do;
  %include "etl/tlf_run_from_metadata.sas";
%end;
%else %put NOTE: [RUN=&RUN_ID.] INCLUDE_TLF=&INCLUDE_TLF. so skipping TLF build.;

%include "validation/scan_logs_and_summarize.sas";
