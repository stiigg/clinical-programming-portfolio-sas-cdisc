/* jenner-check bundle: macros/apply_subgroup.sas (%apply_subgroup)
   from stiigg/clinical-programming-portfolio-sas-cdisc
   Caller exercises the repo's %apply_subgroup macro, a text-generating
   macro rather than a data-step macro: called with no subgrp_id (or
   when specs.spec_subgroup is absent) it expands to the literal WHERE
   fragment "1=1", meant to be dropped straight into a WHERE clause so
   subgroup filtering becomes a no-op filter. Exercised here inside a
   real WHERE clause against a small DM-shaped sample (shaped like
   data/raw/dm.csv), both with no subgrp_id (all subjects pass) and with
   a subgrp_id supplied but no specs.spec_subgroup library assigned
   (same "1=1" fallback -- the third %else branch). %apply_subgroup is
   copied verbatim. */

data dm;
  length USUBJID $10 ARMCD $2 SEX $1 AGE 8;
  input USUBJID $ ARMCD $ SEX $ AGE;
  datalines;
S001 B M 45
S002 B M 26
S003 B F 63
S004 A F 41
S005 B F 65
;
run;

/* ---- macros/apply_subgroup.sas (verbatim) ---- */
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

/* case 1: no subgrp_id -- unconditional 1=1 */
data dm_all;
  set dm;
  where %apply_subgroup();
run;

/* case 2: subgrp_id supplied but no specs.spec_subgroup library assigned
   -- falls through to the same 1=1 default */
data dm_fallback;
  set dm;
  where %apply_subgroup(subgrp_id=ELDERLY);
run;

proc print data=dm_all noobs;
  title 'apply_subgroup() with no subgrp_id: all subjects kept';
run;

proc print data=dm_fallback noobs;
  title 'apply_subgroup(subgrp_id=ELDERLY) with no spec_subgroup lib: falls back to 1=1, all subjects kept';
run;
