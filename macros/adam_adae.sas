/* adam_adae.sas */

%macro adam_adae;
  %put NOTE: Deriving ADaM ADAE from SDTM AE + ADSL;
  proc sql;
    create table adam.adae as
    select a.USUBJID,
           a.AETERM,
           a.AESTDTC,
           a.AEENDTC,
           a.AESEV,
           b.TRTSDT,
           b.TRTEDT
    from sdtm.ae as a
    left join adam.adsl as b
      on a.USUBJID = b.USUBJID;
  quit;

  data adam.adae;
    set adam.adae;
    length TRTEMFL $1;
    format TRTSDT TRTEDT AESTDT AEENDT date9.;
    AESTDT = input(AESTDTC, yymmdd10.);
    AEENDT = input(AEENDTC, yymmdd10.);
    TRTEMFL = ifc(not missing(TRTSDT) and not missing(AESTDT) and AESTDT >= TRTSDT, 'Y', 'N');
  run;

  proc sort data=adam.adae;
    by USUBJID AESTDTC;
  run;

  %ct_check(adam_dataset=adam.adae, ct_spec_file=&reference_dir./ct_evs.csv);
%mend;
