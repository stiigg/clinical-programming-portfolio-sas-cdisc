/* define_write_xml_v21.sas
   Serialize Define-XML 2.1 documents from prepared metadata tables. */

%macro define_write_xml_v21(
  standard = SDTM,
  inlib    = work,
  outxml   =,
  studyid  = DEMO_STUDY,
  version  = 2.1.0,
  standard_version = 1.0,
  standard_name =
);
  %local std _outxml _outdir _domain_list _domain_count _created _study_clean;
  %let std=%upcase(&standard.);
  %let inlib=%upcase(&inlib.);

  %if %sysevalf(%superq(outxml)=, boolean) %then %let _outxml=%sysfunc(pathname(work))/define_&std..xml;
  %else %let _outxml=&outxml.;

  %if %sysevalf(%superq(standard_name)=, boolean) %then %let standard_name=&std.;

  %if ^%sysfunc(exist(&inlib..def_itemgroup)) %then %do;
    %put ERROR: Required dataset &inlib..def_itemgroup not found. Run %nrstr(%define_build_meta) first.;
    %return;
  %end;
  %if ^%sysfunc(exist(&inlib..def_itemref)) %then %do;
    %put ERROR: Required dataset &inlib..def_itemref not found. Run %nrstr(%define_build_meta) first.;
    %return;
  %end;
  %if ^%sysfunc(exist(&inlib..def_itemdef)) %then %do;
    %put ERROR: Required dataset &inlib..def_itemdef not found. Run %nrstr(%define_build_meta) first.;
    %return;
  %end;
  %if ^%sysfunc(exist(&inlib..def_codelist)) %then %do;
    %put ERROR: Required dataset &inlib..def_codelist not found. Run %nrstr(%define_build_meta) first.;
    %return;
  %end;
  %if ^%sysfunc(exist(&inlib..def_codelist_item)) %then %do;
    %put ERROR: Required dataset &inlib..def_codelist_item not found. Run %nrstr(%define_build_meta) first.;
    %return;
  %end;
  %if ^%sysfunc(exist(&inlib..def_methoddef)) %then %do;
    %put ERROR: Required dataset &inlib..def_methoddef not found. Run %nrstr(%define_build_meta) first.;
    %return;
  %end;
  %if ^%sysfunc(exist(&inlib..def_whereclause)) %then %do;
    %put ERROR: Required dataset &inlib..def_whereclause not found. Run %nrstr(%define_build_meta) first.;
    %return;
  %end;
  %if ^%sysfunc(exist(&inlib..def_valuelist)) %then %do;
    %put ERROR: Required dataset &inlib..def_valuelist not found. Run %nrstr(%define_build_meta) first.;
    %return;
  %end;
  %if ^%sysfunc(exist(&inlib..def_valuelist_map)) %then %do;
    %put ERROR: Required dataset &inlib..def_valuelist_map not found. Run %nrstr(%define_build_meta) first.;
    %return;
  %end;

  data _null_;
    length study $200 cleaned $200;
    study = symget('studyid');
    cleaned = prxchange('s/\s+/_/o', -1, strip(study));
    if missing(cleaned) then cleaned = 'STUDY';
    call symputx('_study_clean', cleaned, 'L');
  run;

  data _null_;
    length path dir $500;
    path = symget('_outxml');
    if not missing(path) then do;
      length pos 8;
      pos = findc(path, '/\\', -length(path));
      if pos>0 then dir = substr(path, 1, pos-1);
      else dir = '';
    end;
    call symputx('_outdir', dir, 'L');
  run;

  %if %sysevalf(%superq(_outdir)^=, boolean) %then %do;
    options dlcreatedir;
    libname __defdir "&_outdir.";
    %if %sysfunc(libref(__defdir))=0 %then %do;
      libname __defdir clear;
    %end;
  %end;

  filename defout "&_outxml." encoding='utf-8';

  %let _created=%sysfunc(datetime(), e8601dt.);

  proc sort data=&inlib..def_itemgroup(where=(standard="&std")) out=__ig;
    by order_num domain;
  run;

  proc sort data=&inlib..def_itemref(where=(standard="&std")) out=__ir;
    by domain ordernumber var_name;
  run;

  proc sort data=&inlib..def_itemdef(where=(standard="&std")) out=__id;
    by domain ordernumber var_name;
  run;

  proc sort data=&inlib..def_codelist out=__cl;
    by codelist_id;
  run;

  proc sort data=&inlib..def_codelist_item out=__cli;
    by codelist_id decode_order code;
  run;

  proc sort data=&inlib..def_methoddef out=__md;
    by method_id;
  run;

  proc sort data=&inlib..def_valuelist(where=(standard="&std")) out=__vl;
    by valuelist_oid;
  run;

  proc sort data=&inlib..def_valuelist_map(where=(standard="&std")) out=__vlm;
    by valuelist_oid where_clause_id;
  run;

  proc sort data=&inlib..def_whereclause out=__wc;
    by where_clause_id;
  run;

  data _null_;
    file defout;
    length study_nm std_name_enc $200;
    study_nm = xmlencode(symget('studyid'));
    std_name_enc = xmlencode(symget('standard_name'));
    put '<?xml version="1.0" encoding="UTF-8"?>';
    put '<ODM xmlns="http://www.cdisc.org/ns/odm/v1.3"';
    put '     xmlns:def="http://www.cdisc.org/ns/def/v2.1"';
    put '     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"';
    put '     CreationDateTime="' "&_created." '"';
    put '     FileOID="DEF.' "&_study_clean." '.' "&std." '"';
    put '     FileType="Snapshot"';
    put '     ODMVersion="1.3.2"';
    put '     def:DefineVersion="' "&version." '"';
    put '     def:StandardName="' std_name_enc +(-1) '"';
    put '     def:StandardVersion="' "&standard_version." '"';
    put '     xsi:schemaLocation="http://www.cdisc.org/ns/odm/v1.3 odm1-3-2.xsd">';
    put '  <Study OID="STUDY.' "&_study_clean." '">';
    put '    <GlobalVariables>';
    put '      <StudyName>' study_nm +(-1) '</StudyName>';
    put '      <StudyDescription>' study_nm +(-1) '</StudyDescription>';
    put '      <ProtocolName>' study_nm +(-1) '</ProtocolName>';
    put '    </GlobalVariables>';
    put '    <MetaDataVersion OID="MDV.' "&std." '" Name="' std_name_enc +(-1) '" def:StandardName="' std_name_enc +(-1) '" def:StandardVersion="' "&standard_version." '">';
  run;

  proc sql noprint;
    select domain into :_domain_list separated by ' '
    from __ig;
  quit;
  %let _domain_count=%sysfunc(countw(&_domain_list.));

  %do di=1 %to &_domain_count.;
    %let _domain=%scan(&_domain_list., &di.);

    data _null_;
      set __ig;
      where domain="&_domain";
      file defout mod;
      length name_enc label_enc class_enc purpose_enc struct_enc $400 line $1000;
      name_enc = xmlencode(name);
      label_enc = xmlencode(label);
      class_enc = xmlencode(class);
      purpose_enc = xmlencode(coalescec(purpose, 'Tabulation'));
      struct_enc = xmlencode(structure);
      line = cats('    <ItemGroupDef OID="', strip(oid), '" Name="', strip(name_enc), '" def:Label="', strip(label_enc), '"');
      if not missing(class) then line = cats(line, ' def:Class="', strip(class_enc), '"');
      line = cats(line, ' Purpose="', strip(purpose_enc), '" Repeating="No" IsReferenceData="No">');
      put line;
      if not missing(structure) then do;
        put '      <Description>';
        put '        <TranslatedText xml:lang="en">' struct_enc +(-1) '</TranslatedText>';
        put '      </Description>';
      end;
    run;

    data _null_;
      set __ir;
      where domain="&_domain";
      file defout mod;
      length role_enc $200 line $1000 mandatory $3 order_txt key_txt $16;
      mandatory = strip(mandatory_flag);
      order_txt = strip(put(ordernumber, best.));
      line = cats('      <ItemRef ItemOID="', strip(itemoid), '" Mandatory="', mandatory, '" OrderNumber="', order_txt, '"');
      if not missing(keysequence) then do;
        key_txt = strip(put(keysequence, best.));
        line = cats(line, ' KeySequence="', key_txt, '"');
      end;
      if not missing(role) then do;
        role_enc = xmlencode(role);
        line = cats(line, ' def:Role="', strip(role_enc), '"');
      end;
      line = cats(line, ' />');
      put line;
    run;

    data _null_;
      file defout mod;
      put '    </ItemGroupDef>';
    run;
  %end;

  data _null_;
    set __id;
    file defout mod;
    length name_enc label_enc format_enc origin_enc $400 line $1000 length_txt $16;
    name_enc = xmlencode(name);
    label_enc = xmlencode(var_label);
    format_enc = xmlencode(display_format);
    origin_enc = xmlencode(origin);
    line = cats('    <ItemDef OID="', strip(oid), '" Name="', strip(name_enc), '" DataType="', strip(data_type), '"');
    if not missing(length) then do;
      length_txt = strip(put(length, best.));
      line = cats(line, ' Length="', length_txt, '"');
    end;
    line = cats(line, '>');
    put line;
    if not missing(var_label) then do;
      put '      <Description>';
      put '        <TranslatedText xml:lang="en">' label_enc +(-1) '</TranslatedText>';
      put '      </Description>';
    end;
    if not missing(display_format) then do;
      put '      <def:DisplayFormat>' format_enc +(-1) '</def:DisplayFormat>';
    end;
    if not missing(origin) then do;
      put '      <def:Origin Type="' origin_enc +(-1) '"/>';
    end;
    if not missing(codelist_id) then do;
      put '      <CodeListRef CodeListOID="' strip(codelist_id) '"/>';
    end;
    if not missing(method_id) then do;
      put '      <MethodRef MethodOID="' strip(method_id) '"/>';
    end;
    if not missing(valuelist_oid) then do;
      put '      <def:ValueListRef ValueListOID="' strip(valuelist_oid) '"/>';
    end;
    put '    </ItemDef>';
  run;

  proc sql noprint;
    select codelist_id into :_cl_list separated by ' '
    from __cl;
  quit;
  %let _cl_count=%sysfunc(countw(&_cl_list.));

  %do ci=1 %to &_cl_count.;
    %let _clid=%scan(&_cl_list., &ci.);

    data _null_;
      set __cl;
      where codelist_id="&_clid";
      file defout mod;
      length name_enc $400 line $1000;
      name_enc = xmlencode(codelist_name);
      line = cats('    <CodeList OID="', strip(codelist_id), '" Name="', strip(name_enc), '" DataType="text"');
      if not missing(nci_code) then line = cats(line, ' def:ExternalCodeID="', strip(nci_code), '"');
      line = cats(line, '>');
      put line;
    run;

    data _null_;
      set __cli;
      where codelist_id="&_clid";
      file defout mod;
      length decode_enc $400 line $1000;
      decode_enc = xmlencode(decode);
      line = cats('      <EnumeratedItem CodedValue="', strip(code), '">');
      put line;
      put '        <Decode>';
      put '          <TranslatedText xml:lang="en">' decode_enc +(-1) '</TranslatedText>';
      put '        </Decode>';
      put '      </EnumeratedItem>';
    run;

    data _null_;
      file defout mod;
      put '    </CodeList>';
    run;
  %end;

  data _null_;
    set __md;
    file defout mod;
    length desc_enc prog_enc $500 line $1000;
    desc_enc = xmlencode(method_description);
    prog_enc = xmlencode(program_ref);
    line = cats('    <MethodDef OID="', strip(method_id), '" Name="', strip(method_id), '" Type="', strip(method_type), '">');
    put line;
    if not missing(method_description) then do;
      put '      <Description>';
      put '        <TranslatedText xml:lang="en">' desc_enc +(-1) '</TranslatedText>';
      put '      </Description>';
    end;
    if not missing(program_ref) then do;
      put '      <def:ProgrammingCode Context="SAS">' prog_enc +(-1) '</def:ProgrammingCode>';
    end;
    put '    </MethodDef>';
  run;

  proc sql noprint;
    select valuelist_oid into :_vl_list separated by ' '
    from __vl;
  quit;
  %let _vl_count=%sysfunc(countw(&_vl_list.));

  %do vi=1 %to &_vl_count.;
    %let _vlid=%scan(&_vl_list., &vi.);

    data _null_;
      set __vl;
      where valuelist_oid="&_vlid";
      file defout mod;
      put '    <def:ValueListDef OID="' strip(valuelist_oid) '">';
    run;

    data _null_;
      set __vlm;
      where valuelist_oid="&_vlid";
      file defout mod;
      length label_enc expr_enc $400 line $1000;
      label_enc = xmlencode(vlm_label);
      expr_enc = xmlencode(where_clause_expression);
      line = cats('      <def:ItemRef ItemOID="IT.', strip(standard), '.', strip(domain), '.', strip(var_name), '" Mandatory="No">');
      put line;
      if not missing(vlm_label) then do;
        put '        <Description>';
        put '          <TranslatedText xml:lang="en">' label_enc +(-1) '</TranslatedText>';
        put '        </Description>';
      end;
      put '        <def:WhereClauseRef WhereClauseOID="' strip(where_clause_id) '"/>';
      if not missing(codelist_id) then do;
        put '        <CodeListRef CodeListOID="' strip(codelist_id) '"/>';
      end;
      if not missing(method_id) then do;
        put '        <MethodRef MethodOID="' strip(method_id) '"/>';
      end;
      put '      </def:ItemRef>';
    run;

    data _null_;
      file defout mod;
      put '    </def:ValueListDef>';
    run;
  %end;

  data _null_;
    set __wc;
    file defout mod;
    length label_enc expr_enc $400;
    label_enc = xmlencode(vlm_label);
    expr_enc = xmlencode(where_clause_expression);
    put '    <def:WhereClauseDef OID="' strip(where_clause_id) '">';
    if not missing(vlm_label) then do;
      put '      <Description>';
      put '        <TranslatedText xml:lang="en">' label_enc +(-1) '</TranslatedText>';
      put '      </Description>';
    end;
    if not missing(where_clause_expression) then do;
      put '      <def:FormalExpression Context="text">' expr_enc +(-1) '</def:FormalExpression>';
    end;
    put '    </def:WhereClauseDef>';
  run;

  data _null_;
    file defout mod;
    put '    </MetaDataVersion>';
    put '  </Study>';
    put '</ODM>';
  run;

  proc datasets lib=work nolist;
    delete __ig __ir __id __cl __cli __md __vl __vlm __wc;
  quit;

  filename defout clear;
%mend define_write_xml_v21;
