*--------------------------------------------------------------------------*
| department of Health Care Policy - Harvard Medical School - Boston, MA   |
|--------------------------------------------------------------------------|
| File Name      = propensitymatching.sas                                  |
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
/** macro executes "one to one" or "one to many" greedy matching algorithm
   using the propensity score.It creates a data set with matched pairs of
   observations. The pairs come from the original data that is divided in two
   data sets by the value of the treatment variable (treatment group and
   control group). The same treatment variable serves as a dependent variable
   for the logistic procedure the results of which are used in the propensity
   score computation.
   For each record from the treatment grop program then selects a record
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
           2 data sets. Treatment and control Should be coded (1,2)
            The observations with TREATMN=1 are included in the treatment
            group.
   id - the name of the macro variable that has the variables
            identifying a single observation in &datain as it's value
            (there should be a statement in the SAS program before
             the macro call identifying the variable:
             Ex.: %let idvar=hicbic.tThe value of the parameter will be 
 idvar).
   predprb - the name of the variable to be used for the computation
             of predicted probability of the treatment.
   blocks - the name of the variable identifying blocks within which
            the matching is performed. If the DATAIN is not divided into 
 blocks
            then the variable should be still created and have the value 
 "1" for
            all observations

  dtmodel - the name of the data set to output the results from the logistic
            procedure
  dataout - the name of the data with the matched pairs
  vlist  - the name of the macro variable to hold the list
           of the independent variables for the logistic procedure.
           The Lists of the variables can be any valid SAS variables list
            (there should be a statement in the SAS program before
             the macro call identifying the variable:
             Ex.: %let keep=-SAS variables list-
              the value of the parameter will be keep).

Keyword parameters:
   numberofcontrols=1 - number of duplicate matches that are generated in 
          treatment group (DMATCH1) to a unique observation in the control 
          group(DMATCH2). By default the number is 1. Change the number to
          execute 1 to many matching.

  caliper=0.6 - identifies the maximum allowed distance between matched pairs
             of observations:
              distance<=caliper*STD of treatment variable across the entire
              DATAIN. By default: 0.6.
  fmtlib=fmt gives a logical name to format library used by the macro. 
         By default the name is fmt. You have to have a libname statement 
         defining the library and a fmtsearch option that adds the library to 
         the sas session. The format library is used by the macro addrfrmt that         stores the formats with the addresses of the records in the same 
         blocks 
         Ex:
         libname fmt "/data/fehb/DATA/formats"
         options fmtsearch=(fmt).

  noint=no . Gives a possibility to run logistic procidure without an intercept
             to do it use noint=yes, Default : run with an intercept.

  replacement=no (default value) executes matches without replacement.
              use replacement=yes for matches with replacement.

  random  =yes by default. If random=yes the data will be randomly sorted
            before the matching. If no value is provided for the parameter
            rseed then every time you ran the program a new random order
            will be generated.

  rseed   =0 by default. Gives the value for a seed to the ranuni function
            used for random sorting of the data.

  stop    =no by default. Use stop=yes if you want the macro to stop
           after producing the results from the logistic procedure.

  libin   -by default none. You can use the name of the library
           where &datain is located followed by ".". (Ex: libin=in.)

  libout -  the name of the library for the output data followed by ".".
           (Ex.:libout=mylib.), by default the name is out. To create
           a temporary data use "libout=" as a parameter.

The macro PROPMT uses 3 additional macros: COUNT_N, VARLIST, ADDRFRMT

OUTPUT DATA:
the macro creates a data set with matched pairs. The data has the following
variables(some of them are given to the macro through the parameters):
1.
   --unique id for the 1st record in the pair supplied by &id parameter
     plus letter "T" at the end. This id represents treatment record.
2.
   --unique id for the matched control record suuplied by &id parameter
     plus letter "C" in the end.
3.
   --treatment variable supplied by &treatmn parameter  and "T" in the end 
     It's value identifies treatment group
4.
  ---treatment variable for the matched control record in the pair. 
     The name starts with &treatmn followed with "C". It's value
     identifies control group

5.
  --predicted probability of the treatment variable supplied by &predprb
    parameter(1st record in the pair) followed by "T"

6.
  --predicted probability of the treatment variable for the control record of
    the pair. The name starts with &predprb followed by "C"

7.
  --pscoreT - variable with the value of the logit function for the &treatmn
    pscoreC - variable with the value of the logit function for the treatment
             variable of the second record
   PSCOREDIFF=|PSCORET-PSCOREC|
   PSCORESTD=sqrt((std(PSCORET)*std(PSCORET)+
                           std(PSCOREC)*std(PSCOREC))/2)

**/

*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Macro Code Begins Here.                                                  |
*--------------------------------------------------------------------------*;

/*The macro PROPENSITYMATCHING is the main macro performing the matching of 
  two data sets within blocks by using the propensity score*/

%macro propensitymatch(datain,treatmn,id,blocks,predprb,dtmodel,
         dataout,vlist,listnum,fmtlib=fmt,noint=no,replacement=no,
         numberofcontrols=1,caliper=0.6,rseed=0,stop=no,libout=out.,libin=);

%local i ii;

%let dpart=none;


%let newpred=&predprb.C;

%let newtreat=&treatmn.C;

%let newid=&&&id..C;
%let treatid=&&&id..T;

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

proc logistic data=&libin.&datain;

model &treatmn=%do i=1 %to &v_num;
               %str(&&var&i )
               %end; %if &noint=yes %then %str( /noint);;
output out=&libout.&dtmodel predicted=&predprb;
run;

%if &stop=no %then %do;

     data dmatch1 dmatch2;
      set &libout.&dtmodel;
      keep &predprb &id1 pscore &blocks &treatmn;
      pscore=log(&predprb/(1-&predprb));
      if &treatmn=2 then output dmatch2;
      else output dmatch1;
     run;

     proc means data=dmatch1 noprint;
     var pscore;
     output out=dmeans1;
     run;
/*
     proc print data=dmeans1;
     run;
*/
     data dmeans1;
     set dmeans1;
     if _stat_="STD";
     keep pscore;
     run;

     proc means data=dmatch2 noprint;
     var pscore;
     output out=dmeans2;
     run;

     data dmeans2;
     set dmeans2;
     if _stat_="STD";
     keep pscore;
     run;

     data dstats;
     set dmeans2(rename=pscore=npscore);
     set dmeans1;
     pscorestd=sqrt((pscore*pscore+npscore*npscore)/2);
     pscorestdT=pscore;
     pscorestdC=npscore;
     keep pscorestd pscorestdT pscorestdC;
     label
       pscorestd="STD of PSCORE"
       pscorestdT="STD of PSCORE for people from dmatch1-treatment group"
       pscorestdC="STD of PSCORE for people from dmatch2-control group"
     ;
     run;
/*
     proc print data=dstats;
*/
     %if &dpart^=none %then %do;

     data dmatch1;
      merge dmatch1(in=in1) &dpart(in=in2);
       by &id1;
      if in1 & in2;

     %end;

     proc freq data=dmatch1 noprint;
     tables &blocks/out=bfreq;
     run;

   /*find out the maximum number of records in one group in data &dmatch1*/
     data _null_;
     set bfreq end=last;
     retain maxcnt 0;
     if &blocks>. then do;
        if maxcnt<count then maxcnt=count;
     end;
     if last then call symput("dnum1",left(put(maxcnt,8.)));
     run;

     %put "maxcount=" &dnum1;

     proc freq data=dmatch2 noprint;
     tables &blocks/out=bfreq;
     run;

   /*find out the maximum number of records in one group in data &dmatch2*/
     data _null_;
     set bfreq end=last;
     retain maxcnt 0;
     if &blocks>. then do;
        if maxcnt<count then maxcnt=count;
     end;
     if last then call symput("maxnum2",left(put(maxcnt,8.)));
     run;

     %put "maxcount2=" &maxnum2;

/* find out number of records in data &dmatch2*/
     %count_n(dmatch2)
     %let dnum2=&n_obs;

        data dmatch;
        set dmatch1;
        retain seed &rseed;
        %if &numberofcontrols=1 or %upcase(&replacement)=NO %then %do;
        do i=1 to &numberofcontrols;
        call ranuni(seed,sortvar);
        output;
        end;
        %end;
        %else %do;
        call ranuni(seed,sortvar);
        do i=1 to &numberofcontrols;
        output;
        end;
        %end;
        run;

        proc sort data=dmatch out=dmatch1(drop=seed);
        by &blocks sortvar;
        run;

        data dmatch;
        set dmatch2;
        retain seed &rseed;
        call ranuni(seed,sortvar);
        run;

        proc sort data=dmatch out=dmatch2(drop=sortvar seed);
        by &blocks sortvar &id1;
        run;


     %addrfrmt(dmatch2,&blocks,block,&fmtlib)

     %let dnum1=%eval(&numberofcontrols*&dnum1);

     data v&dataout/view=v&dataout;
     if _N_=1 then do;
         set dstats;
     end;
     set dmatch1(rename=(&id1=&treatid &treatmn=&treatmn.T pscore=pscoreT
                          &predprb=&predprb.T)) end=last;
     by &blocks sortvar &treatid;
     length begend $ 12 begobs endobs $ 6 
           &newid  %if &type1=1 %then %str( &lng1);
                        %else %str( $ &lng1);
       %if %upcase(&replacement)=NO or
           (%upcase(&replacement)=YES & &numberofcontrols>1)
                               %then %str(rec1-rec&maxnum2 3);
            ;
/*remember if an observation was used for matching from control group*/
       %if %upcase(&replacement)=NO or
           (%upcase(&replacement)=YES & &numberofcontrols>1)
                             %then %str(array rec{&maxnum2};);
     retain  pscoreC &newpred pscorediff  mtch_num endmatch
           count numobs count1 0  begobs endobs " "
                   &newid  %if &type1=2 %then %str( " ");
       %if %upcase(&replacement)=NO or
           (%upcase(&replacement)=YES & &numberofcontrols>1)
                   %then %str(rec1-rec&maxnum2); 
        reccount newrec &newtreat;

     keep &treatid &newid &predprb.T &newpred &treatmn.T &newtreat &blocks
            pscoreT pscoreC pscorediff pscorestd 
          ;
     if first.&blocks then do;
          endmatch=0;
          begend=put(&blocks,BLOCKPNT.);
          begobs=substr(begend,1,6);
          endobs=substr(begend,7,6);
          put begobs= endobs=;
          numobs=0;
          count=0;/*counts # of matches within a block*/
       %if %upcase(&replacement)=NO or
          (%upcase(&replacement)=YES & &numberofcontrols>1)
                                       %then %do;
             do i=1 to &maxnum2;
                 rec{i}=0; 
              end;
       %end;
     end;
       %if %upcase(&replacement)=YES & &numberofcontrols>1
                                       %then %do;
           if first.&treatid then do;
             do i=1 to &maxnum2;
                 rec{i}=0; 
              end;
           end;
       %end;
       pscoreC=100;
       &newpred=100;
       &newtreat=.;
       newrec=0;
       &newid=" ";
       pscorediff=100;
       count1=count1+1;/*counts number of matches overall*/
       reccount=0;
               /*remembers the current observation number from controls*/
          if (begobs ne .) & (endobs ne .) & endmatch=0 then do;
          do ptr=begobs to endobs while(endmatch=0);
              set dmatch2(rename=(&predprb=c_p pscore=xb &blocks=nblockn
                             &id1=nidn &treatmn=ntreatn))
                            point=ptr;
               
               if &blocks^=nblockn then do;
                 put "Bad formating of the block addresses";
                 stop;
               end;
               reccount=reccount+1;
               select=0;
               obsnum=0;
               dif=pscoreT-xb;
               if dif<0 then dif=-dif;
               if dif>. & dif<(&caliper*pscorestd) & dif<pscorediff then do;
             %if %upcase(&replacement)=YES and &numberofcontrols=1 
                             %then %str(  select=0; go to continue; );
                 %else %do;
                   if rec{reccount}=1 then do; 
                              select=1;
                              go to continue;
                           end;
                 %end;
               end; else select=1;
     continue:
/*if a match is found remember the selection and go back to reading a new
  record from dmatch2(controls) to see if there is a better match*/
              if select=0 then do;
                 pscorediff=dif;
                 &newpred=c_p;
                 &newtreat=ntreatn;
                 pscoreC=xb;
                 newrec=reccount;
                 &newid=nidn;
              end;
          end;/*end do loop ptr*/
      end; /*end do group that checks endmatch=0*/
      if pscorediff<100 then do;
                output;
                numobs=numobs+1;/*counts matches within block*/
                /*put newrec= count=;*/
          %if %upcase(&replacement)=NO or
              (%upcase(&replacement)=YES and &numberofcontrols>1) 
                 %then %str(rec{newrec}=1;);
                  count=count+1;
/*put  &treatid= &newid= &treatmn.T= &newtreat=  pscoreT= pscoreC= pscorediff= 
    count= numobs= pscorestd= ; */
          %if %upcase(&replacement)=NO %then 
            %str(if numobs>=&numberofcontrols*(endobs-begobs+1)  then endmatch=1;);

      end; /* end do group pscorediff<100*/
     if last.&blocks or endmatch=1 then do;
          /*numobs=min(numobs,(endobs-begobs+1));*/
          mtch_num=mtch_num+numobs;
     end;

      if last then put count= mtch_num= count1=;

label
    pscorediff="Differ. in STD PSCORE of selected pair"
    &predprb.T="Pred. prob. of &treatmn/treatment data"
    &treatmn.T="Treatment var.:yes,=1;/treatment data"
    pscoreT="Linear predictor of &treatmn/treatment dt"
    &newpred="Pred. prob. of &treatmn/control data"
    pscoreC="Linear predictor of &treatmn/control dt"
    &newtreat="Treatment var.:no,=0;/control data"
    &newid="Unique id/control data"
    &treatid="Unique id/treatment data"
;
run;


data &libout.&dataout;
set v&dataout;
run;
%end;

%mend propensitymatch;


