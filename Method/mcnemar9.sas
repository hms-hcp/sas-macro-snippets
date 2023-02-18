*--------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA   |
|--------------------------------------------------------------------------|
| File Name      = mcnemar9.sas                                            |
| Path or URL    = /usr/apps/sas/maclib/                                   |
| Version        =                                                         |
| Creation Date  = 13 NOV 2008                                             |
| Author         = Rita Volya                                                        |
| Affiliation    = HCP                                                     |
| Category       = Statistics                                                |
| Keys           =                                                         |
|                                                                          |
|--------------------------------------------------------------------------|
| Brief Description: performe McNemar test on matched data created by
|--------------------------------------------------------------------------|

*--------------------------------------------------------------------------*
| Update Information: Repeat below fields for each update                  |
|--------------------------------------------------------------------------|
| Modified Date  = DD MMM YYYY                                             |
| By Whom        =                                                         |
| Reason:

*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| DISCLAIMER:                                                              |
|--------------------------------------------------------------------------|
   The information contained within this file is provided "AS IS" by the
Department of Health Care Policy (HCP), Harvard Medical School, as a 
service to the HCP Programmers Group and the Department's other users of
SAS.  There are no warranties, expressed or implied, as to the
merchantability or fitness for a particular purpose regarding the accuracy
of the materials or programming code contained herein. This macro may be
distributed freely as long as all comments, headers and related files are
included.

   Copyright (C) 2005 by The Department of Health Care Policy, Harvard 
Medical School, Boston, MA, USA. All rights reserved.
*--------------------------------------------------------------------------*;
*--------------------------------------------------------------------------*
| Full Description:                                                        |;
/*                                        |
    1. performs McNemar's Test on matched pairs of records:
       a. using proc freq to compute Cochran-Mantel-Haenszel Statistics
          and Estimates of the Common Relative Risk.
       b. using proc univariates on the difference in the values of the 
       variable in the pair. The name of the variable for the differences 
       starts with "dd" followed by the actual name of the variable. Make
       sure that there is no duplicates in 6 digits of the names.
    2. calculates how many pairs have the same values and how many have
       different values in the paired records
       ( number of concordant and discordant values).

   The macro uses Title statement for all the procedures which are important
   for understanding the printout. 
   The macr uses macros %count_n and %varlist
*/ 
*  
|--------------------------------------------------------------------------|
*--------------------------------------------------------------------------*
| Instructions:                                                            |
|--------------------------------------------------------------------------|;
/*    Macro Parameters:

   data- the name of the initial data set with all the variables needed
         for the analysis; all the variables for McNemar's Test should be 
 coded
          (0,1). The data can be temporary or permanent data set. Use the 
name
         of the library with the data set name as a parameter if it's a
         permanent data: Ex: lib.mydata;

   treatmn- treatment variable which divides DATA in 2 data sets; treatment
            and cont. Should be coded (1,2)
            The observations with TREATMN=1 are included in the treatment
            group;
   id - the name of the variable that identifies a single observation
        in &data
   vlist  - the name of the macro variable to hold the list
           of the all the variables for McNemar's test
           The Lists of the variables can be any valid SAS variables list;
            (there should be a statement in the SAS program before
             the macro call identifying the variable:
             Ex.: %let keep=-SAS variables list-;
              the value of the parameter will be keep);
            You can use any number of variables to perform the test.

   dmatch - the name of the data with the matched pairs that was created
           by the macro propmt_t.sas
   lib -  the name of the library for the data with matched pairs
          followed by ".";  (Ex.:lib=mylib.),

Macro call example:

    %let list=death30 death1y death3y;

    %mcnemar(lib.mydata,cath,hicbic,list,ctmatch,lib=out.)

*/
*--------------------------------------------------------------------------*;
*--------------------------------------------------------------------------*
| Macro Code Begins Here.                                                  |
*--------------------------------------------------------------------------*;
%macro mcnemar9(data,treatmnt,id,vlist,dmatch,lib=,title=,testall=yes);

%local i;

%let newtreat=&treatmnt.C;
%let newid=&id.C;

%varlist(&data,1,&vlist,var,v_num)

%do i=1 %to &v_num;

%let nvar&i=n&&var&i;
%let dvar&i=d&&var&i;
%let ddvar&i=dd&&var&i;

%end;

proc sort data =&data;
by &id;

data matched;
set &lib&dmatch;
keep &id pairs &treatmnt;
retain pairs 0;
pairs=pairs+1;
&id=&id.T;
&treatmnt=&treatmnt.T;
output;
&id=&newid;
&treatmnt=&newtreat;
output;

run;

proc sort data=matched out=match;
by &id;

data matched;
merge match(in=in2) &data(in=in3 keep=&id &&&vlist);
by &id;
count=1;
if  in2 & in3 then output matched;
run;

proc freq;
tables &treatmnt*(%do i=1 %to &v_num;
                %str(&&var&i )
            %end;);
%if &title=%str() %then %do;
title "Cross tab of all the variables with &treatmnt";
%end;
%else %do;
title "&title";
%end;
run;

proc freq;
%do i=1 %to &v_num;
%str( tables pairs*&treatmnt*&&var&i/noprint cmh1;)
%end;
%if &title=%str() %then %do;
title "McNemars test on all the variables: look for column 2 estimates";
%end;
%else %do;
title "&title";
%end;
run;

%if &testall=yes %then %do;
proc sort;
by pairs &treatmnt;

data match;
set matched;
retain %do i=1 %to &v_num;
                %str(&&dvar&i )
            %end; 0;
keep &id  %do i=1 %to &v_num;
                %str(&&nvar&i &&dvar&i &&ddvar&i )
            %end;;
if &treatmnt=1 then do;
%do i=1 %to &v_num;
  %str(&&dvar&i=&&var&i+1; )
%end;
end;
if &treatmnt=2 then do;
%do i=1 %to &v_num;
  %str(&&nvar&i=&&var&i+1; &&ddvar&i=&&dvar&i-&&nvar&i;)
%end;
  output;
end;

proc univariate;
var %do i=1 %to &v_num;
                %str(&&ddvar&i )
            %end;;
title "Proc Univariate on the paired differences:treatment-control";
run;

data match;
set match;

%do i=1 %to &v_num;
ycnt&i=0;
yncnt&i=0;
ncnt&i=0;
nncnt&i=0;
if &&ddvar&i=0 & &&dvar&i=1 then ycnt&i=1;
if &&ddvar&i=0 & &&dvar&i=2  then yncnt&i=1;
if &&ddvar&i^=0 & &&dvar&i=1  then ncnt&i=1;
if &&ddvar&i^=0 & &&dvar&i=2 then nncnt&i=1;
%end;
attrib ycnt1-ycnt&v_num label="Count: same value=1"
         yncnt1-yncnt&v_num label="Count: same value=0"
         ncnt1-ncnt&v_num label="Count: diff. values:in treatment grp=0"
         nncnt1-nncnt&v_num label="Count: diff. values:in treatment grp=1";
run;

%do i=1 %to &v_num;

proc freq;
tables ycnt&i yncnt&i ncnt&i nncnt&i;
title "Concordant and Discordant counts for the variable &&var&i";
run;

%end;

%end;
%mend mcnemar9;
