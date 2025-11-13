/* util_metadata.sas
   Metadata helper macros used throughout the CDISC pipeline. */

%macro set_project_paths;
  %global project_root spec_dir raw_dir interim_dir reference_dir output_root;
  %if %sysevalf(%superq(project_root)=, boolean) %then %do;
    %let project_root=%sysfunc(pathname(work));
    %put WARNING: project_root not supplied. Defaulting to WORK directory: &project_root.;
  %end;
  %let spec_dir=&project_root./specs;
  %let raw_dir=&project_root./data/raw;
  %let interim_dir=&project_root./data/interim;
  %let reference_dir=&project_root./data/reference;
  %let output_root=&project_root./outputs;
%mend;

%macro read_spec(file=, sheet=, out=spec_data);
  %local ext dbms sheet_stmt;
  %let ext=%upcase(%scan(&file., -1, .));
  %if &ext = CSV %then %do;
    %let dbms=csv;
    %let sheet_stmt=;
  %end;
  %else %if &ext = XLSX %then %do;
    %let dbms=xlsx;
    %if %length(&sheet.) %then %let sheet_stmt=sheet="&sheet.";
    %else %let sheet_stmt=;
  %end;
  %else %do;
    %let dbms=csv;
    %let sheet_stmt=;
    %put WARNING: Unrecognised extension &ext. Importing &file. as CSV.;
  %end;

  proc import datafile="&file." dbms=&dbms out=&out. replace;
    guessingrows=max;
    %if %length(&sheet_stmt.) %then &sheet_stmt.;
  run;
%mend;

%macro get_domain_list(type=ALL, outmacro=dom_list);
  %read_spec(file=&spec_dir./spec_toc.csv, out=_toc);
  data _toc2;
    set _toc;
    where upcase(active_flag)='Y';
    %if %upcase(&type.) ne ALL %then %do;
      if upcase(standard) ne "%upcase(&type.)" then delete;
    %end;
  run;
  proc sql noprint;
    select strip(domain) into :&outmacro separated by ' '
    from _toc2;
  quit;
%mend;

%macro open_sdtm_mapping(out=map_data);
  %read_spec(file=&spec_dir./sdtm_mapping.csv, out=&out.);
%mend;

%macro apply_metadata(source=, map=, out=);
  %local nobs;
  data _mapping;
    set &map.;
  run;
  data _null_;
    if 0 then set _mapping nobs=n;
    call symputx('nobs', n, 'L');
    stop;
  run;
  data &out.;
    set &source.;
    %do i=1 %to &nobs.;
      set _mapping point=&i. nobs=_nobs;
      if not missing(strip(sdtm_variable)) then do;
        length target $200 expression $500;
        target = strip(sdtm_variable);
        expression = strip(derivation_rule);
        if missing(expression) or upcase(expression) = 'DIRECT MAPPING' then do;
          call execute(cats(target, ' = ', strip(raw_variable), ';'));
        end;
        else call execute(cats(target, ' = ', expression, ';'));
      end;
    end;
    stop;
  run;
%mend;
