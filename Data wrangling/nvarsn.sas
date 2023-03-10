/*

/ Program   : nvarsn.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 30-Jul-2007
/ Purpose   : Function-style macro to return the number of numeric variables in
/             a dataset.
/ SubMacros : %varlistn %words
/ Notes     : 
/ Usage     : %let nvarsn=%nvarsn(dsname);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                (pos) Dataset name
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  30Jul07         Header tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: nvarsn v1.0;

%macro nvarsn(ds);
%words(%varlistn(&ds))
%mend;
