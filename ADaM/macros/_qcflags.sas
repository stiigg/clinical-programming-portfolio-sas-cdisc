/*-----------------------------------------------------------------------------
Macro:       %qcflags
Purpose:     Generate standard row-level QC flag variables
-----------------------------------------------------------------------------*/
%macro qcflags(in=, out=);
  %if %superq(in)= %then %do;
    %put ERROR: qcflags requires IN= dataset.;
    %return;
  %end;
  %if %superq(out)= %then %let out=&in;

  data &out;
    set &in;
    QC_MISSKEY  = missing(USUBJID);
    QC_OUTRANGE = (not missing(AVAL) and (AVAL < -1e6 or AVAL > 1e6));
    QC_FLAG     = max(QC_MISSKEY, QC_OUTRANGE);
  run;
%mend qcflags;
