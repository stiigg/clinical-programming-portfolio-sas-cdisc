/* cdisc_logging.sas
   Centralized logging helpers for the metadata-driven pipeline. */

%macro start_log(step_name=, logdir=, program=);
  %local logpath timestamp;
  %let timestamp=%sysfunc(datetime(), is8601dt.);
  %if %length(&logdir)=0 %then %let logdir=&project_root./outputs/logs;
  %if %length(&program)=0 %then %let program=%sysfunc(getoption(sysin));
  %let logpath=&logdir./%sysfunc(tranwrd(&step_name.,%str( ),_))_%sysfunc(compress(%sysfunc(datetime(), b8601dt.),':-')).log;
  %put NOTE: === Starting &step_name. at &timestamp. ===;
  %put NOTE: Log file: &logpath.;
%mend;

%macro end_log(step_name=, status=SUCCESS);
  %local timestamp;
  %let timestamp=%sysfunc(datetime(), is8601dt.);
  %put NOTE: === &step_name. completed with status &status. at &timestamp. ===;
%mend;

%macro scan_log(path=);
  %if %sysfunc(fileexist("&path.")) %then %do;
    filename lg "&path.";
    data _null_;
      infile lg truncover;
      input line $char300.;
      if index(upcase(line), 'ERROR:') or index(upcase(line), 'WARNING:') then putlog '>> ' line;
    run;
  %end;
  %else %do;
    %put WARNING: Log file &path. does not exist.;
  %end;
%mend;
