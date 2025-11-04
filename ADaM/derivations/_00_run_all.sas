/*-----------------------------------------------------------------------------
Program:     ADaM/derivations/_00_run_all.sas
Purpose:     Orchestrator to run all ADaM derivation programs in sequence
-----------------------------------------------------------------------------*/
%include "../macros/_setup.sas";

%inc "adsl.sas";
%inc "adae.sas";
%inc "advs.sas";
%inc "adlb.sas";
%inc "admh.sas";
%inc "adtte.sas";
