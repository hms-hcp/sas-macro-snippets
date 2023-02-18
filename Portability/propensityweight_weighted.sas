*--------------------------------------------------------------------------*
| department of Health Care Policy - Harvard Medical School - Boston, MA   |
|--------------------------------------------------------------------------|
| File Name      = propensityweight.sas                                  |
| Path or URL    = /usr/apps/sas/maclib/                                   |
| Version        = 1                                                       |
| Creation Date  = 06 11 2008                                              |
| Author         = Rita Volya                                              |
| Affiliation    = HCP                                                     |
| Category       = Statistics                                                 |
| Keys           =                                                         |
|                                                                          |
|--------------------------------------------------------------------------|
| Brief Description: Propensity score matching using calipers with or      |
| without replacement 1 to 1 or 1 to many. Works with SAS v. 8 and hier    |
| You can use psmatching.sas which is faster for SAS v. 9 and up           |
---------------------------------------------------------------------------|
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
/** macro executes weighted propesity score analysis
    with overlap (variable=overlapweight) and Horvitz-Thomson
    (variable=horvitzweight).
Macro parameters:
   datain- the name of the initial data set with all the variables needed
           for the matching and further analysis.
   treatmn- the name of the treatment variable which divides DATAIN in
           2 data sets. Treatment and control Should be coded (1,2)
            The observations with TREATMN=1 are included in the treatment
            group.
   id - the name of the macro variable that has the variables
            identifying a single observation in &datain as it's value
            (there should be a statement in the SAS program before
             the macro call identifying the variable:
             Ex.: %let idvar=hicbic.tThe value of the parameter will be
 idvar).
   outcomes - suplie a list of outcomes
   predprb - the name of the variable to be used for the computation
             of predicted probability of the treatment.

  dtmodel - the name of the data set to output the results from the logistic
            procedure
  dataout - the name of the data with propensity score and weight variables
            (overlapweight horvitzweight)
  vlist  - the name of the macro variable to hold the list
           of the independent variables for the logistic procedure.
           The Lists of the variables can be any valid SAS variables list
            (there should be a statement in the SAS program before
             the macro call identifying the variable:
             Ex.: %let keep=-SAS variables list-
              the value of the parameter will be keep).

Keyword parameters:

  libin   -by default none. You can use the name of the library
           where &datain is located followed by ".". (Ex: libin=in.)

  libout -  the name of the library for the output data followed by ".".
           (Ex.:libout=mylib.), by default the name is out. To create
           a temporary data use "libout=" as a parameter.

The macro PROPMT uses 3 additional macros: COUNT_N, VARLIST, ADDRFRMT
Exemple:
**/

*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Macro Code Begins Here.                                                  |
*--------------------------------------------------------------------------*;

/*The macro PROPENSITYMATCHING is the main macro performing the matching of
  two data sets within blocks by using the propensity score*/

%macro propensityweight_weighted(datain,treatmn,outcomes,predprb,dtmodel,dataout,vlist,listnum,
          libout=out.,libin=,survweight);


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
/*
%varlist(&datain,1,&id,id,idnum,libin=&libin,attrib=yes)
*/
proc logistic data=&libin.&datain;

model &treatmn=%do i=1 %to &v_num;
               %str(&&var&i )
               %end; ;
output out=&libout&dtmodel predicted=&predprb;
run;


     data &libout&dataout;
      set &libout&dtmodel;
      array outcomes{*} &outcomes;
      if &treatmn=1 then do;
      overlapweight=1-&predprb;
      horvitzweight=1/&predprb;
      end;
      else do;
      overlapweight=&predprb;
      horvitzweight=1/(1-&predprb);
      end;
      overlapweight_new=overlapweight*&survweight;
      horvitzweight_new=horvitzweight*&survweight;

     run;

     proc sort data=&libout&dataout;
     by  &treatmn;
     run;
ods trace on;
     ods output Summary=_summ;
     ods output Statistics=_statsm;
     proc surveymeans data=&libout&dataout ;
     var &outcomes;
     weight overlapweight_new;
     by &treatmn;
     title "Propensity score weighting_weighted: overlap";
     run;

     ods output Summary=_summ1;
     ods output Statistics=_statsm1;
     proc surveymeans data=&libout&dataout ;
     var &outcomes;
     weight  horvitzweight_new;
     by &treatmn;
     title "Propensity score weighting_weighted: Horvitz-Thomson";
     run;

ods trace off;


proc print data=_statsm;
     title "Propensity scoreweighting_weighted: overlap";
run;

proc print data=_statsm1;
     title "Propensity scoreweighting_weighted: Horvitz-Thomson";
     run;

%mend propensityweight_weighted;


