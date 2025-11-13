/* generate_define.sas
   Placeholder for define.xml generation using metadata. */

%include "macros/cdisc_init.sas";
%cdisc_init(study_config="config/config_study.sas");

%include "macros/cdisc_logging.sas";

%start_log(step_name=generate_define);

/* Example: metadata snapshot for define.xml */
%read_spec(file=&spec_dir./spec_toc.csv, out=_define_spec);

proc sql;
  create table reg.define_source as
  select 'SDTM' as Layer length=8, DOMAIN, TYPE, ACTIVE
  from _define_spec;
quit;

%put NOTE: Use SAS Clinical Standards Toolkit or sponsor utilities to convert define_source to define.xml.;

%end_log(step_name=generate_define);
