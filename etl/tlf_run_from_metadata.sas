/* tlf_run_from_metadata.sas
   Loop through specs/spec_tlf.csv and dispatch active outputs. */

%include "&ROOT./config/global_config.sas";
%include "&ROOT./config/select_run.sas";
%include "macros/cdisc_logging.sas";
%include "macros/run_provenance.sas";
%include "macros/tlf_dispatch.sas";
%include "macros/tlf_programs_stub.sas";

proc import datafile="&SPECS_ROOT./spec_tlf.csv"
  out=work.tlf_spec dbms=csv replace;
  guessingrows=max;
run;

data work.tlf_run;
  set work.tlf_spec;
  where upcase(RUN_ACTIVE)='Y' and upcase(TLF_SET)=upcase("&TLF_SET.");
  TLF_ID_num + 1;
run;

data _null_;
  set work.tlf_run;
  length call $1000;
  call = cats('%tlf_dispatch(',
              'tlf_id=', quote(trim(TLF_ID)), ',',
              'program_id=', quote(trim(PROGRAM_ID)), ',',
              'population=', quote(trim(POPULATION)), ',',
              'param_family=', quote(trim(PARAM_FAMILY)), ',',
              'paramcd_list=', quote(trim(PARAMCD_LIST)), ',',
              'risk_level=', quote(trim(RISK_LEVEL)), ');');
  putlog "NOTE: Submitting " call;
  call execute(call);
run;
