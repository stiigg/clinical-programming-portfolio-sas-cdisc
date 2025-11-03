
/* log_review.sas */
%macro scanlog(path=);
  filename lg "&path.";
  data _null_;
    infile lg truncover;
    input line $char200.;
    if index(upcase(line), 'ERROR:') or index(upcase(line), 'WARNING:') then putlog ">> " line;
  run;
%mend;
