/* config/select_run.sas
   Dispatcher that includes the appropriate run_*.sas file. */

%if %sysevalf(%superq(RUN)=, boolean) %then %do;
  %put ERROR: RUN macro variable not provided. Use -set RUN <run_name> when invoking SAS.;
  %abort cancel;
%end;

%put NOTE: >>> RUN=&RUN. <<<;

%if      %upcase(%superq(RUN)) = LOCK_MAIN        %then %include "&ROOT./config/run_LOCK_MAIN.sas";
%else %if %upcase(%superq(RUN)) = INTERIM_2025M10 %then %include "&ROOT./config/run_INTERIM_2025M10.sas";
%else %do;
  %put ERROR: Unknown RUN=&RUN.. Create config/run_&RUN..sas or update config/select_run.sas.;
  %abort cancel;
%end;
