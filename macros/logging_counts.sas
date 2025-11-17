/* logging_counts.sas
   Row-count logging helpers to capture deltas between runs. */

%macro log_counts(lib=work, ds=, label=);
  %local n;
  %if %sysfunc(exist(&lib..&ds.)) %then %do;
    proc sql noprint;
      select count(*) into :n trimmed from &lib..&ds.;
    quit;
    %put NOTE: [RUN=&RUN_ID.] &label. &lib..&ds. has &n. obs.;
  %end;
  %else %put WARNING: [RUN=&RUN_ID.] &label. &lib..&ds. does NOT exist.;
%mend log_counts;
