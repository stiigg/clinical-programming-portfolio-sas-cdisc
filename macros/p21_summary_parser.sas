/* p21_summary_parser.sas
   Summarizes Pinnacle 21 output files for QC tracking. */

%macro p21_summary_parser(file=, out=qc.p21_summary);
  %if %length(&file.)=0 %then %do;
    %put WARNING: No Pinnacle 21 file specified.;
    %return;
  %end;

  %if %upcase(%scan(&file., -1, .)) = XLSX %then %do;
    proc import datafile="&file." dbms=xlsx out=_p21_raw replace;
    run;
  %end;
  %else %do;
    proc import datafile="&file." dbms=csv out=_p21_raw replace;
      guessingrows=max;
    run;
  %end;

  data _p21_clean;
    set _p21_raw;
    length IssueType $64 Severity $32 RuleID $64 Domain $32 Message $200;
    IssueType = coalescec(Issue, IssueType);
    Severity = coalescec(severity, Severity);
    RuleID   = coalescec(rule, RuleID);
    Domain   = coalescec(domain, Domain);
    Message  = coalescec(message, Message);
  run;

  proc sql;
    create table &out. as
    select strip(IssueType) as IssueType,
           strip(Severity) as Severity,
           strip(Domain) as Domain,
           count(*) as Count
    from _p21_clean
    group by IssueType, Severity, Domain;
  quit;
%mend;
