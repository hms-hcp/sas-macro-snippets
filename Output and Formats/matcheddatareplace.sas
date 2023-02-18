*--------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA   |
|--------------------------------------------------------------------------|
| File Name      = matcheddata.sas                                         |
| Path or URL    = /usr/apps/sas/maclib/                                   |
| Version        =                                                         |
| Creation Date  = 13 NOV 2008                                             |
| Author         =                                                         |
| Affiliation    = HCP                                                     |
| Category       = Utility                                                 |
| Keys           =                                                         |
|                                                                          |
|--------------------------------------------------------------------------|
| Brief Description:                                                       |
|  Using the matched data created by %propensitymatch or by psmatching.sasF|
|  the program creates the data with 1 treatment or 1 control observation  |
|  per record with all the variables from the original data and defined by |
|  macro parameter &vlist. It creates the variable PAIRS that randes from 1|
|  to number of pairs and links matched records together.                  |
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
| Full Description:                                                        |
|--------------------------------------------------------------------------|
|  Using the matched data created by %propensitymatch or by psmatching.sasF|
|  the program creates the data with 1 treatment or 1 control observation  |
|  per record with all the variables from the original data and defined by |
|  macro parameter &vlist. It creates the variable PAIRS that randes from 1|
|  to number of pairs and links matched records together.                  |
|--------------------------------------------------------------------------|
*--------------------------------------------------------------------------*
| Instructions:                                                            |
|--------------------------------------------------------------------------|;
/*
    Macro Parameters:

   data- the name of the initial data set with all the variables needed
         for the analysis; All the variables for mc'nemar test should be coded
          (0,1). The data can be temporary or permanent data set. Use the name
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
           by the macro propmt_t.sas. Use the full name including library
           name (Ex: lib.mydata)

Macro call example:

    %let list=death30 death1y death3y;

    %matcheddata(lib.mydata,cath,hicbic,list,ctmatch)
*/
*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Macro Code Begins Here.                                                  |
*--------------------------------------------------------------------------*;
%macro matcheddatareplace(data,treatmnt,id,vlist,dmatch,lib=out.);

%let newtreat=&treatmnt.C;
%let newid=&id.C;

proc sort data =&data;
by &id;
run;

proc sort data=&lib.&dmatch out=&dmatch;
by &id.T;
run;

data test(keep=&id.T count) sum(keep=maxcount);
set &dmatch end=last;
by &id.T;
retain count maxcount 0;
if first.&id.T then count=0;
count=count+1;
if last.&id.T then do;
maxcount=max(count,maxcount);
output test;
end;
if last then output sum;
run;

proc sort data=test ;
by &id.T;
run;


data &dmatch;
if _N_=1 then set sum;
merge &dmatch(in=in1) test(in=in2);
drop count maxcount;
by &id.T;
if in1 & in2;
if count=maxcount;
run;

data matched;
set &dmatch;
keep &id &treatmnt;
&id=&id.T;
&treatmnt=&treatmnt.T;
output;
&id=&newid;
&treatmnt=&newtreat;
output;
run;

proc sort data=matched;
by &id;

data matched;
set matched;
by &id;
retain &id.weight 0;
if first.&id=1 then &id.weight=0;
&id.weight=&id.weight+1;
if last.&id;
run;

data matched;
merge matched(in=in2) &data(in=in3 keep=&id &&&vlist);
by &id;
count=1;
if  in2 & in3 then output matched;
run;

%mend matcheddatareplace;


