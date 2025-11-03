
%include "&root./Macros/metadata_driven_mapping.sas";
%import_csv(ds=dm, file=&sdtm./DM.csv);
%import_csv(ds=spec, file=&specs./ADSL_spec.csv);
%apply_spec(source=dm, spec=spec, out=ADSL);
%export_csv(ds=ADSL, file=&adam./ADSL.csv);
