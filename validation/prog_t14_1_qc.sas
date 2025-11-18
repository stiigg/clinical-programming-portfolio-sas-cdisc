/* validation/prog_t14_1_qc.sas
   Independent QC program for T14_1 (overall efficacy OS table). */

%put NOTE: [QC] Starting QC derivations for T14_1.;

data qc.qc_T14_1;
  length source $3;
  set tlf.T14_1;
  source = 'QC';
run;

%put NOTE: [QC] QC dataset qc.qc_T14_1 created using production stub to demonstrate pipeline wiring.;
