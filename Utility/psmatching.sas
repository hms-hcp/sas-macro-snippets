*--------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA   |
|--------------------------------------------------------------------------|
| File Name      = psmatching.sas                                          |
| Path or URL    = /usr/apps/sas/maclib/                                   |
| Version        = 1                                                       |
| Creation Date  = 06 11 2008                                              |
| Author         = Rita Volya using the code from Marcelo Coca             |
| Affiliation    = HCP                                                     |
| Category       = Statistics                                                 |
| Keys           =                                                         |
|                                                                          |
|--------------------------------------------------------------------------|
| Brief Description: Propensity score matching using calipers with or      |
| without replacement 1 to 1 or 1 to many (combination of 1 to many matching|
| with replacement is not performed by this algorithm, use propensitymatch|
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
/** macro executes "one to one" or "one to many" greedy matching algorithm
   using the propensity score. It creates a data set with matched pairs of
   observations. The pairs come from the original data that is divided in two
   data sets by the value of the treatment variable (treatment group and
   control group). The same treatment variable serves as a dependent variable
   for the logistic procedure the results of which are used in the propensity
   score computation.
   For each record from the treatment group the program selects a record
   from the control group with the closest propensity score. A pair is kept
   in the output data set if 
        distance<=caliper*STD
         where STD- std of treatment variable across the entire initial data
             distance=|logit(treatment record)-logit(control record)|
             caliper -measure of allowed distance.
                      needs to be entered as a parameter to the macro
              (ex: caliper=0.6)
    The algorithm with replacement uses all records from the control group to
    find the best match for every treatment. The algorithm without replacement
    deletes controls matched previously from the possible matches for the next
    itteration
Macro parameters:
   datain- the name of the initial data set with all the variables needed
           for the matching and further analysis.
   treatmn- the name of the treatment variable which divides DATAIN in 
           2 data sets. treatment and control Should be coded (1,2)
            The observations with TREATMN=1 are included in the treatment
            group.
   id - the name of the macro variable that has the variables
            identifying a single observation in &datain as it's value.
            (there should be a statement in the SAS program before
             the macro call identifying the variable:
             Ex.: %let idvar=hicbic. the value of the parameter will be 
 idvar).
   predprb - the name of the variable to be used for the computation
             of predicted probability of the treatment.
   blocks - the name of the variable identifying blocks within which
            the matching is performed. If the DATAIN is not divided into 
 blocks
            then the variable should be still created and have the value 
 "1" for
            all observations.
  dtmodel - the name of the data set to output the results from the logistic
            procedure
  dataout - the name of the data with the matched pairs
  vlist  - the name of the macro variable to hold the list
           of the independent variables for the logistic procedure.
           The Lists of the variables can be any valid SAS variables list.
            (there should be a statement in the SAS program before
             the macro call identifying the variable:
             Ex.: %let keep=-SAS variables list-
              the value of the parameter will be keep).

Keyword parameters:
  method=caliper- executes matching within a caliper
  caliper=0.6 -gives 0.6 value to the caliper. Change the value if you want to 
          change the caliper
  numberofcontrols=1 executes 1 to 1 matching. change to X 
                     to do 1 to many(X)  matching
  fmtlib=fmt gives a logical name to format library used by the macro. 
         By default the name is fmt. You have to have a libname statement 
         defining the library and a fmtsearch option that adds the library to 
         the sas session. The format library is used by the macro addrfrmt that         stores the formats with the addresses of the records in the same 
         blocks 
         Ex:
         libname fmt "/data/fehb/DATA/formats"
         options fmtsearch=(fmt).

  noint=no  gives a possibility to run logistic procidure without an intercept
             to do it use noint=yes, Default : run with an intercept.

  replacement=no. executes matches without replacement. use replacement=yes 
  for matches with replacement.

  rseed   =0 by default. Gives the value for a seed to the ranuni function
            used for random sorting of the data

  stop    =no by default. Use stop=yes if you want the macro to stop
           after producing the results from the logistic procedure.

  libin   -by default none. You have to use the name of the library
           where &datain is located followed by ".". (Ex: libin=in.)

  libout -  the name of the library for the output data followed by ".".
           (Ex.:libout=mylib.), by default the name is out. to create
           a temporary data use "libout=" as a parameter.

The macro PROPMT uses 2 additional macros: COUNT_N, VARLIST

OUTPUT DATA:
the macro creates a data set with matched pairs. The data has the following
variables(some of them are given to the macro through the parameters):
1.
   --unique id for the treatment group supplied by &id parameter followed
     by "T"
2.
   --unique id for the matching controls :1 and 2 make a single record
     in the output data.
     The name starts with &id followed by "C"
3.
   --treatment variable for the treatmentgroup. The name starts
   with &treatmn parameter followed by "C"  
4.
  ---treatment variable for the controls in the pair. The name starts
   with &treatmn parameter followed by "C"

5.
  --pscoreT - variable with the value of the logit function for the &treatmn
    pscoreC - variable with the value of the logit function for the treatment
             variable of the second record
   XB_DIFF=pscoreT-pscoreC
   PSCORESTD=   =sqrt((std(pscoreT)*std(pscoreT)+
                           std(pscoreC)*std(pscoreC))/2).

*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Macro Code Begins Here.                                                  |
*--------------------------------------------------------------------------*;
%macro psmatching(datain,treatmn,id,blocks,predprb,dtmodel,dataout,vlist,
    listnum, numberofcontrols=1,caliper=0.6,method=caliper,
    rseed=0,stop=no,replacement=no,noint=no,libout=,libin=);
%local ii;

%if &listnum>1 %then %do;
%varlist(&datain,&listnum,&vlist,var,v_num,libin=&libin)
%end;
/*
%else
%if &&&vlist=NULL %then %do;
 %let v_num=1;
 %let var1= ;
%end;*/
%else %do;
%varlist(&datain,1,&vlist,var,v_num,libin=&libin)
%end;

%varlist(&datain,1,&id,id,idnum,libin=&libin,attrib=yes)
%let id1t=%trim(&id1)T;
%let id1c=%trim(&id1)C;
%put "id1t=" &id1t "id1c=" &id1c;

proc logistic data=&libin.&datain;

model &treatmn=%do i=1 %to &v_num;
               %str(&&var&i )
               %end; %if %upcase(&noint)=YES %then %str( /noint);;
output out=&libout.&dtmodel predicted=&predprb;
run;

%if %upcase(&stop)=NO %then %do;

     data _Treatment(rename=(pscore=pscoreT &id1=id1t &treatmn=&treatmn.T))
          _Control(rename=(pscore=pscoreC &id1=id1c &treatmn=&treatmn.C));
      set &libout.&dtmodel;
      keep &id1 pscore &blocks &treatmn;
      pscore=log(&predprb/(1-&predprb));
      if &treatmn=2 then output _Control;
      else output _Treatment;
     run;

     proc means data=_Treatment ;
     var pscoreT;
     output out=tmeans;
     run;
/*
     proc print data=tmeans;
     run;
*/
     data tmeans;
     set tmeans;
     if _stat_="STD";
     keep pscoreT;
     run;

     proc means data=_Control;
     var pscoreC;
     output out=cmeans;
     run;

     data cmeans;
     set cmeans;
     if _stat_="STD";
     keep pscoreC;
     run;

     data dstats;
     set cmeans;
     set tmeans;
     pscorestd=sqrt((pscoreC*pscoreC+pscoreT*pscoreT)/2);
     keep pscorestd ;
     label
       pscorestd="STD Error of pscore"
     ;
     run;
/*
     proc print data=dstats;
*/

     proc freq data=&libin.&datain noprint;
     tables &blocks/out=bfreq;
     run;

   /*find out the maximum number of records in one group in data &dmatch1*/
     data _null_;
     set bfreq end=last;
     retain gcount 0;
     if &blocks>. then gcount=gcount+1;
     if last then call symput("groupnum",left(put(gcount,8.)));
     run;
/*
     %put "groupnum=" &groupnum;
*/
     data _Treatment;
     if _N_=1 then do;
         set dstats;
     end;
     set _Treatment;
     by &blocks;
     run;

/* Create copies of the treated units if N > 1 */; 
data _Treatment0(drop= i seed); 
set _Treatment; 
retain seed &rseed;
do i= 1 to &numberofcontrols; 
call ranuni(seed,RandomNumber); 
output; 
end; 
run; 
/* Randomly sort both datasets */ 
proc sort data= _Treatment0 out= _Treatment0(drop= RandomNumber); 
by &blocks RandomNumber; 
run; 

data _Control0(drop=seed); 
set _Control; 
retain seed &rseed;
call ranuni(seed,RandomNumber); 
run; 

proc sort data= _Control0 out= _Control0(drop= RandomNumber); 
by &blocks RandomNumber; 
run; 


%do i=1 %to &groupnum;

data _Control(drop=&blocks);
set _Control0;
if &blocks=&i;
run;
proc contents;
run;

data _Treatment;
set _Treatment0;
if &blocks=&i;
run;

data Matched&i(keep = IdSelectedControl MatchedToTreatID &treatmn.T &treatmn.C
                      &blocks pscoreCSelected pscoreT pscorestd BestDistance
                 rename=(IdSelectedControl=&id1c MatchedToTreatID=&id1t 
                 BestDistance=ScoreDistance  pscoreCSelected=pscoreC)); 
length pscoreC &treatmn.C 8 id1c %if &type1=1 %then %str( &lng1);
                 %else %str( $ &lng1)  ;; 
/* Load Control dataset into the hash object */ 
if _N_= 1 then do; 
declare hash h(dataset: "_Control", ordered: 'no'); 
declare hiter iter('h'); 
h.defineKey("id1c"); 
h.defineData('pscoreC', "id1c", "&treatmn.C"); 
h.defineDone(); 
call missing(id1c, pscoreC,&treatmn.C); 
end; 
/* Open the treatment */ 
set _Treatment; 
%if %upcase(&method) ~= RADIUS %then %do; 
retain BestDistance 99; 
%end; 
/* Iterate over the hash */ 
rc= iter.first(); 
if (rc=0) then BestDistance= 99; 
do while (rc = 0); 
/* Caliper */ 
%if %upcase(&method) = CALIPER %then %do; 
if (pscoreT - &caliper*pscorestd) <= pscoreC <= (pscoreT + &caliper*pscorestd)
                                          then do; 
ScoreDistance = abs(pscoreT - pscoreC); 
if ScoreDistance < BestDistance then do; 
BestDistance = ScoreDistance; 
IdSelectedControl = id1c; 
MatchedToTreatID = id1t;
pscoreCSelected=pscoreC; 
end; 
end; 
%end; 
/* NN */ 
%if %upcase(&method) = NN %then %do; 
ScoreDistance = abs(pscoreT - pscoreC); 
if ScoreDistance < BestDistance then do; 
BestDistance = ScoreDistance; 
IdSelectedControl = id1c; 
MatchedToTreatID = id1t; 
pscoreCSelected=pscoreC;
end; 
%end; 

%if %upcase(&method) = NN or %upcase(&method) = CALIPER %then %do; 
rc = iter.next(); 
/* Output the best control and remove it */ 
if (rc ~= 0) and BestDistance ~=99 then do; 
output; 
%if %upcase(&replacement) = NO %then %do; 
rc1 = h.remove(key: IdSelectedControl); 
%end; 
end; 
%end; 
/* Radius */ 
%if %upcase(&method) = RADIUS %then %do; 
if (pscoreT - &caliper) <= pscoreC <= (pscoreT + &caliper) then do; 
IdSelectedControl = idC; 
MatchedToTreatID = idT; 
pscoreCSelected=pscoreC;
output; 
end; 
rc = iter.next(); 
%end; 
end; 
run; 

%end;
%end;

%if %upcase(&stop)=NO %then %do;

data &libout.&dataout; /*&lib&dataout;*/
set %do i=1 %to &groupnum; %str(Matched&i ) %end;
;
by &blocks;
run;
%end;

/* Delete temporary tables. Quote for debugging 
%if %upcase(delete)=YES %then %do;
proc datasets; 
delete _:(gennum=all); 
%end;
run; */
%mend psmatching; 

