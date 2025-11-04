/*-----------------------------------------------------------------------------
Macro:       %mergecheck
Purpose:     Detect duplicate keys prior to merges and optionally allow 1:M joins
-----------------------------------------------------------------------------*/
%macro mergecheck(base=, add=, by=, allow_many=NO);
  proc sql noprint;
    create table _dups as
    select &by, count(*) as n
    from &add
    group by &by
    having calculated n>1;
  quit;

  %if %upcase(&allow_many)=NO %then %do;
    %assert(%sysfunc(exist(_dups))=0,
            msg=&add has duplicates by (&by),
            level=ERROR);
  %end;
%mend mergecheck;
