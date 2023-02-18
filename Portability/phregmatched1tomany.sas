*--------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA   |
|--------------------------------------------------------------------------|
| File Name      =phregmatched1tomany.sas                                  |
| Path or URL    = /usr/apps/sas/maclib/                                   |
| Version        = I                                                       |
| Creation Date  = December 92009                                          |
| Author         = Rita Volya                                              |
| Affiliation    = HCP                                                     |
| Category       = Statistics                                              |
| Keys           =                                                         |
| Macros used    = genvarloop                                              |
|--------------------------------------------------------------------------|
| Brief Description: Performs conditional logistic analysis on the data    |
| created by propensity score 1 to many without replacement matching       |
|--------------------------------------------------------------------------|
*--------------------------------------------------------------------------*;

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
| Full Description:  Performs conditional logistic analysis on the data    |
| created by propensity score 1 to many without replacement matching       |
| The macro takes the data created by %psmatching or %propensitymatch      |   
|--------------------------------------------------------------------------|
   
*--------------------------------------------------------------------------*;
/*
 Instructions:   
   Parameters:
   alldata- name of the data that has outcomes
   matcheddata- name of the data that has matched pairs
                this data has to be created by %psmatching or 
                %propensitymatch or have the same structure
  matchnum- number of matches from the control group to a single record 
            treatment group
  id-name of the variable that identifies a single record in the data
                  &alldata
  pairs- name of the variable that identifies all matches from control group
         to a single record from the treatment group. This variable will
         be a counter(from 1 to number of unique ids in the treatment group
         that has &matchnum matches.
  treatment- name of the variable that identifies treatment and control 
             groups; it can be (0,1) or (1,2) variable. Thhe macro will
             recode (1,2) to (0,1)
  Keyword parameter:
  outcomes= -the list of all outcomes to be analyzed (can be provided using 
             another macro variable
    Ex: outcomes=&varlist
  libm= name of the library with the matched data. Default is WORK
  liball= name of the library where &alldata is located. Default is WORK

Example of macro call:
%let vars=chemoclaims--survival6;
%let outcomes=%str( );
%listvars(cancer,vars,outcomes); /*this macro was used to create a list of 
        variable names separated by blank; do not use it if you have a list
        of outcomes like %let outcomes=chemoclaims survival6;
%put &outcomes;

 %phregmatched1tomany(cancer,matches,2,seer_id,pairs,bcs,outcomes=&outcomes)
|--------------------------------------------------------------------------|*/

*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Macro Code Begins Here.                                                  |
*--------------------------------------------------------------------------*;

%macro phregmatched1tomany(alldata,matcheddata,matchnum,id,pairs,
                           treatment,outcomes=,libm=work,liball=work);


proc sort data=&libm..&matcheddata out=&matcheddata;
by &id.T;
run;

data validmatches(keep=&id.T);
set &matcheddata;
by &id.T;
if first.&id.T then do;
count=0;
end;
count+1;
if last.&id.T & count=&matchnum then output validmatches;
run;

data &matcheddata;
merge &matcheddata(in=in1) validmatches(in=in2);
by &id.T;
if in1 & in2;
run;

data &matcheddata;
set &matcheddata;
by &id.T;
retain &pairs 0;
keep &id &treatment &pairs;
if first.&id.T then do;
             &id=&id.T;
             &treatment = &treatment.T;
             &pairs=&pairs+1;
             output;
end;
&treatment = &treatment.C;
if &treatment=2 then &treatment=0;
&id=&id.C;
output;
run;

proc sort data=&liball..&alldata out=&alldata;
by &id;
run;

proc sort data=&matcheddata;
by &id;
run;

data &matcheddata;
merge &matcheddata(in=in1) &alldata(in=in2 keep=&id
                         %genvarloop(varlist=&outcomes,code=%nrstr(&nextvar )))
;
by &id;
if in1 & in2;
run;

%genvarloop(varlist=&outcomes,code=%nrstr(proc freq data = &matcheddata;
           tables &nextvar*&treatment;
            run;
            proc phreg data = &matcheddata;
            model &nextvar = &treatment / ties = discrete risklimits;
            strata &pairs;
            run;
))
%mend phregmatched1tomany;
