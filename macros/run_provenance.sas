/* run_provenance.sas
   Run-level provenance helpers for stamping datasets and TLFs. */

%macro run_init(study_id=, run_id=, mode=, sap_ver=, data_cut=, log_root=);
  %global RUN_TS RUN_LABEL G_STUDY_ID G_RUN_ID G_MODE G_SAP_VER G_DATA_CUT G_LOG_ROOT;
  %let RUN_TS      = %sysfunc(datetime(), e8601dt.);
  %let G_STUDY_ID  = &study_id.;
  %let G_RUN_ID    = &run_id.;
  %let G_MODE      = &mode.;
  %let G_SAP_VER   = &sap_ver.;
  %let G_DATA_CUT  = &data_cut.;
  %let G_LOG_ROOT  = &log_root.;
  %let RUN_LABEL   = &G_STUDY_ID.-&G_RUN_ID.-&G_SAP_VER.-&G_DATA_CUT.;

  %put NOTE: ==== START RUN &RUN_LABEL. MODE=&G_MODE. ====;
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
  %local _study _run _sap _cut _mode;
  %let _study=%sysfunc(coalescec(&G_STUDY_ID., &STUDY_ID.));
  %let _run=%sysfunc(coalescec(&G_RUN_ID., &RUN_ID.));
  %let _sap=%sysfunc(coalescec(&G_SAP_VER., &SAP_VERSION.));
  %let _cut=%sysfunc(coalescec(&G_DATA_CUT., &DATA_CUT_DT.));
  %let _mode=%sysfunc(coalescec(&G_MODE., &MODE.));

  footnote1 "Study &_study., Run &_run., SAP &_sap., Cut &_cut.";
  footnote2 "Generated &sysdate9. &systime. (&_mode. mode)";
%mend footnote_run;
