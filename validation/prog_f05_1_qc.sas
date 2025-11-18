/* validation/prog_f05_1_qc.sas
   Independent QC program for F05_1 (KM curve). */

data qc.qc_F05_1;
  length source $3;
  set tlf.F05_1;
  source = 'QC';
run;
