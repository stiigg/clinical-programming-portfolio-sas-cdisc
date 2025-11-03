
%include "&root./Macros/metadata_driven_mapping.sas";
%import_csv(ds=lb_raw, file=&raw./lb.csv);
data sdtm_lb;
  set lb_raw;
  STUDYID = "PORTFOLIO01";
  DOMAIN = "LB";
  LBSTRESC = strip(put(LBORRES, best.));
run;
%check_keys(ds=sdtm_lb, keys=USUBJID LBTEST LBDTC);
%export_csv(ds=sdtm_lb, file=&sdtm./LB.csv);
