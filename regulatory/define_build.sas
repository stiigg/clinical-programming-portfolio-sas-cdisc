/* define_build.sas
   Orchestrates metadata-driven Define-XML 2.1 generation for SDTM and ADaM. */

%include "macros/cdisc_init.sas";
%include "macros/util_metadata.sas";
%include "macros/cdisc_logging.sas";
%include "etl/meta_load.sas";
%include "macros/define_build_meta.sas";
%include "macros/define_write_xml_v21.sas";

%macro define_build(
  study_config = config/config_study.sas,
  project_root =
);
  %if %length(&project_root) %then %do;
    %cdisc_init(study_config=&study_config., project_root=&project_root.);
  %end;
  %else %do;
    %cdisc_init(study_config=&study_config.);
  %end;

  %set_project_paths;

  options dlcreatedir;
  libname specs "&spec_dir.";
  libname outreg "&output_root./regulatory";
  libname logs "&output_root./logs";
  libname logs clear;

  %load_specs(path=&spec_dir.);

  %start_log(step_name=define_build, logdir=&output_root./logs);

  %define_build_meta(standard=SDTM, outlib=work);
  %define_write_xml_v21(standard=SDTM,
                        inlib=work,
                        outxml=&output_root./regulatory/define_sdtm.xml,
                        studyid=&studyid.,
                        version=2.1.0,
                        standard_version=&sdtm_version.,
                        standard_name=SDTM);

  %define_build_meta(standard=ADAM, outlib=work);
  %define_write_xml_v21(standard=ADAM,
                        inlib=work,
                        outxml=&output_root./regulatory/define_adam.xml,
                        studyid=&studyid.,
                        version=2.1.0,
                        standard_version=&adam_version.,
                        standard_name=ADaM);

  %end_log(step_name=define_build);

  libname specs clear;
  libname outreg clear;
%mend define_build;

%define_build();
