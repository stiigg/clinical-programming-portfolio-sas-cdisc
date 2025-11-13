/* generate_qc_report.sas
   Consolidates QC outputs into a single summary listing. */

%include "macros/cdisc_init.sas";
%cdisc_init(study_config="config/config_study.sas");

%include "macros/cdisc_logging.sas";

%start_log(step_name=qc_report);

data qc.qc_summary;
  length Dataset $32 Issue $200;
  if exist('qc.qc_diff_ae') then do;
    Dataset='AE'; Issue='See qc.qc_diff_ae for SDTM comparison results'; output;
  end;
  if exist('qc.qc_diff_adsl') then do;
    Dataset='ADSL'; Issue='See qc.qc_diff_adsl for ADaM comparison results'; output;
  end;
  if exist('qc.ae_duplicates') then do;
    Dataset='AE'; Issue='Duplicate AE records detected'; output;
  end;
  if exist('qc.missing_subjects') then do;
    Dataset='ADSL'; Issue='Subjects without ADaM representation'; output;
  end;
run;

%end_log(step_name=qc_report);
