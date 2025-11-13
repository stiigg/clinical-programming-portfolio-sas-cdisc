/* sdtm_domain_dm.sas */

%macro sdtm_dm;
  proc import datafile="&raw_dir./dm.csv" dbms=csv out=_dm_raw replace;
    guessingrows=max;
  run;

  data sdtm.dm;
    length STUDYID $20 DOMAIN $2 AGEU $5;
    set _dm_raw;
    STUDYID = "&studyid.";
    DOMAIN = 'DM';
    AGEU = 'YEARS';
    %sdtm_date_from_iso(var=RFSTDTC, out=RFSTD);
    %sdtm_date_from_iso(var=RFENDTC, out=RFEND);
  run;

  proc sort data=sdtm.dm;
    by USUBJID;
  run;

  %sdtm_standard_checks(domain=dm);
%mend;
