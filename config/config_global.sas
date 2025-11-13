/* config_global.sas
   Global SAS options and library assignments for the portfolio pipeline. */

options validvarname=v7 mprint mlogic symbolgen;

%include "&project_root./macros/util_metadata.sas";
%set_project_paths;

libname raw    "&raw_dir.";
libname sdtm   "&output_root./sdtm";
libname adam   "&output_root./adam";
libname qc     "&output_root./qc";
libname reg    "&output_root./regulatory";
options sasautos=("&project_root./macros" sasautos);

%put NOTE: Project root set to &project_root.;
%put NOTE: Specs located at &spec_dir.;
