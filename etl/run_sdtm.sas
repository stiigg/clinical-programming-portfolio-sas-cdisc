/* etl/run_sdtm.sas
   Wrapper that runs the existing SDTM build pipeline. */
%put NOTE: [SDTM] Starting SDTM build for RUN=&RUN.;
%if %sysfunc(fileexist("&PROJECTROOT./etl/sdtm_build_from_metadata.sas")) %then %do;
  %include "&PROJECTROOT./etl/sdtm_build_from_metadata.sas";
%end;
%else %if %sysfunc(fileexist("&PROJECTROOT./etl/raw_to_sdtm.sas")) %then %do;
  %include "&PROJECTROOT./etl/raw_to_sdtm.sas";
%end;
%else %put WARNING: [SDTM] No SDTM driver found under &PROJECTROOT./etl.;
