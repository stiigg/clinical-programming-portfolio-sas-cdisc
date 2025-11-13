/* sdtm_generic.sas
   Shared SDTM transformation helpers. */

%macro sdtm_date_from_iso(var=, out=);
  %if %length(&out)=0 %then %let out=&var.;
  if not missing(&var.) then do;
    &out. = input(&var., yymmdd10.);
    format &out. yymmdd10.;
  end;
%mend;

%macro sdtm_merge_dm_keys(source=, target=, out=merged);
  proc sql;
    create table &out. as
    select t.*, d.STUDYID
    from &target. as t
    left join sdtm.dm as d
      on t.USUBJID = d.USUBJID;
  quit;
%mend;

%macro sdtm_standard_checks(domain=);
  %put NOTE: Running standard SDTM checks for &domain.;
  %freq_check(ds=sdtm.&domain., var=USUBJID);
%mend;
