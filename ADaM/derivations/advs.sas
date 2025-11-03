
%include "&root./Macros/metadata_driven_mapping.sas";
%import_csv(ds=vs, file=&sdtm./VS.csv);
%import_csv(ds=spec, file=&specs./ADVS_spec.csv);
%apply_spec(source=vs, spec=spec, out=ADVS);
%export_csv(ds=ADVS, file=&adam./ADVS.csv);
