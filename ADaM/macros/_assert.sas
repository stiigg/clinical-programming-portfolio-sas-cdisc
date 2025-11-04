/*-----------------------------------------------------------------------------
Macro:       %assert
Purpose:     Provide consistent messaging for hard (ERROR) and soft (WARN) checks
-----------------------------------------------------------------------------*/
%macro assert(condition, msg, level=ERROR);
  %if &condition %then %do;
  %end;
  %else %do;
    %if %upcase(&level)=ERROR %then %do;
      %put ERROR: &msg;
      %abort cancel;
    %end;
    %else %if %upcase(&level)=WARN %then %do;
      %put WARNING: &msg;
    %end;
    %else %put NOTE: &msg;
  %end;
%mend assert;
