%macro bldfmtx(dsn, fmtlib, fmtname, start, end, label, width, vtype, other=);
 /*-----------------------------------------------*/
 /*                                               */
 /* NAME:  bldfmtx                                */
 /*                                               */
 /* TYPE:  SAS MACRO                              */
 /*                                               */
 /* DESC:  Build a format from a SAS Dataset      */
 /*        using both starting and ending ranges  */
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
 /*  start      Variable to be used as starting   */
 /*             range of lookup                   */
 /*  end        Variable to be used as ending     */
 /*             range of lookup                   */
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
length  fmtname $8  label $&width ;
retain fmtname "&fmtname";

%*if &other ne %then %do;
length hlo $1;
if _n_ = 1 then                                          
do;
  hlo   = 'O';
  label = &other;
  output ;
  hlo   = ' ';
end;
%*end;
set &dsn(keep=&start &end &label rename=(&start=start &end=end ));
label = &label;
output                                                  ;
run                                                     ;

proc sort data = cntlin; by hlo start; run;

data dups cntlin;
  set cntlin;
  by hlo start;
  if first.start then output cntlin;
  if ^( first.start & last.start ) then output dups;
  run;

title1 "Duplicates in &DSN list (obs=50)";
proc print data = dups(obs=50); run;

proc format library = &fmtlib cntlin = cntlin ;
title1 " ";
run;                                                     

%mend;



