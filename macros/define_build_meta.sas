/* define_build_meta.sas
   Construct in-memory Define-XML metadata tables from MDR specifications. */

%macro define_build_meta(standard=SDTM, outlib=work);
  %local std;
  %let std=%upcase(&standard.);

  proc sql;
    create table &outlib..def_itemgroup_base as
    select distinct
      upcase(d.standard) as standard length=8,
      upcase(d.domain) as domain length=32,
      coalescec(d.dataset_label, d.domain) as dataset_label length=200,
      coalescec(d.structure, '') as structure length=200,
      coalescec(d.purpose, '') as purpose length=40,
      coalescec(d.keys, '') as keys length=200,
      coalescec(t.class, '') as class length=64,
      t.order as order_num,
      coalescec(t.has_value_level, 'N') as has_value_level length=1
    from meta_dataset d
    left join meta_toc t
      on upcase(d.standard)=upcase(t.standard)
     and upcase(d.domain)=upcase(t.domain)
    where upcase(d.standard)="&std";
  quit;

  proc sort data=&outlib..def_itemgroup_base;
    by order_num domain;
  run;

  data &outlib..def_itemgroup;
    set &outlib..def_itemgroup_base;
    by order_num domain;
    length oid $64 name $32 label $200;
    retain seq 0;
    name = strip(domain);
    label = strip(dataset_label);
    oid = cats('IG.', standard, '.', name);
    if missing(order_num) then do;
      seq+1;
      order_num = seq;
    end;
    drop dataset_label;
  run;

  proc sql;
    create table &outlib..def_itemref_base as
    select
      upcase(v.standard) as standard length=8,
      upcase(v.domain) as domain length=32,
      upcase(v.var_name) as var_name length=32,
      coalescec(v.var_label, v.var_name) as var_label length=200,
      coalescec(v.data_type, 'text') as data_type length=16,
      v.length,
      coalescec(v.role, '') as role length=64,
      coalescec(v.origin, '') as origin length=32,
      coalescec(v.codelist_id, '') as codelist_id length=40,
      coalescec(v.method_id, '') as method_id length=40,
      coalescec(v.mandatory, 'No') as mandatory length=3,
      coalescec(v.display_format, '') as display_format length=32,
      v.xml_order
    from meta_variable v
    where upcase(v.standard)="&std";
  quit;

  proc sort data=&outlib..def_itemref_base;
    by standard domain xml_order var_name;
  run;

  proc sort data=&outlib..def_itemgroup(keep=standard domain keys);
    by standard domain;
  run;

  data &outlib..def_itemref;
    merge &outlib..def_itemref_base
          &outlib..def_itemgroup(keep=standard domain keys);
    by standard domain;
    length itemoid $64 name $32 mandatory_flag $3 ordernumber 8 keysequence 8;
    retain seq 0;
    if first.domain then seq=0;
    seq+1;
    itemoid = cats('IT.', standard, '.', domain, '.', var_name);
    name = strip(var_name);
    if missing(xml_order) then ordernumber = seq;
    else ordernumber = xml_order;
    mandatory_flag = ifc(upcase(mandatory)='YES','Yes','No');
    keysequence = .;
    if not missing(keys) then do;
      length key $32;
      do _i_=1 to countw(keys, ' ');
        key = upcase(scan(keys, _i_, ' '));
        if key = name then do;
          keysequence = _i_;
          leave;
        end;
      end;
    end;
    drop _i_;
  run;

  proc sql;
    create table &outlib..def_itemdef as
    select
      r.standard length=8,
      r.domain length=32,
      r.var_name,
      r.itemoid as oid length=64,
      r.name,
      r.var_label,
      r.data_type,
      r.length,
      r.role,
      r.origin,
      r.codelist_id,
      r.method_id,
      r.mandatory_flag as mandatory length=3,
      r.display_format,
      r.ordernumber,
      r.keysequence
    from &outlib..def_itemref r;
  quit;

  proc sql;
    create table &outlib..def_codelist as
    select distinct
      codelist_id length=40,
      coalescec(codelist_name, codelist_id) as codelist_name length=200,
      coalescec(nci_code, '') as nci_code length=32,
      coalescec(ct_package, '') as ct_package length=40,
      coalescec(is_sponsor_ct, 'N') as is_sponsor_ct length=1
    from meta_codelist
    where not missing(codelist_id);

    create table &outlib..def_codelist_item as
    select
      codelist_id length=40,
      coalescec(code, '') as code length=64,
      coalescec(decode, '') as decode length=200,
      coalescec(decode_order, .) as decode_order
    from meta_codelist
    where not missing(codelist_id)
    order by codelist_id, calculated decode_order, decode;

    create table &outlib..def_methoddef as
    select
      method_id length=40,
      coalescec(method_type, 'Computation') as method_type length=32,
      coalescec(method_description, '') as method_description length=500,
      coalescec(program_ref, '') as program_ref length=200
    from meta_method
    where not missing(method_id);

    create table &outlib..def_document as
    select
      doc_id length=32,
      coalescec(doc_title, '') as doc_title length=200,
      coalescec(doc_type, '') as doc_type length=40,
      coalescec(file_name, '') as file_name length=200,
      coalescec(href, '') as href length=200
    from meta_document
    where not missing(doc_id);
  quit;

  proc sql;
    create table &outlib..def_vlm as
    select
      upcase(standard) as standard length=8,
      upcase(domain) as domain length=32,
      upcase(var_name) as var_name length=32,
      coalescec(where_clause_id, cats('WC_', strip(var_name))) as where_clause_id length=40,
      coalescec(where_clause_expression, '') as where_clause_expression length=200,
      coalescec(vlm_label, '') as vlm_label length=200,
      coalescec(codelist_id, '') as codelist_id length=40,
      coalescec(method_id, '') as method_id length=40,
      coalescec(data_type, '') as data_type length=16,
      length
    from meta_vlm
    where upcase(standard)="&std";
  quit;

  proc sort data=&outlib..def_vlm;
    by domain var_name where_clause_id;
  run;

  proc sql;
    create table &outlib..def_valuelist as
    select distinct
      standard,
      domain,
      var_name,
      cats('VL.', standard, '.', domain, '.', var_name) as valuelist_oid length=64
    from &outlib..def_vlm;

    create table &outlib..def_whereclause as
    select distinct
      where_clause_id length=40,
      coalescec(where_clause_expression, '') as where_clause_expression length=200,
      coalescec(vlm_label, '') as vlm_label length=200
    from &outlib..def_vlm;
  quit;

  proc sql;
    create table &outlib..def_itemdef_vl as
    select distinct
      v.standard,
      v.domain,
      v.var_name,
      cats('VL.', v.standard, '.', v.domain, '.', v.var_name) as valuelist_oid length=64
    from &outlib..def_vlm v;
  quit;

  proc sort data=&outlib..def_itemdef;
    by standard domain var_name;
  run;

  proc sort data=&outlib..def_itemdef_vl;
    by standard domain var_name;
  run;

  data &outlib..def_itemdef;
    merge &outlib..def_itemdef(in=a)
          &outlib..def_itemdef_vl;
    by standard domain var_name;
  run;

  data &outlib..def_valuelist_map;
    set &outlib..def_vlm;
    length valuelist_oid $64;
    valuelist_oid = cats('VL.', standard, '.', domain, '.', var_name);
  run;
%mend define_build_meta;
