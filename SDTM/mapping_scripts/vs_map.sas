
%include "&root./Macros/metadata_driven_mapping.sas";
%import_csv(ds=vs_raw, file=&raw./vs.csv);
data sdtm_vs;
  set vs_raw(rename=(vsorres=VSORRES vsstresu=VSSTRESU VSTEST=VSTEST));
  STUDYID = "PORTFOLIO01";
  DOMAIN = "VS";
run;
%check_keys(ds=sdtm_vs, keys=USUBJID VSTEST VSDTC);
%export_csv(ds=sdtm_vs, file=&sdtm./VS.csv);
