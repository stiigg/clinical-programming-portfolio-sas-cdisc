/* macros/run_init.sas
   Initialize libraries and derived paths for metadata-driven run control. */
%macro run_init;
  %local _root;

  %if %symexist(PROJECTROOT) %then %let _root=&PROJECTROOT.;
  %else %if %symexist(project_root) %then %let _root=&project_root.;

  %if %sysevalf(%superq(_root)=, boolean) %then %do;
    %put ERROR: PROJECTROOT not defined. Check config/config_study.sas.;
    %abort cancel;
  %end;

  %let PROJECTROOT = &_root.;
  %let OUT_ROOT = &PROJECTROOT./outputs/&RUN.;

  %put NOTE: === STUDYID=&STUDYID RUN=&RUN RUN_SET=&RUN_SET SAP=&SAP_VERSION DATA_CUT=&DATA_CUT_DT ===;

  options dlcreatedir;
  libname raw   "&PROJECTROOT./data/raw";
  libname ref   "&PROJECTROOT./data/ref";
  libname specs "&PROJECTROOT./specs";
  libname sdtm  "&OUT_ROOT./sdtm";
  libname adam  "&OUT_ROOT./adam";
  libname tlf   "&OUT_ROOT./tlf";
  libname qc    "&OUT_ROOT./qc";
%mend run_init;
