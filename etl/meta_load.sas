/* meta_load.sas
   Utility macro to load metadata repository CSV specifications into SAS work tables. */

%macro load_specs(path=specs);
  %local specdir;
  %let specdir=&path;

  %macro _load(file=, ds=, lengths=);
    %local fullpath;
    %let fullpath=&specdir./&file.;
    %if %sysfunc(fileexist("&fullpath.")) %then %do;
      proc import datafile="&fullpath." out=&ds. dbms=csv replace;
        guessingrows=max;
      run;
    %end;
    %else %do;
      data &ds.;
        length &lengths.;
        stop;
      run;
    %end;
  %mend _load;

  %_load(file=spec_toc.csv,
         ds=meta_toc,
         lengths=standard $8 domain $32 class $64 active_flag $1 order 8 has_value_level $1);

  %_load(file=spec_meta_dataset.csv,
         ds=meta_dataset,
         lengths=standard $8 domain $32 dataset_label $200 structure $200 keys $200 purpose $40 is_derived $1 comment $500 doc_id $32);

  %_load(file=spec_meta_variable.csv,
         ds=meta_variable,
         lengths=standard $8 domain $32 var_name $32 var_label $200 data_type $16 length 8 role $64 origin $32 codelist_id $40 method_id $40 mandatory $3 display_format $32 xml_order 8);

  %_load(file=spec_meta_value_level.csv,
         ds=meta_vlm,
         lengths=standard $8 domain $32 var_name $32 where_clause_id $40 where_clause_expression $200 vlm_label $200 codelist_id $40 method_id $40 data_type $16 length 8);

  %_load(file=spec_meta_codelist.csv,
         ds=meta_codelist,
         lengths=codelist_id $40 codelist_name $200 nci_code $32 ct_package $40 decode $200 code $64 decode_order 8 is_sponsor_ct $1);

  %_load(file=spec_meta_method.csv,
         ds=meta_method,
         lengths=method_id $40 method_type $32 method_description $500 program_ref $200);

  %_load(file=spec_meta_document.csv,
         ds=meta_document,
         lengths=doc_id $32 doc_title $200 doc_type $40 file_name $200 href $200);
%mend load_specs;
