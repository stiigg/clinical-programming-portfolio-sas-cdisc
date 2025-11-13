/* sdtm_domain_ae.sas */

%macro sdtm_ae;
  %local mapping_file;
  %let mapping_file=&spec_dir./sdtm_mapping.csv;
  %put NOTE: Building AE domain using &mapping_file.;

  proc import datafile="&raw_dir./ae.csv" dbms=csv out=_ae_raw replace;
    guessingrows=max;
  run;

  data sdtm.ae;
    length STUDYID $20 DOMAIN $2 AESCAT $40;
    set _ae_raw;
    STUDYID = "&studyid.";
    DOMAIN = 'AE';
    AESCAT = 'TREATMENT EMERGENT';
  run;

  proc sort data=sdtm.ae;
    by USUBJID AETERM AESTDTC;
  run;

  %sdtm_standard_checks(domain=ae);
%mend;
