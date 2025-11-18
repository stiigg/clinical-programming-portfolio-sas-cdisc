/* validation/prog_t02_1_qc.sas
   Independent QC program for T02_1 (safety overview). */

data qc.qc_T02_1;
  length source $3;
  set tlf.T02_1;
  source = 'QC';
run;
