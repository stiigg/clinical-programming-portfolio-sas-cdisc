/*-----------------------------------------------------------------------------
Macro:       %export_xpt
Purpose:     Write ADaM datasets to SAS v5 transport files for submission
-----------------------------------------------------------------------------*/
%macro export_xpt(data=, outpath=..);
  %local _lib _dsn _xpt;
  %let _lib=%scan(&data,1,.);
  %let _dsn=%scan(&data,2,.);
  %if %superq(_dsn)= %then %do;
    %put ERROR: export_xpt requires DATA=library.dataset;
    %return;
  %end;
  %let _xpt=%sysfunc(cats(&outpath,/,%upcase(&_dsn),.xpt));
  libname xptout xport "&_xpt";
  proc copy in=&_lib out=xptout; select &_dsn; run;
  libname xptout clear;
%mend export_xpt;
