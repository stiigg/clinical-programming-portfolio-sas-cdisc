/* config_study.sas
   Study-specific configuration parameters. Update project_root to match your environment. */
%global project_root studyid sponsor protocol sdtm_version adam_version
        PROJECTROOT STUDYID PROTOCOL;

%if %sysevalf(%superq(project_root)=, boolean) %then %let project_root = <ABSOLUTE_PATH_TO_REPO>;
%let studyid      = PORTFOLIO01;
%let sponsor      = Portfolio Labs;
%let protocol     = PORT-001;
%let sdtm_version = 3.4;
%let adam_version = 1.1;

%if %sysevalf(%superq(PROJECTROOT)=, boolean) %then %let PROJECTROOT = &project_root.;
%else %let project_root = &PROJECTROOT.;
%let STUDYID     = &studyid.;
%let PROTOCOL    = &protocol.;
