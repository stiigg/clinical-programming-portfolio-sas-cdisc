/* adam_build_all.sas
   Wrapper that derives shared ADaM assets after sdtm_to_adam.sas. */

%include "&ROOT./config/global_config.sas";
%include "&ROOT./config/select_run.sas";
%include "macros/run_provenance.sas";
%include "macros/cdisc_logging.sas";
%include "macros/logging_counts.sas";
%include "macros/population_macros.sas";
%include "macros/endpoint_macros.sas";

%put NOTE: [RUN=&RUN_ID.] Starting ADaM build for TLF set &TLF_SET.;
%include "etl/sdtm_to_adam.sas";

%if %upcase(&INCLUDE_AD) = Y %then %do;
  %derive_pop_flags(adsl_in=&ADAM_LIB..adsl, adsl_out=&ADAM_LIB..adsl);
  %derive_time_to_event(inds=&ADAM_LIB..adsl, outds=&ADAM_LIB..adtte,
                        event_var=PROG_EVENT, time_var=TTD, censor_var=CNSR);
  %stamp_dataset(lib=&ADAM_LIB., ds=adsl);
  %stamp_dataset(lib=&ADAM_LIB., ds=adtte);
%end;
%else %put NOTE: [RUN=&RUN_ID.] INCLUDE_AD=&INCLUDE_AD. so skipping ADaM post-processing.;
