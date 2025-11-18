/* etl/run_tlf.sas
   Drive TLF execution from metadata for the requested RUN_SET. */
%put NOTE: [TLF] Starting TLF build for RUN=&RUN. (RUN_SET=&RUN_SET.);
%include "&PROJECTROOT./macros/population_macros.sas";
%include "&PROJECTROOT./macros/apply_subgroup.sas";
%include "&PROJECTROOT./macros/tlf_km.sas";
%include "&PROJECTROOT./macros/tlf_resp_rate.sas";
%include "&PROJECTROOT./macros/tlf_dispatch.sas";
%include "&PROJECTROOT./etl/etl_tlf.sas";
%tlf_dispatch(run_set=&RUN_SET);
