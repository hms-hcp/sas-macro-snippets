%macro PRTFMT(LIBREF=WORK,CATNAME=FORMATS,FMT=,NOBS=10,ORDER=A,LISTONLY=N);
%put *************** BEGIN MACRO PRTFMT ***************;
%*********************************************************************;
%*____________________________________________________________________;
%*DESCRIPTION                                                         ;
%*____________________________________________________________________;
%*                                                                    ;
%*   Name:        prtfmt.sas                                          ;
%*                                                                    ;
%*   Author:                                                          ;
%*                                                                    ;
%*   Type:        SAS Macro                                           ;
%*                                                                    ;
%*   Library:     /sas/sas8_1/maclib                                  ;
%*                                                                    ;
**   Description & Usage:  Print user-defined formats                 ;
**                                                                    ;
**                                                                    ;
**                                                                    ;
**     Examples:                                                      ;
**                                                                    ;
**        %PRTFMT;                                                    ;
**        %PRTLIB(FMT=$XYZ);                                          ;
**        %PRTLIB(LIBREF=MYLIB,NOBS=10);                              ;
**                                                                    ;
**____________________________________________________________________;
**PARAMETERS                                                          ;
**____________________________________________________________________;
**                                                                    ;
**   Keyword .... Description                                         ;
**   -------..... -----------                                         ;
**   LIBREF ..... SAS libref for formats (defaults to LIBRARY)        ;
**   FMT    ..... Format name begins with xyw (optional). If blank,   ;
**                (the default) all formats in library are printed.   ;
**   CATNAME .... Name of format catalog (defaults to FORMATS)        ;
**   NOBS   ..... # of obs to print for format (defaults to 10)       ;
**   ORDER  ..... Order to print formats (A for ALPHA, D for DATE)    ;
**                (defaults to Alpha)                                 ;
**   LISTONLY ... Print only a list of formats (default=N)            ;
**____________________________________________________________________;
**CHANGE LOG                                                          ;
**                                                                    ;
** Date            Change                                             ;
**---------        -------                                            ;
* 07/27/01         Fix resetting of fmtsearch options statement (mbr) ;
* 07/31/01         Remove char $ and . from value of FMT (mbr)        ;
**********************************************************************;

%local pathname;
%if %length(&LIBREF) ne 0 %then %do; 
   %let pathname = %sysfunc(pathname(&LIBREF));
%end;

%if %length(&LIBREF) = 0 or %length(&PATHNAME) = 0 or %length(&CATNAME) = 0
   %then %do;
   %put *************** ERROR IN INPUT PARAMETERS ***************;
   %put *************** MACRO FMTLIB ENDED UNSUCCESSFULLY *********;
   %goto endmac;
   %end;

%local fmtsearch;
%let fmtsearch = %sysfunc(getoption(FMTSEARCH));  ** save existing options before modifiying **;
options fmtsearch=(&LIBREF);
   
%let LIBREF = %upcase(&LIBREF);
%let CATNAME = %upcase(&CATNAME);
%let ORDER = %upcase(&ORDER);
%let LISTONLY = %upcase(&LISTONLY);

%local FMTS;
%if %length(&FMT) ne 0 %then %do;
    %let FMT = %upcase(&FMT);
    %let FMT = %sysfunc(compress(&FMT,'$.'));
    %let FMTS = and objname like &FMT%;  ** used for title **;
    %let FMT = and objname like "&FMT%"; ** used for where clause **;
%end;

data _FMTLIB;
      set SASHELP.VCATALG end=lastobs;
         where libname eq "&LIBREF" and memtype like "CAT%" and memname like "&CATNAME%" and
                      objtype like "FORMAT%" &FMT;
run;

%if %substr(&ORDER,1,1) eq A %then %do;
  %let ORDER = Alphabetical order;
  proc sort data=_FMTLIB;
    by objname;
  run;
%end;
%else %do;
  %let ORDER = Decending Date order;
  proc sort data=_FMTLIB;
      by descending modified;
  run;
%end;
  

%local TOT;
data _FMTLIB;
  set _FMTLIB end=lastobs;
     if objtype eq 'FORMATC' then PREFIX ='$'; else PREFIX = '';
     fmtname = trim(left(prefix!!objname)); 
     call symput('FMT'!!trim(left(_n_)),fmtname);
     call symput('MODDT'!!trim(left(_n_)),put(datepart(modified),yymmdd10.));
     if lastobs then call symput('TOT',trim(left(_n_)));
run;

%if &TOT < 1 %then %do;
   %put *************** NO FORMATS WERE FOUND *****************;
   %put *************** DOUBLE CHECK YOUR PARMS ***************;
   %goto endmac;
%end;

proc print data=_FMTLIB;
  var libname memname objname modified;
  title1 "List of formats in &PATHNAME where";
  title2 "libref equals &LIBREF and memname like &CATNAME% &FMTS";
  title4 "-- Sorted by &ORDER --";
run;

%if %length(&LISTONLY) eq 0 %then %do;
  %let LISTONLY = N;
%end;
%else %do;
  %let LISTONLY = %substr(&LISTONLY,1,1);
%end;
%if &LISTONLY eq N %then %do;
   %local i FMTNAME;
   %do i = 1 %to &TOT;
       proc format lib=&LIBREF cntlout=_CNTLOUT;
         select &&FMT&I;;
       run;
       %let FMTNAME = &&FMT&I;
       proc print data=_CNTLOUT (obs=&NOBS);
         title1 "Format Library=&LIBREF";
         title2 "Format Name= &FMTNAME, Last Modified Date= &&MODDT&I ";
         var FMTNAME START END LABEL TYPE;
       run;
       title1 ;
       title2 ;
   %end;
%end;

options fmtsearch=&fmtsearch;

%put *************** END macro PRTFMT **************;
%endmac:
%mend;







