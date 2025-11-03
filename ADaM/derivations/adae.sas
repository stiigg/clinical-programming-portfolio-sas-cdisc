
%include "&root./Macros/metadata_driven_mapping.sas";
%import_csv(ds=dm, file=&sdtm./DM.csv);
%import_csv(ds=ae, file=&sdtm./AE.csv);
%import_csv(ds=spec, file=&specs./ADAE_spec.csv);
proc sql;
  create table ae_dm as
  select a.*, b.RFSTDTC
  from ae a left join dm b
    on a.USUBJID=b.USUBJID;
quit;
data ae_dm;
  set ae_dm;
  if not missing(AESTDTC) and not missing(RFSTDTC) and AESTDTC >= RFSTDTC then TRTEMFL='Y';
  else TRTEMFL='N';
run;
%apply_spec(source=ae_dm, spec=spec, out=ADAE);
%export_csv(ds=ADAE, file=&adam./ADAE.csv);
