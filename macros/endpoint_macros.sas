/* endpoint_macros.sas
   Shared endpoint derivations (e.g., time-to-event). */

%macro derive_time_to_event(inds=adam.adsl, outds=adam.adtte,
                            event_var=PROG_EVENT, time_var=TTD,
                            censor_var=CNSR);
  %if not %sysfunc(exist(&inds.)) %then %do;
    %put WARNING: [RUN=&RUN_ID.] Cannot derive TTE because &inds. is missing.;
    %return;
  %end;

  data &outds.;
    set &inds.;
    length &time_var 8 &censor_var 8;
    format &time_var 8. &censor_var 8.;

    if &event_var = 1 then do;
      &time_var = max(0, EVTDT - RANDDT + 1);
      &censor_var = 0;
    end;
    else do;
      &time_var = max(0, CUTOFFDT - RANDDT + 1);
      &censor_var = 1;
    end;
  run;

  %if %sysfunc(macroexist(log_counts)) %then %do;
    %log_counts(lib=%scan(&outds., 1, .), ds=%scan(&outds., 2, .), label=Post-derive_time_to_event);
  %end;
%mend derive_time_to_event;
