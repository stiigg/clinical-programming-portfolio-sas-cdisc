/* etl/run_adam.sas
   Build core ADaM datasets for the SCLC run. */
%put NOTE: [ADaM] Starting ADaM build for RUN=&RUN.;
%include "&PROJECTROOT./macros/population_macros.sas";
%include "&PROJECTROOT./macros/adam_adsl.sas";
%include "&PROJECTROOT./macros/derive_tte_from_adresp.sas";
%include "&PROJECTROOT./macros/derive_tte_from_adae.sas";
%include "&PROJECTROOT./macros/tte_censoring_rules.sas";
%include "&PROJECTROOT./macros/derive_time_to_event.sas";
%include "&PROJECTROOT./macros/derive_all_tte.sas";

%adam_adsl;
%derive_all_tte;
