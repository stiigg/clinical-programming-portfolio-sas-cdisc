/* scan_logs_and_summarize.sas
   Scans log directory for warnings/errors and prints a summary. */

%include "&ROOT./config/global_config.sas";
%include "&ROOT./config/select_run.sas";
%include "macros/cdisc_logging.sas";

%let _log_dir=%sysfunc(coalescec(&LOG_OUT., &LOG_ROOT.));
filename logdir "&_log_dir.";

data _null_;
  length mem $256;
  did = dopen('logdir');
  if did <= 0 then do;
    put 'WARNING: Unable to open log directory ' "&_log_dir.";
    stop;
  end;
  do i = 1 to dnum(did);
    mem = dread(did, i);
    if upcase(scan(mem, -1, '.')) = 'LOG' then do;
      call execute(cats('%scan_log(path=', "&_log_dir./", mem, ');'));
    end;
  end;
  rc = dclose(did);
run;
