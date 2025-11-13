/* config_study.sas
   Study-specific configuration parameters. Update project_root to match your environment. */

%global project_root studyid sponsor protocol sdtm_version adam_version;

%let project_root = <ABSOLUTE_PATH_TO_REPO>;
%let studyid      = PORTFOLIO01;
%let sponsor      = Portfolio Labs;
%let protocol     = PORT-001;
%let sdtm_version = 3.4;
%let adam_version = 1.1;
