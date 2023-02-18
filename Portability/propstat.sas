*--------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA   |
|--------------------------------------------------------------------------|
| File Name      = propstat9.sas                                           |
| Path or URL    = /usr/apps/sas/maclib/                                   |
| Version        =                                                         |
| Creation Date  = 13 11 2008                                              |
| Author         = Rita Volya                                              |
| Affiliation    = HCP                                                     |
| Category       = Statistics                                              |
| Keys           =                                                         |
|                                                                          |
|--------------------------------------------------------------------------|
| Brief Description: Computes standardized differences for the data of the |
| matched pairs of records between treatment and control groups. Should be |
| used for the data created using propensity score matching :              |
| psmatching.sas or propensitymatch.sas                                    |
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
| Full Description:                                                       |;
/* macro computes standardized differences for the data of the matched
pairs of records between treatment and control groups.
Should be used for the data created using propensity score matching.
psmatching.sas or propensitymatch.sas
*/
*|--------------------------------------------------------------------------|
   
*--------------------------------------------------------------------------*
| Instructions:                                                            |
|--------------------------------------------------------------------------|;
/*
Parameters :

varlist-the list of the variables for the analysis of means;
                    can be any valid SAS variable list;
                    They should be (0,1) or continuos variables.
         the list could be created using a macro variable.
         Ex.: %let vlist=age sex ....;(any valid SAS variables list )
         Then you could pass the value of the macro variable:

         %propstat(......,&vlist,...)

datain- the name of the input data containing all the variables from the
         lists above; you can use the output data set from the logistic
         procedure created by macro %propmt_t
treatmn- name of the treatment variable which divides the data into the
          treatment and control groups
          It's supposed to be a (1,2) variable.

Keyword parameters:

label=no if label=yes the variable labels are displayed instead of
            their names. The length for the displayed label is
            restricted to 35 characters.

lib-  library for the input data;by default a temporary data is used;
       The name of the library should be followed by ".".
save=no (default) - creates a temporary output data. Use save=yes
    to create permanent data in the library &lib.

ASSUMPTIONS:

This macro assumes that only (0,1) variables or the continuos variables
are used in the computations of standardized differences
If it's not true the macro has to be adjusted to the situation.
All the variables have to be defined for the whole population which 
makes sense because all the variables were used to do the matching.

Output Data:

  a data named &datain.stats that has the following variables
   will be created. To make the data permanent use save=yes
   The data will have the following variables:
    name - holds the names of the variables for which the standardized
           differences are computed
    namef -formatted names of the variables (is present if &format=yes);
           Gives a chance to print out the labels for the variables.
           See the description of the parameter format.
   grp1mean - means of the variables across the treatment group;
   grp2mean - means of the variable across the control group;
   stddif - standardized difference between the means in the treatment group
            and the control group (treatment-control).

   The contents of the data is printed out.

Example of macro call:
  %let list=age sex black hispanic;

  %propstat(mydata,cath,hicbic,&list,format=$varname.,lib=out.,save=yes)
*/
*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Macro Code Begins Here.                                                  |
*--------------------------------------------------------------------------*;
%macro propstat9(datain,treatmn,id,varlist,label=no,lib=,save=no);

%local i;
%local varlen labellen;

proc contents data=&lib.&datain(keep= &varlist)
    out=cont position noprint;
run;

data _null_;
set cont (keep=name label) end=eof;
retain v_num 0;
v_num=v_num+1;
call symput("mvar"||put(left(v_num),3.),name);
if label="" then call symput("mlabel"||put(left(v_num),3.),name);
    else call symput("mlabel"||put(left(v_num),3.),label);
if eof then call symput("mv_num",put(left(v_num),3.));
run;

%let varlen=15;
%let labellen=15;

%do i=1 %to &mv_num;
%put &&mvar&i &&mlabel&i;
%let len=%length(&&mvar&i);
%if &len>&varlen %then %let varlen=&len;
%let lenl=%length(&&mlabel&i);
%if &lenl>&labellen %then %let labellen=&lenl;
%end;

%put "max varlen=" &varlen "max labellen=" &labellen;

data first second;
set &lib.&datain;
if &treatmn=1 then output first;
else output second;
run;

proc means data=first noprint ;
var &varlist;
output out=firstm;
run;

proc means data=second noprint;
var &varlist;
output out=secondm;
run;

%count_n(first);
%let fstnum=&n_obs;
%count_n(second);
%let secnum=&n_obs;

data firstm;
set firstm;
length %if label=no %then %str(name $ &varlen;);
          %else %str(name $ &labellen;);
retain adj1-adj&mv_num fm1-fm&mv_num grp1mean 0 ;
array fm{&mv_num} fm1-fm&mv_num ;
array  adj{&mv_num} adj1-adj&mv_num;

if _stat_="N" then grp1mean=&mvar1;
if _stat_="MAX" then do;
     %do i=1 %to &mv_num;
       if &&mvar&i=1 then adj{&i}=100;
       else adj{&i}=1;
     %end;
end;
if _stat_="MEAN" then do;
     %do i=1 %to &mv_num;
       fm{&i}=&&mvar&i;
     %end;
end;

if _stat_="STD" then do;
        name="Obs. No.";
        grp1std=0;
        output;
    %do i=1 %to &mv_num;
        grp1mean=fm{&i}*adj{&i};
        grp1std=&&mvar&i;
        %if label=no %then %str(name="&&mvar&i";);
          %else %str(name="&&mlabel&i";);
        output;
    %end;
end;

keep name grp1mean grp1std;
run;

*proc print;

%if &labellen>35 %then %let labellen=35;
 
data secondm;
set secondm;
length %if label=no %then %str(name $ &varlen;);
          %else %str(name $ &labellen;);
retain adj1-adj&mv_num sm1-sm&mv_num grp2mean 0;
array sm{&mv_num} sm1-sm&mv_num ;
array  adj{&mv_num} adj1-adj&mv_num;

if _stat_="N" then grp2mean=&mvar1;
if _stat_="MAX" then do;
     %do i=1 %to &mv_num;
       if &&mvar&i=1 then adj{&i}=100;
       else adj{&i}=1;
     %end;
end;
if _stat_="MEAN" then do;
     %do i=1 %to &mv_num;
       sm{&i}=&&mvar&i;
     %end;
end;

if _stat_="STD" then do;
        name="Obs. No.";
        grp2std=0;
        output;
    %do i=1 %to &mv_num;
        grp2mean=sm{&i}*adj{&i};
        grp2std=&&mvar&i;
        %if label=no %then %str(name="&&mvar&i";);
          %else %str(name="&&mlabel&i";);
        output;
    %end;
end;

keep name grp2mean grp2std;
run;

*proc print;

data %if &save=yes %then %str(&lib.);&datain.stats;
set firstm;
set secondm;
if _N_^=1 then do;
mstd=sqrt((grp1std*grp1std+grp2std*grp2std)/2);
stddif=(grp1mean-grp2mean)/mstd;
end;
keep name grp1mean grp2mean stddif;
label
     name="VARIABLE NAME"
     grp1mean="MEAN/TREATMENT GROUP"
     grp2mean="MEAN/CONTROL GROUP"
     stddif="STD. DIFFERENCE"
;
run;

proc print data=%if &save=yes %then %str(&lib.);&datain.stats;
run;

%mend propstat9;


