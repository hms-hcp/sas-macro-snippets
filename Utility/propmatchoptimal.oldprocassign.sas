*--------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA   |
|--------------------------------------------------------------------------|
| File Name      = propmatchoptimal.sas                                    |
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
/** macro executes "one to one" or "one to many" optimal matching algorithm
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
            the matching is performed. The variable should have integer values
            starting from "1".
            If the DATAIN is not divided into blocks then the variable should 
            be still created and have the value "1" for all observations.
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
  highvalue=10000 (default)- replaces the distance fith infinite value in case
                 of the distance being greater according to caliper
                 (see cliper definition below) Default is 10,000
                if "no" , a missing value is entered- in this case
                the pair is never picked by the algorithm
                if you set highvalue to 0 the distance will not change
  scale=3 (default) number used for scaling the cost data in proc assign
           (number of decimal points used in the cost data- this helps
            to make the algorithm more efficient) 

  noint=no  gives a possibility to run logistic procidure without an intercept
             to do it use noint=yes, Default : run with an intercept.

  stop    =no by default. Use stop=yes if you want the macro to stop
           after producing the results from the logistic procedure
           and to review the matrice prepared for the proc assign.
  obs - number of observations to print from the matrice of iligible matches
         0- no matrice is printed

  libin   -by default none. You have to use the name of the library
           where &datain is located followed by ".". (Ex: libin=in.)

  libout -  the name of the library for the output data followed by ".".
           (Ex.:libout=mylib.), by default the name is out. to create
           a temporary data use "libout=" as a parameter.
  caliper=0.6 -default value of caliper.
          In this algorithm the caliper is used to scale up the value of the
          distance between propensity score of Treatment and Control groups
          so the treatment/control pair is likely not picked by the optimal
          networking algorith implemented by SAS PROC ASSIGN.
          if psdistance= abs(pscoreT-pscoreC) > caliper*pscore_std
           then psdistance=100,000 * pscore_std
          where
   PSCORE_STD=   =sqrt((std(pscoreT)*std(pscoreT)+
                           std(pscoreC)*std(pscoreC))/2).

  --pscoreT - variable with the value of the logit function for the 
              treatment group
    pscoreC - variable with the value of the logit function for the control
             group

The macro PROPMATCHOPTIMAL uses 2 additional macros: COUNT_N, VARLIST

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

3. psdistance= abs(pscoreT-pscoreC)

 
*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Macro Code Begins Here.                                                  |
*--------------------------------------------------------------------------*;

/*The macro PROPENSITYMATCHING is the main macro performing the matching of 
  two data sets within blocks by using the propensity score*/

%macro propmatchoptimal(datain,treatmn,id,blocks,predprb,dtmodel,dataout,vlist,
    listnum, numberofcontrols=1,caliper=0.6,highvalue=10000,scale=3,stop=no,obs=0,noint=no,libout=,libin=);

%local i ii groupnum id1T id1C id1Cdnum1 ControlsNumber;

%if &listnum>1 %then %do;
%varlist(&datain,&listnum,&vlist,var,v_num,libin=&libin)
%end;
%else %do;
%varlist(&datain,1,&vlist,var,v_num,libin=&libin)
%end;

%varlist(&datain,1,&id,id,idnum,libin=&libin,attrib=yes)
%let id1t=%trim(&id1)T;
%let id1c=%trim(&id1)C;


 /*find out the number of groups for exact matching*/
     proc freq data=&libin.&datain;
     tables &blocks/out=bfreq;
     run;

     %count_n(bfreq);
     %let groupnum=&n_obs;

%do i=1 %to &groupnum;

proc logistic data=&libin.&datain;

model &treatmn=%do ii=1 %to &v_num;
               %str(&&var&ii )
               %end; %if &noint=yes %then %str( /noint);;
output out=&dtmodel.&i predicted=&predprb;
where &blocks=&i;
run;


/*Next steps are to find out the stderr of propensity score differences between
  the 2 group-overall*/
     data _Treatment(rename=(pscore=pscoreT &id1=id1t &treatmn=&treatmn.T))
          _Control(rename=(pscore=pscoreC &id1=id1c &treatmn=&treatmn.C));
      set &dtmodel.&i;
      keep &id1 pscore &blocks &treatmn;
      pscore=log(&predprb/(1-&predprb));
      if &treatmn=2 then output _Control;
      else output _Treatment;
     run;

    %count_n(_Treatment)
     %let dnum1=&n_obs;


     %count_n(_Control)
     %let ControlsNumber=&n_obs;

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
     pscore_std=sqrt((pscoreC*pscoreC+pscoreT*pscoreT)/2);
     keep pscore_std ;
     label
       pscore_std="STD Error of propensity score"
     ;
     run;

      proc print data=dstats;

/*
    %if &dnum1> &ControlsNumber %then %do;
                      %put "ERROR: Number of Controls is less than Number of Treatments. The programm will stop executing";
    %end;
    %else %do;
*/
        data _Treatment;
        if _N_=1 then set dstats;/*brings in pscore_std*/
        set _Treatment;
        %if &numberofcontrols=1 %then %do;
        output;
        %end;
        %else %do;
        do ii=1 to &numberofcontrols;
        output;
        end;
        %end;
        run;
/*
       proc print data=_Treatment(obs=20);
       run;
*/
       proc sort data=_Control;
       by id1C;
       run;

        data _Control;
        set _Control;
        DistCol=left(compress("control"!!_N_));
        run;

       data DistMatrix(keep = id1T 
                     %do ii=1 %to &ControlsNumber; %str( control&ii) %end;);

       length pscoreC &treatmn.C 8 id1c %if &type1=1 %then %str( &lng1);
                 %else %str( $ &lng1)  ; ; 
       /* Load Control dataset into the hash object */ 
       if _N_= 1 then do; 
             declare hash h(dataset: "_Control", ordered: 'ascending'); 
             declare hiter iter('h'); 
             h.defineKey("id1c"); 
             h.defineData('pscoreC', "id1c", "&treatmn.C"); 
             h.defineDone(); 
             call missing(id1c, pscoreC,&treatmn.C); 
       end; 

       /* Open the treatment */ 
       set _Treatment; 
       array ScoreDistance{*} control1-control&ControlsNumber;
       rc= iter.first(); 
       if (rc=0) then i=1;
       do while (rc = 0); 
           ScoreDistance{i}=abs(pscoreT-pscoreC);
           /*set the distance to missing (if highvalue=no) or to infinite
            value (if highvalue^=no for pairs with distance more than
            caliper* PS distance std error; Setteing highvalue to 0 
            will not change the distance
           */
           if ScoreDistance{i}>&caliper*pscore_std then 
              %if &highvalue^=no %then 
/*to differentiate even rejected values amoung themselves use the distance plus
  a constant 10,000-default value*/
              %str( ScoreDistance{i}=&highvalue + ScoreDistance{i};);
                     %else %str( ScoreDistance{i}=.;);
           i=i+1;
           rc=iter.next();
           *if (rc=0) then output;
       end;

      output;
      run;
%if &obs>0 %then %do;
      proc print data=DistMatrix(obs=&obs);
      run;
%end;

    %if &stop=no %then %do;
      proc assign data=DistMatrix out=Result dec=&scale;
      cost control1-control&ControlsNumber;
      id id1T;
      run;

      proc print data=Result(drop=control1-control&ControlsNumber);
      sum _fcost_;
      run;

      proc sql;
      create table MatchedOpt&i as
      select b.id1C as id1C, b.&blocks, 
             a.id1T as id1T, a._fcost_ as psdistance
      /*select b.id1C as id1C,  a.id1T as id1T*/
      from result a left join _Control b
      on a._ASSIGN_=b.DistCol;
      quit;
/*
      proc print data=MatchedOpt&i(obs=20);
      run;
*/
    %end; /*<------ end to stop parameter*/
%end;
/*%end;*/

%if &stop=no %then %do;/*put  all the results together if we run proc assign*/

    data &libout.&dtmodel; 
    set %do ii=1 %to &groupnum; %str(&dtmodel.&ii) %end;
    ;
    by &blocks;
    run;

    data &libout.&dataout(rename=(id1t=&id1t id1C=&id1c)); /*&lib&dataout;*/
    set %do ii=1 %to &groupnum; %str(MatchedOpt&ii(in=in&ii) ) %end;
    ;
    by &blocks;
    drop i;
/*group value comes from _Control data ; when number of controls is smaller
  than number of treatments the variable &blocks will have a missing value.
  The code below fills in the missing values*/
    array indata {*} %do ii=1 %to &groupnum; %str( in&&ii) %end;;
     if &blocks =. then do;
        do i=1 to dim(indata);
          if indata{i}=0 then &blocks=i;
        end;
     end;
/*the treatment/control indicators for matched pair are needed 
  to be consistent with the analysis programs developed for greedy
  matching algorithm*/
    &treatmn.C=2;
    &treatmn.T=1;
    run;
    
    proc print data=&libout.&dataout(obs=100);
    run;

%end; /*<------ end to stop prameter*/


%mend propmatchoptimal;


