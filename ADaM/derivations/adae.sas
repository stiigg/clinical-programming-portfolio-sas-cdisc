/*-----------------------------------------------------------------------------
Program:     ADaM/derivations/adae.sas
Purpose:     Derive ADAE from SDTM with traceability and QC hooks
Inputs:      SDTM.* , ADSL (where applicable)
Outputs:     ADaM.ADAE (plus /logs and /reports outputs)
Traceability:
  - Source SDTM domains: AE, DM
  - Derivations documented in metadata/adae_meta.md
  - Spec version: metadata/spec/adam_spec.csv (SpecID=YYYYMMDD)
Owner:       Clinical Programmer   Version: 0.1.0   Last updated: 2024-06-08
-----------------------------------------------------------------------------*/
%include "../macros/_setup.sas";
%audit_start(domain=ADAE, program=%sysfunc(getoption(sysin)));

%assert(%sysfunc(exist(SDTM.AE)), msg=SDTM.AE missing, level=ERROR);
%assert(%sysfunc(exist(ADaM.ADSL)), msg=ADaM.ADSL missing. Run ADSL first., level=ERROR);

%mergecheck(base=SDTM.AE, add=ADaM.ADSL, by=USUBJID, allow_many=YES);

/*-- Defensive check for duplicate AESEQ records ----------------------------*/
proc sort data=SDTM.AE out=work._ae_sorted nodupkey dupout=work._ae_dups;
  by USUBJID AESEQ;
run;

%let ae_dupobs=0;
%let _ae_dups_dsid = %sysfunc(open(work._ae_dups));
%if &_ae_dups_dsid %then %do;
  %let ae_dupobs = %sysfunc(attrn(&_ae_dups_dsid, nobs));
  %let _rc = %sysfunc(close(&_ae_dups_dsid));
%end;

%if %sysevalf(&ae_dupobs > 0) %then %do;
  %put WARNING: [ADAE] Duplicate AE records detected. Review WORK._AE_DUPS.;
%end;

proc import datafile="../metadata/codelists.csv" out=work._codelists dbms=csv replace;
  guessingrows=max;
run;

proc sql;
  create table work._sev_map as
  select strip(VALUE) as AESEV length=200,
         strip(STANDARD_VALUE) as AESEV_STD length=200
  from work._codelists
  where upcase(DOMAIN)="ADAE" and upcase(VARIABLE)="AESEV";

  create table work._ser_map as
  select strip(VALUE) as AESER length=200,
         strip(STANDARD_VALUE) as AESER_STD length=200
  from work._codelists
  where upcase(DOMAIN)="ADAE" and upcase(VARIABLE)="AESER";
quit;

proc sql;
  create table work._adae_base as
  select a.*,
         coalescec(s.AESEV_STD, a.AESEV) as AESEV_STD length=200,
         coalescec(r.AESER_STD, a.AESER) as AESER_STD length=200,
         b.TRTSDT_FINAL,
         b.TRTEDT_FINAL,
         b.SAFFL
  from work._ae_sorted a
  left join ADaM.ADSL b
    on a.USUBJID=b.USUBJID
  left join work._sev_map s
    on upcase(coalescec(a.AESEV,''))=upcase(s.AESEV)
  left join work._ser_map r
    on upcase(coalescec(a.AESER,''))=upcase(r.AESER);
quit;

data work._adae_deriv;
  set work._adae_base;
  length ASTDT AENDT 8
         ASTDTF AENDTF $1
         ASTDY AENDY 8
         TRTEMFL ANL01FL $1
         SRCDOM $8 SRCVAR $32 SRCSEQ 8;
  format ASTDT AENDT date9.;
  label ASTDT = "Analysis Start Date"
        ASTDTF = "Analysis Start Date Imputation Flag"
        ASTDY = "Analysis Start Relative Day"
        AENDT = "Analysis End Date"
        AENDTF = "Analysis End Date Imputation Flag"
        AENDY = "Analysis End Relative Day"
        TRTEMFL = "Treatment-Emergent Flag"
        ANL01FL = "Primary Analysis Flag"
        SRCDOM = "Source SDTM Domain"
        SRCVAR = "Source Variable"
        SRCSEQ = "Source Sequence";

  SRCDOM = "AE";
  SRCVAR = "AESEQ";
  SRCSEQ = AESEQ;

  /*--- Impute partial start dates ---*/
  length _year _month _day 8;
  ASTDT = .;
  ASTDTF = '';
  if not missing(AESTDTC) then do;
    _year = input(substr(AESTDTC, 1, 4), best.);
    _month = .;
    _day = .;
    if lengthn(AESTDTC) >= 7 then _month = input(substr(AESTDTC, 6, 2), best.);
    if lengthn(AESTDTC) >= 10 then _day = input(substr(AESTDTC, 9, 2), best.);

    if missing(_year) then do;
      ASTDT = .;
      ASTDTF = 'Y';
    end;
    else do;
      if missing(_month) then do;
        _month = 1;
        _day = 1;
        ASTDTF = 'M';
      end;
      else if missing(_day) then do;
        _day = 1;
        ASTDTF = 'D';
      end;
      ASTDT = mdy(_month, _day, _year);
    end;
  end;

  /*--- Impute partial end dates ---*/
  _year = .;
  _month = .;
  _day = .;
  AENDT = .;
  AENDTF = '';
  if not missing(AEENDTC) then do;
    _year = input(substr(AEENDTC, 1, 4), best.);
    if lengthn(AEENDTC) >= 7 then _month = input(substr(AEENDTC, 6, 2), best.);
    if lengthn(AEENDTC) >= 10 then _day = input(substr(AEENDTC, 9, 2), best.);

    if missing(_year) then do;
      AENDT = .;
      AENDTF = 'Y';
    end;
    else do;
      if missing(_month) then do;
        _month = 12;
        _day = 31;
        AENDTF = 'M';
      end;
      else if missing(_day) then do;
        AENDTF = 'D';
        AENDT = intnx('month', mdy(_month, 1, _year), 0, 'end');
      end;
      if missing(AENDT) then AENDT = mdy(_month, coalesce(_day, 1), _year);
    end;
  end;

  /*--- Relative study days ---*/
  ASTDY = .;
  AENDY = .;
  if not missing(ASTDT) and not missing(TRTSDT_FINAL) then do;
    if ASTDT >= TRTSDT_FINAL then ASTDY = ASTDT - TRTSDT_FINAL + 1;
    else ASTDY = ASTDT - TRTSDT_FINAL;
  end;

  if not missing(AENDT) and not missing(TRTSDT_FINAL) then do;
    if AENDT >= TRTSDT_FINAL then AENDY = AENDT - TRTSDT_FINAL + 1;
    else AENDY = AENDT - TRTSDT_FINAL;
  end;

  /*--- Treatment-emergent and analysis flags ---*/
  TRTEMFL = '';
  ANL01FL = '';
  length _tem_date 8;
  _tem_date = .;
  if not missing(ASTDT) then _tem_date = ASTDT;
  else if not missing(AENDT) then _tem_date = AENDT;

  if not missing(TRTSDT_FINAL) and not missing(_tem_date) then do;
    if _tem_date >= TRTSDT_FINAL then TRTEMFL = 'Y';
    else TRTEMFL = 'N';
  end;

  if TRTEMFL = 'Y' then ANL01FL = 'Y';

  drop _year _month _day _tem_date;
run;

proc sort data=work._adae_deriv;
  by USUBJID AESEQ;
run;

data ADaM.ADAE;
  set work._adae_deriv;
run;

proc sql;
  create table work._adae_te_summary as
  select coalescec(TRTEMFL, 'Missing') as TRTEMFL length=8,
         count(*) as RECORD_COUNT
  from work._adae_deriv
  group by calculated TRTEMFL;
quit;

proc export data=work._adae_te_summary
  outfile="../reports/qc/ADAE_trtem_summary.csv"
  dbms=csv
  replace;
run;

data work._adae_imputation_flags;
  set work._adae_deriv;
  where strip(coalescec(ASTDTF,'')) ne '' or strip(coalescec(AENDTF,'')) ne '';
  keep USUBJID AESEQ ASTDTF AENDTF;
run;

proc export data=work._adae_imputation_flags
  outfile="../reports/qc/ADAE_imputation_flags.csv"
  dbms=csv
  replace;
run;

%qcflags(in=ADaM.ADAE, out=ADaM.ADAE_QC);

proc datasets lib=work nolist;
  delete _codelists _sev_map _ser_map _adae_base _adae_deriv _ae_sorted _ae_dups
         _adae_te_summary _adae_imputation_flags;
quit;

%export_xpt(data=ADaM.ADAE, outpath="../exports");
%specdiff(domain=ADAE, spec=../metadata/spec/adam_spec.csv, out=../reports/specdiff/ADAE_specdiff.csv);
%audit_end(domain=ADAE);
