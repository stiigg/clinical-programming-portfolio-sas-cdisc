/* macros/tlf_km.sas */
%macro tlf_km(outid=, ds=ADTTE, paramcd=, pop=ITT, subgrp=);
  %local where_pop where_sub;
  %if %sysevalf(%superq(outid)=, boolean) %then %let outid=KM_&paramcd.;
  %if %sysevalf(%superq(paramcd)=, boolean) %then %let paramcd=OS;
  %let where_pop = %get_pop_where(pop=&pop.);
  %let where_sub = %apply_subgroup(subgrp_id=&subgrp.);

  data tlf.&outid.;
    set adam.&ds.;
    where upcase(PARAMCD)=upcase("&paramcd.")
          and (&where_pop)
          and (&where_sub);
  run;

  %put NOTE: [TLF] Created KM dataset tlf.&outid. for PARAMCD=&paramcd. POP=&pop. SUBGRP=&subgrp.;
%mend;
