/* scan_logs_and_summarize.sas
   Scans log directory for warnings/errors and prints a summary. */

%include "config/config_study.sas";
%include "config/config_run_auto.sas";
%include "macros/cdisc_logging.sas";

%let _log_dir=&OUTPUT_ROOT./&LOG_SUBDIR.;
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
