/*Programmer: Margaret Volya

   This macro is the third macro for the propensity score analysis.

   The macro %mcnemar:

    1. performs McNemar's Test of pairs of records:
       a. using proc freq to compute Cochran-Mantel-Haenszel Statistics
          and Estimates of the Common Relative Risk.
       b. using proc univariates on the difference in the values of the 
 variable
       in the pair. The name of the variable for the differences starts with
       "dd" and uses 6 first digits of the actual name of the variable. Make
       sure that there is no duplicates in 6 digits of the names.
    2. calculates how many pairs have the same values and how many have
       different values in the paired records
       ( number of concordant and discordant values).

   The macro uses Title statement for all the procedures which are important
   for understanding the printout. To produce more titles use statements 
Title
   and other;

   The macr uses macros %count_n and %varlist
    Macro Parameters:

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
          followed by ".";  (Ex.:libout=mylib.),

Macro call example:

    %let list=death30 death1y death3y;

    %mcnemar(lib.mydata,cath,hicbic,list,ctmatch,out.)

*/

%macro lifetestmatched(data,treatmnt,id,vlist,othervars,dmatch,lib,title=);

%local i;

%if %length(&treatmnt)>7 %then %let newtreat=n%substr(&treatmnt,1,7);
%else %let newtreat=n&treatmnt;

%if %length(&id)>7 %then %let newid=n%substr(&id,1,7);
%else %let newid=n&id;
/*
proc contents data=&data(keep=&&&vlist) out=cont noprint;
run;

%count_n(cont)
%let vnum=&n_obs;

%do i=1 %to &vnum;
%global var&i;
%end;
*/
%varlist(&data,1,&vlist,var,v_num)

%do i=1 %to &v_num;

%if %length(&&var&i)>7 %then %let nvar&i=n%substr(&&var&i,1,7);
%else %let nvar&i=n&&var&i;

%if %length(&&var&i)>7 %then %let dvar&i=d%substr(&&var&i,1,7);
%else %let dvar&i=d&&var&i;

%if %length(&&var&i)>6 %then %let ddvar&i=dd%substr(&&var&i,1,6);
%else %let ddvar&i=dd&&var&i;

%end;

proc sort data =&data;
by &id;

data matched;
set &lib.&dmatch;
keep &id pairs &treatmnt;
retain pairs 0;
pairs=pairs+1;
if &treatmnt=2 then  &treatmnt=0;
output;
&id=n&id;
&treatmnt=&newtreat;
if &treatmnt=2 then  &treatmnt=0;
output;

run;

proc sort data=matched out=match;
by &id;

data matched;
merge match(in=in2) &data(in=in3 keep=&id &&&vlist &&&othervars);
by &id;
count=1;
if  in2 & in3 then output matched;
run;
proc univariate;
var &var1;
where &treatmnt=1 & censor=1;
run;
proc univariate;
var &var1;
where &treatmnt=0 & censor=1;
run;

/*
ods html;
ods graphics on;
*/
*goption device=gif;
%do i=1 %to &v_num;
proc lifetest data=matched
          plots=(s);
time &&var&i*censor(0);
/*id &id;*/
strata &treatmnt; 
run;
%end;
%macro test;
%do i=1 %to &v_num;
proc lifetest data=matched
          plots=(s);
time &&var&i*censor(0);
/*id &id;*/
strata pairs/group=&treatmnt; 
run;
%end;
/*
ods graphics off;
ods html close;
*/
%mend test;
%mend lifetestmatched;













