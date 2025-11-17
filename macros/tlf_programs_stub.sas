/* tlf_programs_stub.sas
   Placeholder TLF macros invoked by the metadata dispatcher. */

%macro _tlf_stub(tlf_id=, population=, param_family=, paramcd_list=, risk_level=, program_label=);
  %footnote_run;
  data outtlf.&tlf_id.;
    length TLF_ID PROGRAM POPULATION PARAM_FAMILY PARAMCD_LIST RISK_LEVEL $40 message $200;
    TLF_ID = "&tlf_id.";
    PROGRAM = "&program_label.";
    POPULATION = "&population.";
    PARAM_FAMILY = "&param_family.";
    PARAMCD_LIST = "&paramcd_list.";
    RISK_LEVEL = "&risk_level.";
    message = "Stub output generated for portfolio wiring.";
  run;

  %stamp_dataset(lib=outtlf, ds=&tlf_id.);
%mend _tlf_stub;

%macro efficacy_generic(tlf_id=, population=, param_family=, paramcd_list=, risk_level=);
  %_tlf_stub(tlf_id=&tlf_id., population=&population., param_family=&param_family.,
             paramcd_list=&paramcd_list., risk_level=&risk_level., program_label=efficacy_generic);
%mend efficacy_generic;

%macro km_generic(tlf_id=, population=, param_family=, paramcd_list=, risk_level=);
  %_tlf_stub(tlf_id=&tlf_id., population=&population., param_family=&param_family.,
             paramcd_list=&paramcd_list., risk_level=&risk_level., program_label=km_generic);
%mend km_generic;

%macro safety_generic(tlf_id=, population=, param_family=, paramcd_list=, risk_level=);
  %_tlf_stub(tlf_id=&tlf_id., population=&population., param_family=&param_family.,
             paramcd_list=&paramcd_list., risk_level=&risk_level., program_label=safety_generic);
%mend safety_generic;
