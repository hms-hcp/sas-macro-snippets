*--------------------------------------------------------------------------*
| department of Health Care Policy - Harvard Medical School - Boston, MA   |
|--------------------------------------------------------------------------|
| File Name      = freqmeans.sas                                           |
| Path or URL    = /usr/apps/sas/maclib/                                   |
| Version        = 1                                                       |
| Creation Date  = 01 20 2011                                              |
| Author         = Kayo Walsh                                              |
| Affiliation    = HCP                                                     |
| Category       = Working with SAS DATA                                   |
| Keys           =                                                         |
|                                                                          |
|--------------------------------------------------------------------------|
| Brief Description: Data qulity check method that detemines whether PROC  |
| FREQ, PROC MEANS, or PROC RPINTS are appropriate.                        |
|                                                                          |
---------------------------------------------------------------------------|
*--------------------------------------------------------------------------*
| Update Information: Repeat below fields for each update                  |
|--------------------------------------------------------------------------|
| Modified Date  = DD MMM YYYY                                             |
| By Whom        =                                                         |
| Reason:                                                                  |
*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| DISCLAIMER:                                                              |
|--------------------------------------------------------------------------|
|   The information contained within this file is provided "AS IS" by the  |
|Department of Health Care Policy (HCP), Harvard Medical School, as a      |
|service to the HCP Programmers Group and the Departments other users of   |
|SAS.  There are no warranties, expressed or implied, as to the            |
|merchantability or fitness for a particular purpose regarding the accuracy|
|of the materials or programming code contained herein. This macro may be  | 
|distributed freely as long as all comments, headers and related files are | 
|included.                                                                 |
|                                                                          |
|   Copyright (C) 2011 by The Department of Health Care Policy, Harvard    |
|Medical School, Boston, MA, USA. All rights reserved.                     |
*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Full Description:                                                        |
|--------------------------------------------------------------------------|
This macro ouputs results of PROC FREQ, PROC MEANS, and PROC PRINT.  
These results can be selected as an optional. A user can decide where to 
make a cutoff point of # of level of variable. Also, a user can choose # of 
records to be printed if PROC RPINT is selected.

# levels <= cutoff - PROC FREQ
# levels >  cutoff AND numeric variables - PROC MEANS
# levels >  cutoff AND character variables - PROC PRINT 

Keyword parameters:

   lib        -  library name for input data set. Type 'work' 
                           for a work data set.
   dsn        -  name of input data set.   
   cutoff     -  cutoff point - maximum number of levels for FREQ. Default=10 
   metalib    -  library name for meta data set (that contains # of levels and 
                types of variables).  Default: work           
   metadsn    -  name of meta data set.  Default: meta
   printcases -  yes/no option. no by default. yes - 
                        print char vars with > cutoff levels 
   ncases     -  if printcases = yes, then specify number of cases to print.           

Sample macro calls: 
* %FreqMeans(lib=sashelp,               /*run macro on SASHELP.CLASS         */ 
*           dsn=class) 
* 
*%FreqMeans(lib=sashelp, 
*           dsn=class, 
*           printcases=yes,            /* print char vars with nlevels>cutoff */ 
*           ncases=40)                 /* print 40 observations               */ 
* 
*libname sasdata 'c:\metadata'; 
*%FreqMeans(lib=sashelp, 
*           dsn=class, 
*           metalib=sasdata,           /* save metadata in permanent         */ 
*           metadsn=classmeta)         /* SAS data set SASDATA.CLASSMETA     */ 
* 
*%FreqMeans(lib=work,                  /* ran macro on WORK.CLASS                     */
*           dsn=class,                
*           cutoff = 10,               /* assign a cutoff point that divide variables */
*                                      /* into FREQ/MEANS                             */   
*           metalib=sasdata,           /* save metadata in permanent                  */ 
*           metadsn=classmeta,         /* SAS data set SASDATA.CLASSMETA     */
*           printcases=no)             /* no print */
                                         
*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Macro Code Begins Here.                                                  |
*--------------------------------------------------------------------------*;

%macro FreqMeans(lib=  ,             /* libref for input data set            */ 
                 dsn=  ,             /* name of input data set               */ 
                 cutoff=10  ,          /* maximum number of levels for FREQ    */ 
                 metalib=work  ,     /* libref for meta data set             */ 
                 metadsn=meta ,         /* name of meta data set             */ 
                 printcases= ,       /* print char vars with > cutoff levels */ 
                 ncases=  ,        /* number of cases to print             */
                 title2= 
 );
%local MEANSvars FREQvars PRINTvars;

/*1. Create NLEVELS output data set*/ 

ods listing close; *turn off printing; 
ods output nlevels = nlevelsds; 
    proc freq data=&lib..&dsn nlevels; 
    tables _all_/noprint; 
    run; 
ods listing; *turn on printing; 
 
/*2. Create META data set*/

proc sql noprint; 
    create table &metalib..&metadsn as 
    select name, type, nlevels 
    from dictionary.columns, nlevelsds 
    where libname=upcase("&lib") and memname=upcase("&dsn") and name=tablevar; 
 
/*3A. Store names of all variables with NLEVELS <= cutoff 
     in macro variable FREQvars*/ 

    select name into :FREQvars separated by ' ' 
    from &metalib..&metadsn 
    where nlevels <= &cutoff; 
 
/*3B. Store names of numeric variables with NLEVELS > cutoff 
     in macro variable MEANSvars*/ 

    select name into :MEANSvars separated by ' ' 
    from &metalib..&metadsn 
    where nlevels > &cutoff and type="num"; 
 
/*3C. Conditionally store names of character variables with NLEVELS > cutoff 
     in macro variable PRINTvars*/

     %let PRINTvars = ; *initialize macro variable; 
     %if %upcase(&printcases)=YES %then %do;
  
         select name into :PRINTvars separated by ' ' 
         from &metalib..&metadsn 
         where nlevels > &cutoff and type="char"; 
     %end; 
 
quit; 
 
/*4A. Run PROC FREQ on all variables with NLEVELS <= cutoff*/

%if &FREQvars ne %then %do; 
     proc freq data = &lib..&dsn; 
         tables &FREQvars; 
         title "PROC FREQ of all variables with NLEVELS <= &cutoff";
         title2 "&title2"; 
     run; 
%end; 
  
/*4B. Run PROC MEANS on numeric variables with NLEVELS > cutoff*/

%if &MEANSvars ne %then %do; 
     proc means data=&lib..&dsn; 
          var &MEANSvars; 
          title "PROC MEANS of numeric variables with NLEVELS > &cutoff"; 
         title2 "&title2"; 
     run; 
%end; 
 
/*4C. Upon request, run PROC PRINT on character variables with NLEVELS > cutoff*/ 

%if %upcase(&printcases)=YES and &PRINTvars ne %then %do; 
     proc print data=&lib..&dsn(obs=&ncases); 
         var &PRINTvars; 
         title "PROC PRINT of character variables with NLEVELS  > &cutoff";
         title2 "&title2";  
     run; 
%end; 
 
%mend FreqMeans; 

