/* macros/tlf_resp_rate.sas */
%macro tlf_resp_rate(outid=, ds=ADRESP, paramcd=, pop=ITT, subgrp=);
  %local where_pop where_sub;
  %if %sysevalf(%superq(outid)=, boolean) %then %let outid=RESP_&paramcd.;
  %if %sysevalf(%superq(paramcd)=, boolean) %then %let paramcd=ORR;
  %let where_pop = %get_pop_where(pop=&pop.);
  %let where_sub = %apply_subgroup(subgrp_id=&subgrp.);

  %if not %sysfunc(exist(adam.&ds.)) %then %do;
    data tlf.&outid.;
      length note $200;
      note = cats('Dataset adam.', "&ds.", ' missing.');
    run;
    %return;
  %end;

  data work._resp;
    set adam.&ds.;
    where upcase(PARAMCD)=upcase("&paramcd.")
          and (&where_pop)
          and (&where_sub);
    length RESPFL $1;
    RESPFL = ifc(upcase(coalescec(AVALC, '')) in ('CR','PR','RESP'), 'Y', 'N');
  run;

  proc summary data=work._resp nway;
    class RESPFL;
    output out=work._resp_cnt (drop=_type_) n=COUNT;
  run;

  data tlf.&outid.;
    set work._resp_cnt end=last;
    retain TOTAL 0 RESP 0;
    TOTAL + COUNT;
    if RESPFL='Y' then RESP + COUNT;
    if last then do;
      length OUTID $32 POPULATION $12 SUBGRP_ID $32;
      OUTID = "&outid.";
      POPULATION = "&pop.";
      SUBGRP_ID = "&subgrp.";
      RATE = divide(RESP, TOTAL);
      output;
    end;
    keep OUTID POPULATION SUBGRP_ID TOTAL RESP RATE;
  run;

  %put NOTE: [TLF] Created response dataset tlf.&outid. for PARAMCD=&paramcd.;
%mend;
