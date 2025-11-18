/* macros/apply_subgroup.sas */
%macro apply_subgroup(subgrp_id=);
  %local rule;
  %if %sysevalf(%superq(subgrp_id)=, boolean) %then %do;
    %let rule=1=1;
  %end;
  %else %if %sysfunc(exist(specs.spec_subgroup)) %then %do;
    proc sql noprint;
      select RULE into :rule trimmed
      from specs.spec_subgroup
      where upcase(SUBGRP_ID)=upcase("&subgrp_id.");
    quit;
    %if &sqlobs = 0 %then %let rule=1=1;
  %end;
  %else %let rule=1=1;

  &rule
%mend;
