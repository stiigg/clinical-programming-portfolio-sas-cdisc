
%include "&root./Macros/metadata_driven_mapping.sas";
%import_csv(ds=ae_raw, file=&raw./ae.csv);
data sdtm_ae;
  set ae_raw(rename=(aeterm=AETERM aestdtc=AESTDTC aeendtc=AEENDTC aesev=AESEV aeser=AESER));
  STUDYID = "PORTFOLIO01";
  DOMAIN = "AE";
  AESCAT = "TREATMENT EMERGENT";
run;
%check_keys(ds=sdtm_ae, keys=USUBJID AETERM AESTDTC);
%export_csv(ds=sdtm_ae, file=&sdtm./AE.csv);
