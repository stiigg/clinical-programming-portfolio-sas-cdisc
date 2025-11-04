/*-----------------------------------------------------------------------------
Macro:       %audit_start / %audit_end
Purpose:     Capture run metadata and redirect logs for each domain program
-----------------------------------------------------------------------------*/
%macro audit_start(domain=, program=);
  %local _ts _logfile;
  %let _ts=%sysfunc(datetime(), e8601dt.);
  %let _logfile=%sysfunc(cats(%superq(G_ADAM_ROOT),/logs/,%upcase(&domain)_,%sysfunc(date(),yymmddn8.),.log));
  filename audit "&_logfile";
  proc printto log=audit new; run;
  %put NOTE: AUDIT START %upcase(&domain) at &_ts by &sysuserid using &program;
%mend audit_start;

%macro audit_end(domain=);
  %local _te;
  %let _te=%sysfunc(datetime(), e8601dt.);
  %put NOTE: AUDIT END %upcase(&domain) at &_te;
  proc printto; run;
%mend audit_end;
