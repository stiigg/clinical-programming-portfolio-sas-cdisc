/*-----------------------------------------------------------------------------
Macro:       ADaM/macros/_setup.sas
Purpose:     Establish project options, library assignments, and macro includes
Details:
  - Derives project root paths relative to the executing derivation program
  - Assigns SDTM and ADaM libraries using repository folder structure
  - Sets common SAS options for reproducible ADaM programming
  - Auto-loads shared utility macros housed in ADaM/macros
-----------------------------------------------------------------------------*/
%global G_PROJECT_ROOT G_ADAM_ROOT G_SDTM_ROOT G_METADATA_SPEC_PATH G_MACROS_INITIALIZED;
%global G_REPORT_ROOT G_EXPORT_ROOT;

%macro _determine_roots;
  %local _program _normalized _progdir;

  %let _program=%sysfunc(getoption(sysin));
  %if %superq(_program)= %then %do;
    %let _program=%sysfunc(getoption(SASINITIALFOLDER));
    %if %superq(_program)= %then %let _program=%sysget(PWD);
  %end;

  %if %superq(_program)= %then %do;
    %put WARNING: Unable to resolve executing program path. Override G_PROJECT_ROOT before running.;
    %return;
  %end;

  %let _normalized=%sysfunc(prxchange(s/\\/\//,-1,%superq(_program)));
  %if %sysfunc(fileexist(&_normalized)) %then %let _progdir=%sysfunc(prxchange(s/[^\/]+$//,-1,&_normalized));
  %else %let _progdir=%superq(_normalized);

  %let G_ADAM_ROOT=%sysfunc(prxchange(s/\/(derivations)(\/$)?$//,-1,%superq(_progdir)));
  %let G_PROJECT_ROOT=%sysfunc(prxchange(s/\/(ADaM)(\/$)?$//,-1,%superq(G_ADAM_ROOT)));
  %let G_SDTM_ROOT=%sysfunc(cats(%superq(G_PROJECT_ROOT),/SDTM/SDTM_domains));
  %let G_METADATA_SPEC_PATH=%sysfunc(cats(%superq(G_ADAM_ROOT),/metadata/spec));
  %let G_REPORT_ROOT=%sysfunc(cats(%superq(G_ADAM_ROOT),/reports));
  %let G_EXPORT_ROOT=%sysfunc(cats(%superq(G_ADAM_ROOT),/exports));
%mend _determine_roots;

%if %sysevalf(%superq(G_PROJECT_ROOT)=,boolean) %then %_determine_roots;

options nodate nonumber validvarname=upcase missing='.' ls=256 ps=60 mprint symbolgen;

%macro _assign_libs;
  %if %sysevalf(%superq(G_PROJECT_ROOT)=,boolean) %then %do;
    %put WARNING: G_PROJECT_ROOT is not set. Libraries were not assigned.;
  %end;
  %else %do;
    libname SDTM "%superq(G_SDTM_ROOT)" access=readonly;
    libname ADaM "%superq(G_ADAM_ROOT)/analysis_datasets";
    libname METADATA "%superq(G_ADAM_ROOT)/metadata";
  %end;
%mend _assign_libs;
%_assign_libs;

%macro _include_macro(file);
  %if %sysfunc(fileexist(%sysfunc(cats(%superq(G_ADAM_ROOT),/macros/,%superq(file))))) %then %do;
    %include "%superq(G_ADAM_ROOT)/macros/%superq(file)" / source2;
  %end;
  %else %put WARNING: Macro file %superq(file) not found under &G_ADAM_ROOT/macros.;
%mend _include_macro;

%if %sysevalf(%superq(G_MACROS_INITIALIZED)=,boolean) %then %do;
  %_include_macro(_assert.sas);
  %_include_macro(_mergecheck.sas);
  %_include_macro(_popflags.sas);
  %_include_macro(_baseline.sas);
  %_include_macro(_qcflags.sas);
  %_include_macro(_audit.sas);
  %_include_macro(_specdiff.sas);
  %_include_macro(_export_xpt.sas);
  %let G_MACROS_INITIALIZED=1;
%end;

