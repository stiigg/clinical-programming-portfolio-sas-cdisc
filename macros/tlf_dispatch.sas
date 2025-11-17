/* tlf_dispatch.sas
   Dispatch metadata-driven TLF requests to specific program macros. */

%macro tlf_dispatch(tlf_id=, program_id=, population=, param_family=,
                    paramcd_list=, risk_level=);
  %local pgm;
  %let pgm = %sysfunc(compress(&program_id., %str( )));

  %log_run_tlf_start(&tlf_id., &pgm., &population., &risk_level.);

  %if %sysfunc(macroexist(&pgm.)) %then %do;
    %&pgm.(
      tlf_id=&tlf_id.,
      population=&population.,
      param_family=&param_family.,
      paramcd_list=&paramcd_list.,
      risk_level=&risk_level.
    );
  %end;
  %else %do;
    %put ERROR: [RUN=&RUN_ID.] Unknown PROGRAM_ID=&program_id. for TLF=&tlf_id.;
  %end;

  %log_run_tlf_end(&tlf_id., &pgm.);
%mend tlf_dispatch;
