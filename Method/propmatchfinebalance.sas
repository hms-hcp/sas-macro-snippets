*--------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA   |
|--------------------------------------------------------------------------|
| File Name      = propmatchfinebalance.sas                                |
| Path or URL    = /usr/apps/sas/maclib/                                   |
| Version        = 1                                                       |
| Creation Date  = 22 11 2010                                              |
| Author         = Rita Volya using the code from Marcelo Coca             |
| Affiliation    = HCP                                                     |
| Category       = Statistics                                              |
| Keys           =                                                         |
|                                                                          |
|--------------------------------------------------------------------------|
| Brief Description: Propensity score matching using calipers with fine    |
| balance 1 to 1 or 1 to many (combination of 1 to many matching|          |
| with replacement is not performed by this algorithm )   The fine balance |
| stacastically matches withing defined balancing groups by adding fake    |
| treatment having cost 0 with the controls from the same group forcing    |
| matches to unwanted controls and discurding them after the match is      |
| completed                                                                |
|--------------------------------------------------------------------------|
*--------------------------------------------------------------------------*
| Update Information: Repeat below fields for each update                  |
|--------------------------------------------------------------------------|
| Modified Date  =  DD MM YYYY                                             |
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
/** macro executes "one to one" or "one to many" optimal  matching algorithm
   with fine balance using the propensity score. It creates a data set with 
   matched pairs of observations. The pairs come from the original data that 
   is divided in two data sets by the value of the treatment variable 
   (treatment group and control group). The same treatment variable serves as 
   a dependent variable for the logistic procedure the results of which are 
   used in the propensity score computation.
   For each record from the treatment group the program selects a record
   from the control group with the closest propensity score. A pair is kept
   in the output data set if 
        distance<=caliper*STD
         where STD- std of treatment variable across the entire initial data
             distance=|logit(treatment record)-logit(control record)|
             caliper -measure of allowed distance.
                      needs to be entered as a parameter to the macro
              (ex: caliper=0.6)

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
   ballancegroup - the name of the grouping variable identifying blocks within 
                   which the fine ballance is performed. The variable should 
                  have integer values starting from "1".
               Fine ballance without exact matching means that standardized 
               differences for that variable will be 0 without implementing
               exact matching. This variable should not participate in
               defining propercity score

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

The macro PROPMATCHFINEBALANCE uses 2 additional macros: COUNT_N, VARLIST

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

%macro propmatchfinebalance(datain,treatmn,id,balancegroup,predprb,dtmodel,
       dataout,vlist,listnum, numberofcontrols=1,caliper=0.6,highvalue=10000,
       stop=no,obs=0,noint=no,libout=,libin=);

%local i ii groupnum id1T id1C id1Cdnum1 ControlsNumber status;

%if &listnum>1 %then %do;
%varlist(&datain,&listnum,&vlist,var,v_num,libin=&libin)
%end;
%else %if &listnum=1  %then %do;
%varlist(&datain,1,&vlist,var,v_num,libin=&libin)
%end;

%varlist(&datain,1,&id,id,idnum,libin=&libin,attrib=yes)
%let id1t=%trim(&id1)T;
%let id1c=%trim(&id1)C;


proc logistic data=&libin.&datain;

model &treatmn=%do ii=1 %to &v_num;
               %str(&&var&ii )
               %end; %if %upcase(&noint)=YES %then %str( /noint);;
output out=&libout.&dtmodel  predicted=&predprb;
run;


/*Next steps are to find out the stderr of propensity score differences between
  the 2 group-overall*/
     data _Treatment(rename=(pscore=pscoreT &id1=id1t &treatmn=&treatmn.T))
          _Control(rename=(pscore=pscoreC &id1=id1c &treatmn=&treatmn.C));
      set   &libout.&dtmodel; 
      keep &id1 pscore &balancegroup &treatmn;
      pscore=log(&predprb/(1-&predprb));
      if &treatmn=2 then output _Control;
      else output _Treatment;
     run;

    %count_n(_Treatment)
     %let dnum1=&n_obs;


     %count_n(_Control)
     %let ControlsNumber=&n_obs;

     proc means data=_Treatment noprint;
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

     proc means data=_Control noprint;
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
       
       proc sort data=_Treatment;
       by &balancegroup;
/*
       proc print data=_Treatment(obs=20);
       run;
*/
       proc sort data=_Control;
       by &balancegroup id1C;
       run;

        data _Control (rename=&balancegroup=grouptomatchCT);
        set _Control;
        by &balancegroup id1C;
        DistCol=left(compress("control"!!_N_));
        run;

        proc sort;
        by grouptomatchCT;
        run;


 /*find out the number of ballancing groups and number available records in each
    group for fine ballance matching*/

     proc freq data=_Control noprint;
     tables grouptomatchCT/out=_cfreq;
     run;

proc print data=_cfreq;
run;
     proc freq data=_Treatment noprint;
     tables &balancegroup/out=_tfreq;
     run;
     
     %let status=n;

     data balance;
     merge _tfreq(in=int rename=count=tcount keep=&balancegroup count)
           _cfreq(in=inc rename=(count=ccount grouptomatchCT=&balancegroup) 
                                                       keep=grouptomatchCT count)
     ;
     by &balancegroup;
     if int;
     countExtraMatch=ccount-tcount;
     keep &balancegroup countExtraMatch;
     if  countExtraMatch<0 then call symput("status", "y");
     run;

     %if %upcase(&status)=Y %then %do;
         %put "Fine balance matching can't be performed because there aren't enough controls for one or more values of balance grouping variable";
         endsas;
     %end;
     %put"status="  &status;

     %count_n(balance);
     %let groupnum=&n_obs;

      data _Treatment;
      merge _Treatment(in=in1) balance(in=in2);
       by &balancegroup;
      if in1 & in2;
      run;

      proc print data=_control(obs=20);
run;
       data DistMatrix(keep = id1T 
                     %do ii=1 %to &ControlsNumber; %str( control&ii) %end;);

       length pscoreC &treatmn.C 8 id1c %if &type1=1 %then %str( &lng1);
       %else %str( $ &lng1)  ; grouptomatchCT 8 group1-group&ControlsNumber 3 ; 
       /* Load Control dataset into the hash object */ 
       if _N_= 1 then do; 
             declare hash h(dataset: "_Control", ordered: 'ascending'); 
             declare hiter iter('h'); 
             h.defineKey("grouptomatchCT","id1c"); 
             h.defineData('pscoreC', "id1c", "&treatmn.C", "grouptomatchCT"); 
             h.defineDone(); 
             call missing(id1c, pscoreC,&treatmn.C,grouptomatchCT); 
       end; 

       /* Open the treatment */ 
       set _Treatment; 
       by &balancegroup;
       array ScoreDistance{*} control1-control&ControlsNumber;
       array groupsdummies{*} group1-group&ControlsNumber;
       rc= iter.first(); 
       if (rc=0) then i=1;
       do while (rc = 0); 
          /*mark locations of Controls with the same balance group as
           current Treatment*/
           if last.&balancegroup then do;
                 if grouptomatchCT=&balancegroup then groupsdummies{i}=1;
                                          else groupsdummies{i}=0;
           put &balancegroup= grouptomatchCT= groupsdummies{i}=;
           end;
           ScoreDistance{i}=abs(pscoreT-pscoreC);
           /*set the distance to missing (if highvalue=no) or to infinite
            value (if highvalue^=no for pairs with distance more than
            caliper* PS distance std error; Setting highvalue to 0 
            will not change the distance
           */
           if ScoreDistance{i}>&caliper*pscore_std then 
              %if %upcase(&highvalue)^=NO %then 
/*to differentiate even rejected values amoung themselves use the distance plus
  a constant 10,000 - default value*/
              %str( ScoreDistance{i}=&highvalue + ScoreDistance{i};);
                     %else %str( ScoreDistance{i}=.;);
           i=i+1;
           rc=iter.next();
           *if (rc=0) then output;
       end;
      
      output;
      if countExtraMatch>0 & last.&balancegroup then do;
       do l=1 to countExtraMatch;
       do j=1 to &ControlsNumber;
         %if %upcase(&highvalue)^=NO %then %do;
          if groupsdummies{j}=0 then ScoreDistance{j}=1000*&highvalue; 
                                                     /*make it bigger
                                                        than scaled distance*/
          else ScoreDistance{j}=0;
         %end;
         %else %do;
          if groupsdummies{j}=0 then ScoreDistance{j}=.;
           else ScoreDistance{j}=0;
         %end;
       end;
       if l=1 then do; /*all extra records will have the same treatment id*/
       %if &type1=1 %then %str(id1T=-id1T;);
       %else %str(id1T="-"!!id1T;);
       end;
       output;/*output extra raws to Distance Matrix to force the fine balance*/
       end;
      end;
      run;

%if &obs>0 %then %do;
      proc print data=DistMatrix(obs=&obs);
      run;
%end;

    %if %upcase(&stop)=NO %then %do;
/*    proc assign data=DistMatrix out=Result dec=&scale;/*scale is removed
                                                         from parameters
      cost control1-control&ControlsNumber;
      id id1T;
      run;
*/
      proc optnet data_matrix=DistMatrix;
      lap  /*linear_assignment statement*/id=(id1T) out=Result;
      run;
/*
      proc print data=Result;
      sum cost;
      run;
*/
      data result;
      set result;
       %if &type1=1 %then %str(if id1T>0;);
       %else %str(if substr(id1T,1,1)^="-";);
      run;

      proc sql;
      create table Matched as
      select b.id1C as id1C, 
             a.id1T as id1T, a.cost as psdistance, b.grouptomatchCT as
                                            &balancegroup 
      /*select b.id1C as id1C,  a.id1T as id1T*/
      from result a left join _Control b
      on a.ASSIGN=b.DistCol;
      quit;

/*      proc sql;
      create table Matched    as
      select b.id1C as id1C, 
             a.id1T as id1T, a._fcost_ as psdistance , b.grouptomatchCT as
                                            &balancegroup 
      from result a left join _Control b
      on a._ASSIGN_=b.DistCol;
      quit;*/

      proc print data=Matched(obs=20);
      run;

    proc sort data=Matched;
    by &balancegroup;
    run;

    data &libout.&dataout(rename=(id1t=&id1t id1C=&id1c)); /*&lib&dataout;*/
    set  Matched;
    ;
    by &balancegroup;
    &treatmn.C=2;
    &treatmn.T=1;
    run;
    /*
    proc print data=&libout.&dataout(obs=100);
    run;
*/
%end; /*<------ end to stop prameter*/


%mend propmatchfinebalance;


