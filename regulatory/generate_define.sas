/* generate_define.sas
   Regulatory-grade define.xml automation with comprehensive validation and logging. */

%include "macros/cdisc_init.sas";
%include "macros/util_metadata.sas";
%include "macros/cdisc_logging.sas";

%macro generate_define(
    study_config = config/config_study.sas,
    project_root =,
    spec_path =,
    codelist_path =,
    valuelvl_path =,
    spec_toc_path =,
    artifact_manifest =,
    annot_crf_pdf =,
    reviewer_guide =,
    dataset_spec =,
    output_index =,
    out_define_xml =,
    log_dir =,
    fail_on_missing = YES
);

  %local _start_time _end_time _status _fail _issue_count _message_esc _spec_loaded _cl_loaded
         _vl_loaded _toc_loaded _artifact_list _domain_count _domain_list _artifact_missing
         _fail_flag severity_option _nobs __temp_path __dir _missing_spec _dupcount
         _orphan_count _valuelvl_missing _toc_missing_count _study_xml _protocol_xml;

  %let _start_time=%sysfunc(datetime());
  %let _status=SUCCESS;
  %let _fail=0;
  %let _issue_count=0;

  %if %length(&project_root) %then %do;
    %cdisc_init(study_config=&study_config., project_root=&project_root.);
  %end;
  %else %do;
    %cdisc_init(study_config=&study_config.);
  %end;

  %set_project_paths;

  %if %sysevalf(%superq(studyid)=, boolean) %then %let studyid=UNKNOWN_STUDY;
  %if %sysevalf(%superq(protocol)=, boolean) %then %let protocol=UNKNOWN_PROTOCOL;

  %local _study_xml _protocol_xml;
  data _null_;
    length study protocol $500;
    study = xmlencode(symget('studyid'));
    protocol = xmlencode(symget('protocol'));
    call symputx('_study_xml', strip(study), 'L');
    call symputx('_protocol_xml', strip(protocol), 'L');
  run;

  %if %sysevalf(%superq(spec_path)=, boolean) %then %let spec_path=&spec_dir./spec_define.csv;
  %if %sysevalf(%superq(codelist_path)=, boolean) %then %let codelist_path=&spec_dir./spec_codelist.csv;
  %if %sysevalf(%superq(valuelvl_path)=, boolean) %then %let valuelvl_path=&spec_dir./spec_valuelevel.csv;
  %if %sysevalf(%superq(spec_toc_path)=, boolean) %then %let spec_toc_path=&spec_dir./spec_toc.csv;
  %if %sysevalf(%superq(output_index)=, boolean) %then %let output_index=&output_root./regulatory/artifact_index.csv;
  %if %sysevalf(%superq(out_define_xml)=, boolean) %then %let out_define_xml=&output_root./regulatory/define.xml;
  %if %sysevalf(%superq(log_dir)=, boolean) %then %let log_dir=&output_root./logs;

  options dlcreatedir;
  libname _logdir "&log_dir.";
  %if %sysfunc(libref(_logdir)) %then %do;
    %put WARNING: Unable to establish log directory &log_dir.;
  %end;
  %else %do;
    libname _logdir clear;
  %end;

  %start_log(step_name=generate_define, logdir=&log_dir.);

  proc sql;
    create table work._define_issues
    (
      code char(12),
      severity char(8),
      message char(500)
    );
  quit;

  %macro _log_issue(code=, message=, severity=ERROR);
    %global _issue_count;
    %local _msg_clean _sev;
    %let _issue_count=%eval(&_issue_count+1);
    %let _msg_clean=%sysfunc(tranwrd(%superq(message), %str(%'), %str(%'')));
    %let _sev=%upcase(&severity.);
    %put &_sev.: (&code.) %superq(message);
    proc sql;
      insert into work._define_issues
      set code="&code.", severity="&_sev.", message="&_msg_clean.";
    quit;
    %if &_sev=ERROR or &_sev=FATAL %then %do;
      %if %upcase(&fail_on_missing.)=YES %then %let _fail=1;
      %else %if &_sev=FATAL %then %let _fail=1;
      %if &_status ne FAILED %then %let _status=FAILED;
    %end;
    %if &_sev=WARNING and &_status=SUCCESS %then %let _status=WARNING;
  %mend;

  %macro _check_required_file(path=, label=, code=DEF0001);
    %if %sysevalf(%superq(path)=, boolean) %then %do;
      %_log_issue(code=&code., severity=%sysfunc(ifc(%upcase(&fail_on_missing.)=YES,ERROR,WARNING)),
        message=&label. location not provided.);
      %return;
    %end;
    %if %sysfunc(fileexist(%superq(path)))=0 %then %do;
      %_log_issue(code=&code., severity=%sysfunc(ifc(%upcase(&fail_on_missing.)=YES,ERROR,WARNING)),
        message=&label. not found at %superq(path).);
      %return;
    %end;
    %put NOTE: &label. found at %superq(path).;
  %mend;

  %macro _ensure_dir(path=, label=, code=DEF0007);
    %if %sysevalf(%superq(path)=, boolean) %then %return;
    %global __path_holder __dir_holder;
    %let __path_holder=%superq(path);
    data _null_;
      length path dir $500;
      path = symget('__path_holder');
      dir = '';
      if not missing(path) then do;
        length pos 8;
        pos = findc(path, '/\', 'b');
        if pos>1 then dir = substr(path, 1, pos-1);
      end;
      call symputx('__dir_holder', dir, 'L');
    run;
    %if %sysevalf(%superq(__dir_holder)=, boolean) %then %return;
    %let __dir_ref=%sysfunc(filename(__dirref, %superq(__dir_holder)));
    %if &__dir_ref = 0 %then %do;
      %let __dir_did=%sysfunc(dopen(__dirref));
      %if &__dir_did = 0 %then %do;
        %_log_issue(code=&code., severity=%sysfunc(ifc(%upcase(&fail_on_missing.)=YES,ERROR,WARNING)),
          message=&label. directory %superq(__dir_holder) is missing or inaccessible.);
      %end;
      %else %do;
        %let __dir_close=%sysfunc(dclose(&__dir_did.));
      %end;
      %let __dir_clear=%sysfunc(filename(__dirref));
    %end;
  %mend;

  %macro _ensure_columns(ds=, columns=, code=DEF0010, label=metadata);
    %local lib mem i column exists;
    %let lib=%upcase(%scan(&ds., 1, .));
    %let mem=%upcase(%scan(&ds., 2, .));
    %if %length(&mem.)=0 %then %do;
      %let mem=&lib.;
      %let lib=WORK;
    %end;
    %do i=1 %to %sysfunc(countw(&columns., %str( )));
      %let column=%upcase(%scan(&columns., &i., %str( )));
      proc sql noprint;
        select count(*) into :exists
        from dictionary.columns
        where libname="&lib." and memname="&mem." and upcase(name)="&column.";
      quit;
      %if &exists = 0 %then %do;
        %_log_issue(code=&code., severity=%sysfunc(ifc(%upcase(&fail_on_missing.)=YES,ERROR,WARNING)),
          message=Required column &column. missing from &label. dataset &ds.);
      %end;
    %end;
  %mend;

  %_check_required_file(path=&spec_path., label=Specification metadata, code=DEF0100);
  %_check_required_file(path=&codelist_path., label=Codelist metadata, code=DEF0101);
  %_check_required_file(path=&spec_toc_path., label=Specification table of contents, code=DEF0102);
  %if %sysfunc(fileexist(%superq(valuelvl_path))) %then %do;
    %put NOTE: Value-level metadata detected at %superq(valuelvl_path).;
  %end;
  %else %do;
    %_log_issue(code=DEF0103, severity=%sysfunc(ifc(%upcase(&fail_on_missing.)=YES,ERROR,WARNING)),
      message=Value-level metadata file missing at %superq(valuelvl_path).);
  %end;

  %if %sysfunc(fileexist(%superq(spec_path))) %then %do;
    %read_spec(file=&spec_path., out=_define_spec_raw);
    data _define_spec;
      set _define_spec_raw;
      length DOMAIN VARIABLE TYPE LABEL CODELIST $200;
      DOMAIN = upcase(coalescec(DOMAIN, TABLE, DATASET));
      VARIABLE = strip(coalescec(VARIABLE, COLUMN, NAME));
      TYPE = upcase(coalescec(TYPE, DATA_TYPE, DATATYPE));
      LABEL = coalescec(LABEL, DESCRIPTION, COMMENT, VARIABLE_LABEL);
      CODELIST = strip(coalescec(CODELIST, FORMAT, TERMID));
      length ORDERNUM 8;
      if not missing(ORDER) then ORDERNUM=ORDER;
      else if not missing(ORDINAL) then ORDERNUM=ORDINAL;
      else if not missing(VARIABLE_ORDER) then ORDERNUM=VARIABLE_ORDER;
      else ORDERNUM=_N_;
      length DOMAIN_XML VARIABLE_XML LABEL_XML CODELIST_XML TYPE_XML $512;
      DOMAIN_XML = strip(xmlencode(coalescec(DOMAIN, '')));
      VARIABLE_XML = strip(xmlencode(coalescec(VARIABLE, '')));
      LABEL_XML = strip(xmlencode(coalescec(LABEL, '')));
      CODELIST_XML = strip(xmlencode(coalescec(CODELIST, '')));
      TYPE_XML = strip(xmlencode(coalescec(TYPE, '')));
    run;
    %_ensure_columns(ds=_define_spec, columns=DOMAIN VARIABLE TYPE ORDERNUM, code=DEF0110, label=specification metadata);
    proc sql noprint;
      select count(*) into :_nobs from _define_spec;
    quit;
    %if &_nobs = 0 %then %_log_issue(code=DEF0111, severity=%sysfunc(ifc(%upcase(&fail_on_missing.)=YES,ERROR,WARNING)),
      message=Specification metadata contains no active records.);
    proc sort data=_define_spec out=_define_spec_sort nodupkey dupout=_dup_spec;
      by DOMAIN VARIABLE;
    run;
    %if %sysfunc(exist(_dup_spec)) %then %do;
      proc sql noprint;
        select count(*) into :_dupcount from _dup_spec;
      quit;
      %if %sysevalf(%superq(_dupcount)=, boolean) %then %let _dupcount=0;
      %if &_dupcount > 0 %then %_log_issue(code=DEF0112,
        severity=%sysfunc(ifc(%upcase(&fail_on_missing.)=YES,ERROR,WARNING)),
        message=Duplicate DOMAIN/VARIABLE combinations detected in specification metadata: &_dupcount records.);
    %end;
    proc sql noprint;
      select count(*) into :_missing_spec
      from _define_spec
      where missing(DOMAIN) or missing(VARIABLE);
    quit;
    %if %sysevalf(%superq(_missing_spec)=, boolean) %then %let _missing_spec=0;
    %if &_missing_spec > 0 %then
      %_log_issue(code=DEF0113, severity=%sysfunc(ifc(%upcase(&fail_on_missing.)=YES,ERROR,WARNING)),
        message=Specification metadata contains &_missing_spec entries with missing domain or variable.);
  %end;

  %if %sysfunc(fileexist(%superq(codelist_path))) %then %do;
    %read_spec(file=&codelist_path., out=_define_codelist_raw);
    data _define_codelist;
      set _define_codelist_raw;
      length DOMAIN VARIABLE CODELIST CODE VALUE DECODING $200;
      DOMAIN = upcase(coalescec(DOMAIN, TABLE, DATASET));
      VARIABLE = strip(coalescec(VARIABLE, COLUMN, NAME));
      CODELIST = strip(coalescec(CODELIST, NAME, CODELIST_NAME));
      CODE = strip(coalescec(CODE, VAL, CODE_VALUE));
      VALUE = strip(coalescec(VALUE, MEANING, LABEL));
      DECODING = coalescec(DECODING, DECODE, DEFINITION, VALUE_LABEL);
      length CODE_XML DECODING_XML CODELIST_XML DOMAIN_XML VARIABLE_XML $512;
      CODE_XML = strip(xmlencode(coalescec(CODE, '')));
      DECODING_XML = strip(xmlencode(coalescec(DECODING, VALUE, '')));
      CODELIST_XML = strip(xmlencode(coalescec(CODELIST, '')));
      DOMAIN_XML = strip(xmlencode(coalescec(DOMAIN, '')));
      VARIABLE_XML = strip(xmlencode(coalescec(VARIABLE, '')));
    run;
    %_ensure_columns(ds=_define_codelist, columns=DOMAIN VARIABLE CODELIST, code=DEF0120, label=codelist metadata);
    proc sql;
      create table _codelist_orphans as
      select distinct c.DOMAIN, c.VARIABLE, c.CODELIST
      from _define_codelist as c
      left join _define_spec as s
        on upcase(c.DOMAIN)=upcase(s.DOMAIN)
       and upcase(c.VARIABLE)=upcase(s.VARIABLE)
      where missing(s.VARIABLE);
    quit;
    %if %sysfunc(exist(_codelist_orphans)) %then %do;
      proc sql noprint;
        select count(*) into :_orphan_count from _codelist_orphans;
      quit;
      %if %sysevalf(%superq(_orphan_count)=, boolean) %then %let _orphan_count=0;
      %if &_orphan_count > 0 %then
        %_log_issue(code=DEF0121, severity=%sysfunc(ifc(%upcase(&fail_on_missing.)=YES,ERROR,WARNING)),
          message=Codelist metadata references &_orphan_count domains or variables absent from specification metadata.);
    %end;
  %end;

  %if %sysfunc(fileexist(%superq(valuelvl_path))) %then %do;
    %read_spec(file=&valuelvl_path., out=_define_valuelvl_raw);
    data _define_valuelvl;
      set _define_valuelvl_raw;
      length DOMAIN VARIABLE WHERE_CLAUSE PARENT_VARIABLE $200;
      DOMAIN = upcase(coalescec(DOMAIN, TABLE, DATASET));
      VARIABLE = strip(coalescec(VARIABLE, COLUMN, VALUE_VARIABLE));
      PARENT_VARIABLE = strip(coalescec(PARENT_VARIABLE, PARENTVAR, TARGET_VARIABLE));
      WHERE_CLAUSE = coalescec(WHERE_CLAUSE, WHERECLAUSE, CRITERIA);
      length DOMAIN_XML VARIABLE_XML PARENT_XML WHERE_XML $512;
      DOMAIN_XML = strip(xmlencode(coalescec(DOMAIN, '')));
      VARIABLE_XML = strip(xmlencode(coalescec(VARIABLE, '')));
      PARENT_XML = strip(xmlencode(coalescec(PARENT_VARIABLE, '')));
      WHERE_XML = strip(xmlencode(coalescec(WHERE_CLAUSE, '')));
    run;
    %_ensure_columns(ds=_define_valuelvl, columns=DOMAIN VARIABLE PARENT_VARIABLE, code=DEF0130, label=value-level metadata);
    proc sql;
      create table _valuelvl_parent as
      select distinct v.DOMAIN, v.PARENT_VARIABLE
      from _define_valuelvl as v
      left join _define_spec as s
        on upcase(v.DOMAIN)=upcase(s.DOMAIN)
       and upcase(v.PARENT_VARIABLE)=upcase(s.VARIABLE)
      where missing(s.VARIABLE);
    quit;
    %if %sysfunc(exist(_valuelvl_parent)) %then %do;
      proc sql noprint;
        select count(*) into :_valuelvl_missing from _valuelvl_parent;
      quit;
      %if %sysevalf(%superq(_valuelvl_missing)=, boolean) %then %let _valuelvl_missing=0;
      %if &_valuelvl_missing > 0 %then
        %_log_issue(code=DEF0131, severity=%sysfunc(ifc(%upcase(&fail_on_missing.)=YES,ERROR,WARNING)),
          message=Value-level metadata references &_valuelvl_missing parent variables absent from specification metadata.);
    %end;
  %end;

  %if %sysfunc(fileexist(%superq(spec_toc_path))) %then %do;
    %read_spec(file=&spec_toc_path., out=_define_toc_raw);
    data _define_toc;
      set _define_toc_raw;
      length DOMAIN $32 TYPE $8 ACTIVE $1;
      DOMAIN = upcase(strip(coalescec(DOMAIN, DATASET)));
      TYPE = upcase(strip(coalescec(TYPE, STANDARD)));
      ACTIVE = upcase(strip(coalescec(ACTIVE, STATUS)));
    run;
    proc sql;
      create table _toc_missing_domains as
      select distinct t.DOMAIN
      from _define_toc as t
      where upcase(coalescec(t.ACTIVE, 'N'))='Y'
        and not exists (
          select 1 from _define_spec as s
          where upcase(s.DOMAIN)=upcase(t.DOMAIN)
        );
    quit;
    %if %sysfunc(exist(_toc_missing_domains)) %then %do;
      proc sql noprint;
        select count(*) into :_toc_missing_count from _toc_missing_domains;
      quit;
      %if %sysevalf(%superq(_toc_missing_count)=, boolean) %then %let _toc_missing_count=0;
      %if &_toc_missing_count > 0 %then
        %_log_issue(code=DEF0140, severity=%sysfunc(ifc(%upcase(&fail_on_missing.)=YES,ERROR,WARNING)),
          message=Active domains in specification TOC missing from specification metadata: &_toc_missing_count records.);
    %end;
  %end;

  %macro _artifact_append(name=, path=, type=);
    %if %sysevalf(%superq(path)=, boolean)=0 %then %do;
      %local _path_clean;
      %let _path_clean=%sysfunc(tranwrd(%superq(path), %str(%'), %str(%'')));
      proc sql;
        insert into work._artifact_index
        set artifact_name="&name.",
            artifact_path="&_path_clean.",
            artifact_type="&type.",
            last_updated="%sysfunc(datetime(), is8601dt.)";
      quit;
    %end;
  %mend;

  data work._artifact_index;
    length artifact_name artifact_type $200 artifact_path $512 last_updated $25;
    stop;
  run;

  %if %sysfunc(fileexist(%superq(artifact_manifest))) %then %do;
    %read_spec(file=&artifact_manifest., out=_artifact_manifest_raw);
    data _artifact_manifest;
      set _artifact_manifest_raw;
      length artifact_name artifact_path artifact_type $200;
      artifact_name = strip(coalescec(artifact_name, NAME, TITLE));
      artifact_path = strip(coalescec(artifact_path, PATH, LOCATION));
      artifact_type = strip(coalescec(artifact_type, TYPE, CATEGORY));
      if missing(artifact_name) then artifact_name=strip(cats('Artifact_', _N_));
    run;
    %_ensure_columns(ds=_artifact_manifest, columns=artifact_name artifact_path artifact_type, code=DEF0150, label=artifact manifest);
    data work._artifact_index;
      set _artifact_manifest;
      length last_updated $25;
      last_updated="%sysfunc(datetime(), is8601dt.)";
      keep artifact_name artifact_path artifact_type last_updated;
    run;
  %end;

  %_artifact_append(name=Annotated CRF, path=&annot_crf_pdf., type=aCRF);
  %_artifact_append(name=Reviewer Guide, path=&reviewer_guide., type=RG);
  %_artifact_append(name=Dataset Specifications, path=&dataset_spec., type=Spec);

  %_artifact_append(name=Define XML, path=&out_define_xml., type=DefineXML);

  data _null_;
    set work._artifact_index;
    if missing(artifact_path) then call execute('%_log_issue(code=DEF0151, severity=' ||
      quote(%sysfunc(ifc(%upcase(&fail_on_missing.)=YES,ERROR,WARNING))) ||
      ', message=Artifact ' || quote(trim(artifact_name)) || ' does not have a resolved path. )');
    else if fileexist(strip(artifact_path))=0 then call execute('%_log_issue(code=DEF0152, severity=' ||
      quote(%sysfunc(ifc(%upcase(&fail_on_missing.)=YES,ERROR,WARNING))) ||
      ', message=Artifact ' || quote(trim(artifact_name)) || ' missing at ' || quote(strip(artifact_path)) || '. )');
    else putlog 'NOTE: Artifact ' artifact_name ' -> ' artifact_path;
  run;

  %_ensure_dir(path=&out_define_xml., label=define.xml output, code=DEF0200);
  %_ensure_dir(path=&output_index., label=artifact index output, code=DEF0201);

  %macro export_define_xml(metadata=, codelist=, valuelvl=, output=, artifacts=);
    %local domain_list domain_count i domain_label;
    proc sort data=&metadata out=_meta_sorted;
      by DOMAIN ORDERNUM;
    run;
    proc sql noprint;
      select distinct DOMAIN into :domain_list separated by ' '
      from _meta_sorted
      where not missing(DOMAIN)
      order by DOMAIN;
    quit;
    %let domain_count=%sysfunc(countw(&domain_list.));

    %if %sysfunc(exist(&artifacts.)) %then %do;
      data _artifact_links;
        set &artifacts.;
        length artifact_name_xml artifact_path_xml artifact_type_xml $512;
        artifact_name_xml = strip(xmlencode(coalescec(artifact_name, '')));
        artifact_path_xml = strip(xmlencode(coalescec(artifact_path, '')));
        artifact_type_xml = strip(xmlencode(coalescec(artifact_type, '')));
      run;
    %end;

    filename _defxml "&output." encoding='utf-8';
    data _null_;
      file _defxml lrecl=32767;
      put '<?xml version="1.0" encoding="UTF-8"?>';
      put '<ODM xmlns="http://www.cdisc.org/ns/odm/v1.3"';
      put '     xmlns:xlink="http://www.w3.org/1999/xlink"';
      put '     xmlns:def="http://www.cdisc.org/ns/def/v2.1"';
      put '     FileType="Snapshot" ODMVersion="1.3.2" FileOID="DEFINE.FILE" CreationDateTime="' "%sysfunc(datetime(), is8601dt.)" '"';
      put '     SourceSystem="Clinical Programming Portfolio" SourceSystemVersion="1.0">';
      put '  <Study OID="STUDY.OID">';
      put '    <GlobalVariables>';
      put '      <StudyName>' "&_study_xml." '</StudyName>';
      put '      <StudyDescription>Define-XML generated from metadata-driven pipeline.</StudyDescription>';
      put '      <ProtocolName>' "&_protocol_xml." '</ProtocolName>';
      put '    </GlobalVariables>';
      put '    <MetaDataVersion OID="MDV.STUDY" Name="Study Metadata" StandardName="CDISC Define-XML" StandardVersion="2.1">';
    run;

    %if %sysfunc(exist(_artifact_links)) %then %do;
      data _null_;
        set _artifact_links;
        file _defxml mod lrecl=32767;
        put '      <def:SupplementalDoc xlink:href="' artifact_path_xml '" def:DocumentType="' artifact_type_xml '">';
        put '        <def:Description>' artifact_name_xml +(-1) '</def:Description>';
        put '      </def:SupplementalDoc>';
      run;
    %end;

    %do i=1 %to &domain_count.;
      %let domain=%scan(&domain_list., &i.);
      data _null_;
        set _meta_sorted(where=(DOMAIN="&domain.")) end=last;
        file _defxml mod lrecl=32767;
        if _n_=1 then do;
          put '      <ItemGroupDef OID="IG.&domain." Domain="' DOMAIN_XML '" Name="' DOMAIN_XML '" Repeating="No" IsReferenceData="No">';
        end;
        length itemoid $200;
        itemoid = cats('IT.', DOMAIN, '.', VARIABLE);
        put '        <ItemRef ItemOID="' itemoid '" OrderNumber="' ORDERNUM '" Mandatory="No"/>';
        if last then do;
          put '      </ItemGroupDef>';
        end;
      run;
    %end;

    data _null_;
      set _meta_sorted;
      file _defxml mod lrecl=32767;
      length itemoid $200;
      itemoid = cats('IT.', DOMAIN, '.', VARIABLE);
      put '      <ItemDef OID="' itemoid '" Name="' VARIABLE_XML '" DataType="' TYPE_XML '" Length="200">';
      if not missing(LABEL) then put '        <Description><TranslatedText xml:lang="en">' LABEL_XML +(-1) '</TranslatedText></Description>';
      if not missing(CODELIST) then put '        <CodeListRef CodeListOID="CL.' CODELIST '"/>';
      put '      </ItemDef>';
    run;

    %if %sysfunc(exist(&codelist.)) %then %do;
      proc sort data=&codelist out=_codelist_sorted;
        by CODELIST CODE;
      run;
      data _null_;
        set _codelist_sorted;
        by CODELIST;
        file _defxml mod lrecl=32767;
        if first.CODELIST then do;
          put '      <CodeList OID="CL.' CODELIST '" Name="' CODELIST_XML '" DataType="text">';
        end;
        put '        <CodeListItem CodedValue="' CODE_XML '" OrderNumber="' _N_ '"><Decode><TranslatedText xml:lang="en">' DECODING_XML +(-1) '</TranslatedText></Decode></CodeListItem>';
        if last.CODELIST then put '      </CodeList>';
      run;
    %end;

    %if %sysfunc(exist(&valuelvl.)) %then %do;
      proc sort data=&valuelvl out=_vl_sorted;
        by DOMAIN PARENT_VARIABLE VARIABLE;
      run;
      data _vl_sorted;
        set _vl_sorted;
        by DOMAIN PARENT_VARIABLE;
        retain seq 0;
        if first.PARENT_VARIABLE then seq=0;
        seq+1;
        length VALUEOID WHEREOID $200;
        VALUEOID = cats('VL.', DOMAIN, '.', PARENT_VARIABLE, '.', seq);
        WHEREOID = cats('WC.', DOMAIN, '.', PARENT_VARIABLE, '.', seq);
      run;
      data _null_;
        set _vl_sorted;
        by DOMAIN PARENT_VARIABLE;
        file _defxml mod lrecl=32767;
        if first.PARENT_VARIABLE then do;
          put '      <ValueListDef OID="VL.' DOMAIN '.' PARENT_VARIABLE '" ItemOID="IT.' DOMAIN '.' PARENT_VARIABLE '">';
        end;
        if not missing(WHERE_CLAUSE) then do;
          put '        <ItemRef ItemOID="IT.' DOMAIN '.' VARIABLE '" Mandatory="No">';
          put '          <WhereClauseRef WhereClauseOID="' WHEREOID '"/>';
          put '        </ItemRef>';
        end;
        else do;
          put '        <ItemRef ItemOID="IT.' DOMAIN '.' VARIABLE '" Mandatory="No"/>';
        end;
        if last.PARENT_VARIABLE then do;
          put '      </ValueListDef>';
        end;
      run;
      data _null_;
        set _vl_sorted;
        where not missing(WHERE_CLAUSE);
        file _defxml mod lrecl=32767;
        put '      <WhereClauseDef OID="' WHEREOID '">';
        put '        <FormalExpression Context="SAS">' WHERE_XML +(-1) '</FormalExpression>';
        put '      </WhereClauseDef>';
      run;
    %end;

    data _null_;
      file _defxml mod lrecl=32767;
      put '    </MetaDataVersion>';
      put '  </Study>';
      put '  <def:Define Version="2.1"/>';
      put '</ODM>';
    run;
  %mend;

  %if %sysfunc(fileexist(%superq(out_define_xml))) %then %do;
    %put NOTE: Existing define.xml will be overwritten: &out_define_xml.;
  %end;

  %export_define_xml(metadata=_define_spec, codelist=_define_codelist, valuelvl=_define_valuelvl, output=&out_define_xml., artifacts=work._artifact_index);

  %if %sysfunc(exist(work._artifact_index)) %then %do;
    proc export data=work._artifact_index outfile="&output_index." dbms=csv replace;
      putnames=yes;
    run;
  %end;

  %let _end_time=%sysfunc(datetime());
  %if &_fail and %upcase(&fail_on_missing.)=YES %then %do;
    %let _status=FAILED;
  %end;

  %put NOTE: define.xml build completed in %sysevalf(&_end_time - &_start_time) seconds.;
  %end_log(step_name=generate_define, status=&_status.);

  %if &_fail and %upcase(&fail_on_missing.)=YES %then %do;
    %put ERROR: Pipeline terminating due to blocking issues. See log for details.;
    %abort cancel;
  %end;

%mend generate_define;

/* Example invocation:
%generate_define(
  project_root=%sysfunc(getoption(work)),
  spec_path=%sysfunc(getoption(work))/specs/spec_define.csv,
  codelist_path=%sysfunc(getoption(work))/specs/spec_codelist.csv,
  valuelvl_path=%sysfunc(getoption(work))/specs/spec_valuelevel.csv,
  annot_crf_pdf=outputs/annotated/acrf.pdf,
  reviewer_guide=outputs/guides/reviewer_guide.pdf,
  dataset_spec=specs/dataset_specifications.xlsx,
  out_define_xml=outputs/regulatory/define.xml
);
*/
