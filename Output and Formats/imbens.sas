*--------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA   |
|--------------------------------------------------------------------------|
| File Name      = imbens.sas                                              |
| Path or URL    = /usr/apps/sas/maclib/                                   |
| Version        =  1                                                      |
| Creation Date  = 13 NOV 2008                                             |
| Author         = Rita Volya                                              |
| Affiliation    = HCP                                                     |
| Category       = Statistics                                              |
| Keys           =                                                         |
|                                                                          |
|--------------------------------------------------------------------------|
| Brief Description: perform propensity score analysis based on Imbens     | 
|                    approach for more than 2 treatment groups             |
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
| Perform propensity score analysis based on Imbens approach for           |
| compairing several treatment groups. It creates the output data with the |
| following variables : variable name, estimate, std err., lower level,    |
| uper level.                                                              |
| It works with 1 outcome at a time. If you need a second outcome you might|
| use parameters logistic=no, adjusted=no and give the name of the data    |
| produced by the previous call containing the predicted probabilities as  |
| parameter model for the next macro call                                  |
*--------------------------------------------------------------------------*
| Instructions:                                                            |
|--------------------------------------------------------------------------|;
/*
    Macro Parameters:

   id - the name of the variable that identifies a single observationin &data
        (unique key)
   treatment- treatment variable which divides DATA into n treatment group
            and cont. Should be coded (1,2,3,...,N), where
            N-number of treatment groups
   outcome - the name of a categorical outcome variable
   covariates - the name of the macro variable to hold the list
           of the all the variables for McNemar's test
           The Lists of the variables can be any valid SAS variables list;
            (there should be a statement in the SAS program before
             the macro call identifying the variable:
             Ex.: %let keep=-SAS variables list-;
              the value of the parameter will be keep);
            You can use any number of variables to perform the test.
   data- the name of the initial data set with all the variables needed
         for the analysis; all the variables used in propensity score
         computation should be coded (0,1) unless continuous.
         The data can be temporary or permanent data set. Use the name
         of the library with the data set name as a parameter if it's a
         permanent data: Ex: lib.mydata;

   model - the name of the data with the predicted probabilities created 
           by the logistic procedure inside the macro or it can be as
           input data when parameter logistic=no
  estimates - (default: estimates=parms) the name of the data with the results
              of the analysis
  libin= -  the name of the library for the  input data 
          followed by "."; Default: temporary data (Ex.:libin=mylib.)
  libout= -  the name of the library for the data with analysis results
          followed by ".";  Temporary data by default (Ex.:libout=mylib.)
  title- use %let statement to assign a title:
            %let title="Imbens approch ";
            ...,title=&title,...
  logistic=yes- runs logistic procedure; use "logistic=no" and give the name 
                of file as parameter model if you want to use already computed
                predicted probability and avoid rerunning proc logistic
  adjusted=yes-by default; Use adjusted=no if you are running the macro for
               the second or more outcomes and adjusted values of parameters 
               are already computeds previously; In this case only adjusted 
               values for the outcome will be computed, stored and displayed
Macro call example:

    %let list=ade male white...;

    %imbens(seer_id,surgery,death,list,cancer,estimates=imbensresults,
            libout=sasave.)
*/
*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Macro Code Begins Here.                                                  |
*--------------------------------------------------------------------------*;
%macro imbens(id,treatment,outcome,covariates,data,model=model,estimates=parms,libin=,libout=,title=,logistic=yes,adjusted=yes);
/*create macro variables for parameters*/
 %local i j l;
 %let i=1;
proc contents data=&libin&data(keep=&&&covariates) noprint out=cont position;
run;
%count_n(cont)

%let vnum=&n_obs;
%global varnames;

proc sql noprint;
select name 
    into  : varnames separated by " "
from cont;
/*%put "names:" &varnames;*/

 %do %while(%length(%scan("&varnames",&i," "))>0);
    %global x&i;
    %let x&i=%trim(%scan("&varnames",&i," "));
   /* %put &&x&i;*/
    %let i=%eval(&i+1);
  %end;
  %let xnum=%eval(&i-1);

/*define the number of levels of treatment variable;*/
 proc freq data=&libin.&data noprint;
 tables &treatment/out=tfreq;
 run;

%count_n(tfreq);
%let tnum=&n_obs;

proc sql noprint;
select &treatment
    into  : tlevels separated by ","
from tfreq;
/*%put "tlevels:" &tlevels;*/

 %let i=1;
 %do %while(%length(%scan("&tlevels",&i,","))>0);
    %global tlevel&i;
    %let tlevel&i=%trim(%scan("&tlevels",&i,","));
  /*  %put &&tlevel&i;*/
    %let i=%eval(&i+1);
  %end;

/*total number of observations in the data*/
%count_n(&libin.&data)
%let totobs=&n_obs;
/*creates a numeric treatmentvariable  with values (1,2,...) corresponding to 
 the supplyed character or numeric variable; the values will be given in the 
 alphabetical order of the values of the variable supplied*/
data &data;
set &libin.&data;
%do i=1 %to &tnum;
 if &treatment="&&tlevel&i" then n&treatment=&i;
%end;
run;

  %let proplist=%str( );
  %do l=2 %to &tnum;
    %let proplist=&proplist%str( propscr&l);
  %end;
/* if logistic is "no" - we assume that there is a data with predicted 
   probabilities already*/
%if &logistic=yes %then %do;
proc logistic data=&libin.&data ;
model n&treatment(descending)=&&&covariates/link=glogit;
output out=predprob pred=ptreat;
title "Imbens Analysis";
run;
%end;
%else %do;
data  predprob;
set &libout.&model;
run;
%end;

data pred;
set predprob(keep=&id &outcome _level_ ptreat &&&covariates n&treatment);
by &id descending _level_;
retain propscr1 &proplist ;
*xbeta=log(ptreat/(1-ptreat));
if first.&id then do;
%do l=&tnum %to 1 %by -1;
 propscr&l=.;
%end;
end;

%do l=&tnum %to 1 %by -1;
if _level_=&l then do;
          propscr&l=ptreat;
end;
%end;

keep &id &&&covariates &outcome n&treatment propscr1 &proplist ;
if last.&id then output;
run;
/*
proc print data=pred (obs=100);
run;
*/

/*define estimates for outcome and covariates for each treatment group*/
%do j=1 %to &tnum;

proc rank data=pred group=5 out=rankp ;
var propscr&j;
ranks rankp;
run;

proc sort;
by rankp;
run;

proc means data=rankp noprint;
var &outcome &&&covariates;
by rankp;
output out=mean;
where n&treatment=&j;
run;
/*
proc print;
title3 "Propensity score &j";
run;
proc freq data=rankp;
tables rankp;
where n&treatment=&j;
run;
*/

proc freq data=rankp noprint;
tables n&treatment/out=freq;
by rankp;

/*number of ppeople receiving treatment &j in each quintile of propensity
  score &j*/
data freq1;
set freq;
keep rankp count;
if n&treatment=&j;
run;
/*
proc print;
title3 "Propensity score &j";
run;
*/
/*number of people in each quintile of propensity score &j receiving
  all treatments*/
data freq2;
set freq;
by rankp;
retain countr 0;
if first.rankp then countr=0;
countr=countr+count;
keep rankp countr;
if last.rankp then output;
run;
/*
proc print;
title3 "Propensity score &j";
run;
*/
data mean&j;
merge mean(in=in1) freq1(in=in2) freq2(in=in3)  end=last;
by rankp;
if in1 & in2 & in3 ;
keep &outcome.pred&j &outcome.var&j %do i=1 %to &xnum; %str( &&x&i..adjusted&j ) %end;;
retain mean1 mean2 mean3 mean4 mean5 countr1-countr5
       count1-count5 std1 std2 std3 std4 std5 
       %do i=1 %to &xnum; %str( mn&&x&i..1-mn&&x&i..5 ) %end; ;

array mn{*} mean1 mean2 mean3 mean4 mean5 ;
array std{*} std1 std2 std3 std4 std5 ;
array cnt{*} count1-count5;
array cntr{*} countr1-countr5;
%do i=1 %to &xnum;
array mn&&x&i{*} mn&&x&i..1-mn&&x&i..5 ;
%end;

if _STAT_="MEAN" or _STAT_="STD" ;
rankp=rankp+1;/*to shift the range from 0 to 1*/
if cnt{rankp}=. then cnt{rankp}=count;
if cntr{rankp}=. then cntr{rankp}=countr;
if _STAT_="MEAN" then do; 
               mn{rankp}=&outcome;
               %do i=1 %to &xnum;
                   mn&&x&i{rankp}=&&x&i;
               %end;
   /* put mn{rankp}= %do i=1 %to &xnum;
                   %str( mn&&x&i{rankp}=)
               %end; ;*/
end;  
if _STAT_="STD" then std{rankp}=&outcome;

if last then do;
 &outcome.pred&j=0; 
 &outcome.var&j=0;
 %do l=1 %to &xnum;
  &&x&l..adjusted&j=0;
 %end;
 do i=1 to 5;
      &outcome.pred&j=&outcome.pred&j+((cntr{i}/&totobs)*mn{i});
      &outcome.var&j=&outcome.var&j+((cntr{i}*cntr{i})/(&totobs*&totobs))*
                             ((std{i}*std{i})/cnt{i});
      %do l=1 %to &xnum;
         &&x&l..adjusted&j=&&x&l..adjusted&j+((cntr{i}/&totobs)*mn&&x&l{i});
      %end;
/*
put &outcome.pred&j= cnt{i}= mn{i}= cntr{i}= std{i}=  &outcome.var&j= 
&x3.adjusted&j=;
;*/
 end;
 output;
end;
run;
/*
proc print;
title3 "Propensity score &j";
run;
*/
%end;

/*data with estimates*/
data parms;
%do l=1 %to &tnum;
set mean&l;
%end;
length variable $ 16;
retain variable ' ' ul ll  estimate; 
keep variable estimate ul ll stderr diffestimate difful diffll diffstderr 
     %do i=1 %to &xnum; %str( &&x&i..adjusted) %end;;


%do l=1 %to &tnum;
variable="&&tlevel&l";
/*this code produces differences of the estimates compared to treatment=1*/
estimate=&outcome.pred&l;
stderr=sqrt(&outcome.var&l);
ul=estimate+1.96*stderr;
ll=estimate-1.96*stderr;
%if &l>=2 %then %do;
diffestimate=&outcome.pred&l-&outcome.pred1;
diffstderr=sqrt(&outcome.var&l+&outcome.var1);
difful=diffestimate+1.96*diffstderr;
diffll=diffestimate-1.96*diffstderr;
%end;
%else %do;
diffestimate=.;
diffstderr=.;
difful=.;
diffll=.;
%end;

%do i=1 %to &xnum;
 &&x&i..adjusted= &&x&i..adjusted&l;
%end;
/*put _all_;*/
/*put &x1.adjusted&l= &x2&adjusted&l=;*/
output;
%end;

run;

/*
proc print;
title "Imbens: Analysis results";
title2 " &title ";
run;
*/
proc transpose data=parms out=parmst;
run;

data &libout&estimates;
set parmst(rename=(%do i=1 %to &tnum; %str(col&i=treatment&i ) %end;));
/*
drop %do i=1 %to &tnum; %str( col&i) %end;;*/
label 
%do i=1 %to &tnum;
%str( treatment&i="&&tlevel&i" )
%end;
;
run;

proc print data=&libout&estimates %if &adjusted^=yes %then %str((obs=8)); noobs label;
var _Name_ %do i=1 %to &tnum; %str( treatment&i) %end;; 
label
_Name_ = "Variable Name"
%do i=1 %to &tnum;
%str( treatment&i="&&tlevel&i" )
%end;
;
 
title "Imbens: Analysis results";
title2 " &title ";
run;

%if &logistic=yes %then %do;
data &libout.&model;
set predprob;
run;
%end;
%mend imbens;
