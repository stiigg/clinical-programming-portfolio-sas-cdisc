/*-----------------------------------------------------------------------------
Macro:       %popflags
Purpose:     Apply standard population flags within ADSL
-----------------------------------------------------------------------------*/
%macro popflags(in=ADaM.ADSL, out=ADaM.ADSL);
  data &out;
    set &in;
    length ITTFL SAFFL PPFL $1;

    ITTFL_flg = (not missing(RANDDT));
    SAFFL_flg = (not missing(TRTSDT));
    PPFL_flg  = (ITTFL_flg and missing(PPWHY));

    ITTFL = ifc(ITTFL_flg,'Y','N');
    SAFFL = ifc(SAFFL_flg,'Y','N');
    PPFL  = ifc(PPFL_flg,'Y','N');
    drop ITTFL_flg SAFFL_flg PPFL_flg;
  run;
%mend popflags;
