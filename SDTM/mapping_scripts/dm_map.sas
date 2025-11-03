
%include "&root./Macros/metadata_driven_mapping.sas";
%import_csv(ds=dm_raw, file=&raw./dm.csv);
data sdtm_dm;
  set dm_raw(rename=(sex=SEX arm=ARM age=AGE rfstdtc=RFSTDTC rfendtc=RFENDTC));
  STUDYID = "PORTFOLIO01";
  DOMAIN = "DM";
  %iso2date(RFSTDTC);
  %iso2date(RFENDTC);
  AGEU = "YEARS";
run;
%check_keys(ds=sdtm_dm, keys=USUBJID);
%export_csv(ds=sdtm_dm, file=&sdtm./DM.csv);
