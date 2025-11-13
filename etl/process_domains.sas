/* process_domains.sas
   Metadata-driven driver that loops through SDTM and ADaM domains. */

%macro process_domains(type=SDTM);
  %local domain_list n domain;
  %get_domain_list(type=&type., outmacro=domain_list);
  %let n=%sysfunc(countw(&domain_list.));

  %do i=1 %to &n.;
    %let domain=%upcase(%scan(&domain_list., &i.));
    %put NOTE: === Processing &type. domain &domain. ===;

    %if %upcase(&type.) = SDTM %then %do;
      %if &domain = DM %then %sdtm_dm;
      %else %if &domain = AE %then %sdtm_ae;
      %else %put WARNING: No SDTM macro defined for &domain.;
    %end;
    %else %if %upcase(&type.) = ADAM %then %do;
      %if &domain = ADSL %then %adam_adsl;
      %else %if &domain = ADAE %then %adam_adae;
      %else %put WARNING: No ADaM macro defined for &domain.;
    %end;
  %end;
%mend;
