/* run_provenance.sas
   Run-level provenance helpers for stamping datasets and TLFs. */

%macro run_init;
  %global RUN_TS RUN_LABEL;
  %let RUN_TS    = %sysfunc(datetime(), e8601dt.);
  %let RUN_LABEL = &STUDY_ID.-&RUN_ID.-&SAP_VERSION.-&DATA_CUT_DT.;

  %put NOTE: ==== START RUN &RUN_LABEL. MODE=&MODE. ====;
%mend run_init;

%macro stamp_dataset(lib=, ds=);
  %local dsid rc;
  %if %sysfunc(exist(&lib..&ds.)) %then %do;
    proc datasets lib=&lib. nolist;
      modify &ds.;
        label = catx(' | ', label, "RUN=&RUN_ID.", "SAP=&SAP_VERSION.",
                      "CUT=&DATA_CUT_DT.", "TS=&RUN_TS.");
    quit;
  %end;
  %else %put WARNING: [RUN=&RUN_ID.] &lib..&ds. does not exist for stamping.;
%mend stamp_dataset;

%macro footnote_run;
  footnote1 "Study &STUDY_ID., Run &RUN_ID., SAP &SAP_VERSION., Cut &DATA_CUT_DT.";
  footnote2 "Generated &sysdate9. &systime. (&MODE. mode)";
%mend footnote_run;
