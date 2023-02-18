*--------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA   |
|--------------------------------------------------------------------------|
| File Name      = impute.sas                                              |
| Path or URL    = /usr/apps/sas/maclib/                                   |
| Version        =  1                                                      |
| Creation Date  = 10 FEB 2009                                             |
| Author         = Rita Volya                                              |
| Affiliation    = HCP                                                     |
| Category       = Statistics                                              |
| Keys           =                                                         |
|                                                                          |
|--------------------------------------------------------------------------|
| Brief Description: impute missing values for categorical variables       |
|                   in the proportion existed in the data before imputation|
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
| Full Description:                                                        |
|--------------------------------------------------------------------------|
|                                                                          |
*--------------------------------------------------------------------------*
| Instructions:                                                            |
|--------------------------------------------------------------------------|;
/*
    Macro Parameters:
   var- name of the variable to be imputed
   id - unique identifyer for a record of the file 
  data- the name of the initial data set with all the variables needed
         for the imputation;
  seed= -seed to generate rundom numbers (default: seed=0);
  lib= -  the name of the library for the  input data 
          followed by "."; Default: temporary data (Ex.:lib=mylib.)
  first= - defines if the macro was called for the 1st time (if first=yes)
        default value is no;
  value9= - if yes concider value 9 as missing
Macro call example:

    %impute(age,cancer,lib=sasave.)
*/
*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Macro Code Begins Here.                                                  |
*--------------------------------------------------------------------------*;
%macro impute(var,id,data,seed=0,lib=,first=no, value9=yes);
%local vartype;

%if &first=yes %then %do;
data _type(keep=name type length);
set sashelp.VCOLUMN;
if LIBNAME="WORK" & memname="%upcase(&data)";* & name="%upcase(&nextvar)";
name=upcase(name);
run;
%end;

proc sql noprint;
select type, length
    into  :vartype 
         ,:varlen
from _type
where name="%upcase(&nextvar)";
run;
%put "type=" &vartype "length=" &varlen;

%if &vartype=char %then %do;
                 %let init=%str(" ");
                 %let valuem=%str(" ");
                 %let valuem9=%str("9");
%end;
%else %do;
          %let  init=0;
          %let valuem=%str(.);
          %let valuem9=9;
%end; 

proc freq data=&lib.&data;
tables &var/out=percentvar;
where &var^=&valuem %if &value9=yes %then %str( & &var^=&valuem9);;
title "Variable &var before imputation";
run;
/*
proc print data=percentvar;
run;
*/

%count_n(percentvar)
%let valuesnum=&n_obs;

data percentvar;
keep var1-var&valuesnum percent1-percent&valuesnum;
%if &vartype=char %then %str(length var1-var&valuesnum $ &varlen);;
retain var1-var&valuesnum &init percent1-percent&valuesnum 0;
array pct{*} percent1-percent&valuesnum;
array values{*} var1-var&valuesnum;
do i=1 to &valuesnum;
set percentvar;
values{i}=&var;
pct{i}=percent;
end;
output;
run;

proc print;

data impute;
set &lib.&data;
keep &id &var sortvar;
if &var=&valuem or &var=&valuem9;
retain seed &seed;
call ranuni(seed,sortvar);
run;

proc sort data=impute;
by sortvar;
run;
%count_n(impute)
%let totnum=&n_obs;

%do i=1 %to &valuesnum;
data impute&i(keep=&id &var) impute(keep=&id &var);
if _N_=1 then set percentvar;
set impute;
array percent{*} percent1-percent&valuesnum;
array values{*} var1-var&valuesnum;
datapercent=_N_/&totnum*100;
index=&i;
%if &i^=&valuesnum %then %do;
if datapercent<=percent{index} then do;
   &var=values{index};
   output impute&i;
end;
else output impute;
%end;
%else %do;
   &var=values{index};
   output impute&i;
%end;
run;
%end;

data impute;
set %do i=1 %to &valuesnum; %str( impute&i) %end;;
run;

proc sort;
by &id;
run;

data &lib.&data;
merge &lib.&data(in=in1) impute(in=in2 rename=&var=i&var);
by &id;
if in1 & in2 then &var=i&var;
drop i&var;
run;

proc freq;
tables &var;
title "Variable &var after imputation";
run;

%mend impute;
