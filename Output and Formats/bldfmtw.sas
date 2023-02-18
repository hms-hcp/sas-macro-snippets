%macro bldfmtw(dsn, fmtlib, fmtname, start, label, vtype, other=);
 /*-----------------------------------------------*/
 /*                                               */
 /* NAME:  bldfmtw                                */
 /*                                               */
 /* TYPE:  SAS MACRO                              */
 /*                                               */
 /* DESC: Build a format from a SAS dataset       */
 /*                                               */
 /*                                               */
 /* USAGE: Between SAS steps                      */    
 /*                                               */
 /* PARMS:                                        */
 /* --------    --------------------------------- */    
 /*  dsn        One or two level data set name    */
 /*  fmtlib     Work or libname reference of      */
 /*             format library to write to        */
 /*  fmtname    Name of format                    */
 /*  start      Variable to be used as lookup     */
 /*  label      Variable to returned fro lookup   */
 /*  vtype      C (char) N (numeric)              */
 /*  other      Value returned if not found in    */
 /*             lookup                            */
 /*                                               */    
 /*============================================== */
 /* MODS: 9/8/03 - New (ER)                       */
 /*                                               */
 /*-----------------------------------------------*/
data cntlin                                             ;
length  fmtname $8  label $200 ;
retain fmtname "&fmtname";

%if &other ne %then %do;
length hlo $1;
if _n_ = 1 then                                          
do;
  hlo   = 'O';
  label = &other;
  output ;
  hlo   = ' ';
end;
%end; %else
%do;
  hlo = ' ';
%end;
set &dsn(keep=&start &label rename=(&start=start ));

%if &vtype eq N %then %do;
   label=left(trim(put(&label,best30.)));
%end;
%else %do;
   label = &label;
%end;
output                                                  ;
run                                                     ;

proc sort data = cntlin; by hlo start; run;

data dups cntlin;
  set cntlin;
  by hlo start;
  if first.start then output cntlin;
  if ^( first.start & last.start ) then output dups;
  run;

title2 "(25) Duplicates in &DSN list";
proc print data = dups(obs=25); run;
title2 "";
proc format library = &fmtlib cntlin = cntlin ; ***fmtlib   ;
***select         &fmtname; *** 11/19/99;
run;                                                     

%mend bldfmtw;



