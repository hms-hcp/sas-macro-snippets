%macro _charlsn(data=, out=, id=, dateadm=, datesep=, diags=,
         procs=, index=, tables=no, debug=no) / stmt;

%***************************************************************;
%*                                                             *;
%*  NOTE:  This CCI is a MODIFIED version of the original CCI. *;
%*     Sally apparently used the ICD-9-CM (1979) to create the *;
%*     code from Mary Charlson''s paper some years ago.  Then, *;
%*     based on several clinicians'' review, the CCI was       *;
%*     modified, and has gone through several incarnations     *;
%*     since (eg. see f=cci_aug89).                            *;
%*                                                             *;
%*  NOTE:  1 change made to code that Sally sent -             *;
%*         '4292' replaced '4192' - appears it was an error    *;
%*                                                             *;
%*  NOTE: Pluses added in cancer statement for PCHLSON and     *;
%*        XCHLSON13.1.93 as per Sally''s e-mail (previously    *;
%*        they were 'or'ed)                                    *;
%*                                                             *;
%***************************************************************;

%* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *;
%*   This file has the appropriate codes etc commented out           *;
%*   as per Dr Romano''s FAX of 21.12.92.                            *;
%*   This is the Charlson program modified for the Manitoba-         *;
%*   Dartmouth ICDM codes.                                           *;
%*   Weighting as per Charlson paper                                 *;
%*   PCHARLSON calculated for 0-12 mos before index event            *;
%*   Four digits specified in most cases for the ICDM codes          *;
%*   Melanoma and skin cancer commented out 14.1.93                  *;
%* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *;

%put;
%put Modified Charlson Comorbidity Index macro, October 1998;
%put Original program written by Sally Sharp, modified by Leonie Stranc;
%put Macro version by Randy Walld;
%put;
%* this macro was modified to add upcase() functions to the proc sql
   statements to account for case sensitivity in SAS v7 and greater.
   January 8, 2001. ;

%* Convert some parameters to lower case;
%let tables = %lowcase(&tables);
%let debug = %lowcase(&debug);
%if tables = y %then %let &tables = yes;
%if debug = y %then %let &debug = yes;

%* Check to see if required paramters are present;
%if &data= | &id= | &dateadm= | &datesep= | &index= %then %goto error10;

%* Debugging option;
%if &debug = debug | &debug = yes %then options mprint notes;
%else options nomprint nonotes;;

%* Check to see if dataset exists and required variables are present;
%let chk1=0;
%let chk2=0;
%let chk3=0;
%let chk4=0;
%let chk5=0;
%let chk6=0;
%let chk7=0;
%let chk8=0;
%let chk9=0;
%let dxv1=%scan(&diags,1);
%let pxv1=%scan(&procs,1);
%let dxv2=%scan(&diags,2);
%let pxv2=%scan(&procs,2);

%if %index(&data,.) %then %do;
   %let libname=%scan(&data,1);
   %let data=%scan(&data,2);
%end;
%else %do;
   %let libname=WORK;
%end;
proc sql noprint;
      select nobs into :chk1
      from dictionary.tables
      where libname=%upcase("&libname")  and
            memname=%upcase("&data") and
            (memtype='DATA' or memtype='VIEW');
      select varnum into :chk2
      from dictionary.columns
      where libname=%upcase("&libname") and
            memname=%upcase("&data") and
            (memtype='DATA' or memtype='VIEW') and
            (upcase(name)=%upcase("&id"));
      select varnum into :chk3
      from dictionary.columns
      where libname=%upcase("&libname") and
            memname=%upcase("&data") and
            (memtype='DATA' or memtype='VIEW') and
            (upcase(name)=%upcase("&dateadm"));
      select varnum into :chk4
      from dictionary.columns
      where libname=%upcase("&libname") and
            memname=%upcase("&data") and
            (memtype='DATA' or memtype='VIEW') and
            (upcase(name)=%upcase("&datesep"));
      select varnum into :chk5
      from dictionary.columns
      where libname=%upcase("&libname") and
            memname=%upcase("&data") and
            (memtype='DATA' or memtype='VIEW') and
            (upcase(name)=%upcase("&index"));
      select varnum into :chk6
      from dictionary.columns
      where libname=%upcase("&libname") and
            memname=%upcase("&data") and
            (memtype='DATA' or memtype='VIEW') and
            (upcase(name)=%upcase("&dxv1"));
      select varnum into :chk7
      from dictionary.columns
      where libname=%upcase("&libname") and
            memname=%upcase("&data") and
            (memtype='DATA' or memtype='VIEW') and
            (upcase(name)=%upcase("&pxv1"));
      select varnum into :chk8
      from dictionary.columns
      where libname=%upcase("&libname") and
            memname=%upcase("&data") and
            (memtype='DATA' or memtype='VIEW') and
            (upcase(name)=%upcase("&dxv2"));
      select varnum into :chk9
      from dictionary.columns
      where libname=%upcase("&libname") and
            memname=%upcase("&data") and
            (memtype='DATA' or memtype='VIEW') and
            (upcase(name)=%upcase("&pxv2"));
quit;
%if &chk1=0  %then %goto error1;       %* No dataset;
%else %if &chk2=0 %then %goto error2;  %* No ID;
%else %if &chk3=0 %then %goto error3;  %* No DATEADM;
%else %if &chk4=0 %then %goto error4;  %* No DATESEP;
%else %if &chk5=0 %then %goto error5;  %* No INDEX;
%else %if &chk6=0 %then %goto error6;  %* No starting variable in range DXxx-DXyy;
%else %if &chk7=0 %then %goto error7;  %* No starting variable in range OPxx-OPyy;
%else %if &chk8=0 %then %goto error8;  %* No ending variable in range DXxx-DXyy;
%else %if &chk9=0 %then %goto error9;  %* No ending variable in range OPxx-OPyy;

%put Input dataset:                   &libname..&data;
%put Output dataset:                  &out;
%put Individual identifier:           &id;
%put Admission date variable:         &dateadm;
%put Discharge date variable:         &datesep;
%put Diagnosis code variables:        &diags;
%put Procedure code variables:        &procs;
%put Variable flagging index record:  &index;
%put;

proc sort data=&data out=_d1;
by &id descending &index &dateadm;
run;

* Take DATEADM for the record flagged as index (the first one if more than one;
* is flagged) and retain it as IADMDATE;

data _d1;
set _d1;
by &id descending &index &dateadm;
retain iadmdate;
if first.&id and &index=1 then iadmdate=&dateadm;
run;

*******************  Charlson Program  ************************;

%MACRO FLAGSET(VAR,FLAG,NFLAGS,POSISHN);
   &FLAG = &POSISHN;
   &NFLAGS = &NFLAGS + 1;
   &VAR = 1;
%MEND;

%LET SXVARSTR = &PROCS;
%LET DXVARSTR = &DIAGS;

data _COVAR;
set _d1 (KEEP = &DIAGS &PROCS &ID &DATEADM &DATESEP
                       &INDEX IADMDATE);
by &ID;
   RETAIN CVP36501-CVP36561 CVINDX01-CVINDX61;
   LENGTH DEFAULT=3;
   ARRAY CLP365 {61} CVP36501-CVP36561;
   ARRAY CLINDX {61} CVINDX01-CVINDX61;
   ARRAY COVAR  {61} ANGINA1 ANGINA2 ARRHYTH1 ARRHYTH2 VALVE1 VALVE2
                     ACUTEMI OLDMI CHF HBP1 HBP2 VASCUL1 VASCUL2 CVD
                     PULMON1 PULMON2 NEURO_OT DEMENTIA PARALYS ENDO_OT
                     DIABET1 DIABET2 DIABET3 RENAL1 RENAL2 LIVER1 LIVER2
                     ULCERS INBOWDIS LIPCA ORALCA ESOPHCA STOMCHCA
                     SMLINTCA COLONCA LIVBILCA OTHDIGCA UPAIRCA LUNGCA
                     OTCHSTCA PRMBONCA MELANOMA SKINCA BREASTCA FEMGUCA
                     PROSTCA MALEGUCA BLDKIDCA EYECA CNSCA ENDOCA OTHERCA
                     KAPOSI PARPRTCA SECONDCA LYMPHOMA LEUKEMIA SOLIDCA
                     LYMPLEUK RHEUM AIDS;
   ARRAY SX $ &SXVARSTR;
   ARRAY DX $ &DXVARSTR;
   ARRAY FLAGS {*} FLAG01-FLAG61;

   IF FIRST.&ID THEN DO;
      DO M=1 TO 61;
         CLP365{M}=0;
         CLINDX{M}=0;
      END;
   END;

   DO M=1 TO 61;
      COVAR{M}=0;
      FLAGS{M}=0;
   END;
   NFLAGS=0;

   DO OVER DX;

      IF DX=' ' THEN GO TO OUTDX;

  *** angina, arrhythmia, valvular heart disease, hypertension,  ***;
  *** neuro_ot, endo other, inflam. bowel disease, all commented ***;
  *** out 9/12/92.                                               ***;

     *********** ANGINA ******** NO WEIGHT *****;

/*      IF ANGINA1=0 THEN DO;
         IF '413  ' <=DX<= '4140 ' | '4148 ' <=DX<= '4149 ' |
            '4292 '  =DX THEN DO;
                 %FLAGSET(ANGINA1,FLAGS{NFLAGS+1},NFLAGS,1);
            END;
      END;

      IF ANGINA2=0 THEN DO;
         IF '4111 ' <=DX<= '4118 ' THEN DO;
                 %FLAGSET(ANGINA2,FLAGS{NFLAGS+1},NFLAGS,2);
            END;
      END;
*/
     ********** ARRHYTHMIA **** NO WEIGHT *****;
/*
      IF ARRHYTH1=0 THEN DO;
         IF '42612' <=DX<= '4269 ' | '427  ' <=DX<= '4270 ' |
            '4272 ' <=DX<= '42732' | '4278 ' <=DX<= '42789'
            THEN DO;
                 %FLAGSET(ARRHYTH1,FLAGS{NFLAGS+1},NFLAGS,3);
            END;
      END;

      IF ARRHYTH2=0 THEN DO;
         IF '4274 ' <=DX<= '4275 ' | '4260 ' = DX | '4271 ' = DX |
            'V450 ' = DX THEN DO;
                  %FLAGSET(ARRHYTH2,FLAGS{NFLAGS+1},NFLAGS,4);
         END;
      END;
*/
     ************* VALVULAR HEART DISEASE **** NO WEIGHT ************;

/*      IF VALVE1=0 THEN DO;
         IF '394  ' <=DX<= '39490'  |  '424  ' <=DX<= '42400'  |
            '395  ' <=DX<= '39590'  |  '4241 ' <=DX<= '42410'  |
            '396  ' <=DX<= '39690'  |  '397  ' <=DX<= '39710'  |
            '4242 ' <=DX<= '42430'  |  '3979 ' <=DX = '39790'  |
            '4249 ' <=DX<= '42490'  |  '421  ' <=DX<= '42299'
            THEN DO;
                 %FLAGSET(VALVE1,FLAGS{NFLAGS+1},NFLAGS,5);
            END;
      END;

      IF VALVE2=0 THEN DO;
         IF 'V433 ' = DX THEN DO;
            %FLAGSET(VALVE2,FLAGS{NFLAGS+1},NFLAGS,6);
         END;
      END;
*/
     *********** MYOCARDIAL INFARCTION **** WEIGHT = 1 *****************;

      IF ACUTEMI=0 THEN DO;
         IF '410  ' <= DX <= '41099' THEN DO;
                 %FLAGSET(ACUTEMI,FLAGS{NFLAGS+1},NFLAGS,7);
            END;
      END;

      IF OLDMI=0 THEN DO;
         IF '412  ' = DX THEN DO;
                 %FLAGSET(OLDMI,FLAGS{NFLAGS+1},NFLAGS,8);
            END;
      END;

     *********** CHF ***** WEIGHT = 1 *****************************;

      IF CHF=0 THEN DO;
         IF '428  ' <= DX <= '4289 '  |  '4293 ' = DX |
            DX = '40201' | DX = '40211' | DX = '40291' |
            '425  ' <=DX<= '4259 ' THEN DO;
                 %FLAGSET(CHF,FLAGS{NFLAGS+1},NFLAGS,9);
            END;
      END;
     ************ HYPERTENSION ***** NO WEIGHT ********************;
/*
      IF HBP1=0 THEN DO;
         IF '401  ' <=DX<= '4019 ' | '405  ' = DX |
            '4051 ' <=DX<= '40599' THEN DO;
                  %FLAGSET(HBP1,FLAGS{NFLAGS+1},NFLAGS,10);
            END;
      END;

      IF HBP2=0 THEN DO;
         IF '402  ' <= DX <= '40291'|  '403  ' <= DX <= '40390' |
            '404  ' <= DX <= '40490' | '4050 ' <= DX <= '40509'
            THEN DO;
                 %FLAGSET(HBP2,FLAGS{NFLAGS+1},NFLAGS,11);
            END;
      END;
*/
     ************ PERIPHERAL VASCULAR DISEASE ******* WEIGHT = 1 ******;

      IF VASCUL1=0 THEN DO;
         IF '441  ' <=DX<= '4419 '  |
            '442  ' <=DX<= '4429 '  |
            '4431 ' <=DX<= '4439 '  |  '4471 ' = DX |
            '440  ' <=DX<= '4409 '  |
            '7854 ' = DX
            THEN DO;
                 %FLAGSET(VASCUL1,FLAGS{NFLAGS+1},NFLAGS,12);
            END;
      END;

     ********** CEREBROVASCULAR DISEASE ******* WEIGHT = 1 ************;

      IF CVD=0 THEN DO;
         IF '7843 ' = DX | '438  ' = DX  |
            '9970 ' = DX | DX = '36234' |
            '7814 ' = DX |
            '430  ' <=DX<= '436  ' | '437  ' <=DX<= '4371 ' |
            DX = '4379 ' THEN DO;
               %FLAGSET(CVD,FLAGS{NFLAGS+1},NFLAGS,14);
         END;
      END;
     ************ COPD *********************** WEIGHT = 1 **************;

      IF PULMON1=0 THEN DO;
         IF  '491  ' <=DX<= '4949  '|'496  '= DX THEN DO;
                 %FLAGSET(PULMON1,FLAGS{NFLAGS+1},NFLAGS,15);
             END;
      END;

      IF PULMON2=0 THEN DO;
         IF  '4150 ' = DX   | '4168 ' <=DX<= '4169 ' THEN DO;
                 %FLAGSET(PULMON2,FLAGS{NFLAGS+1},NFLAGS,16);
             END;
      END;


     ****** NEURO_OT >> PARKINSONISM,ETC. ********* NO WEIGHT *********;
/*
      IF NEURO_OT=0 THEN DO;
         IF '332  ' <=DX<= '3321 ' | '3334 ' = DX |
            '340  ' = DX           | '3335 ' = DX |
            '345  ' <=DX<= '3459 ' |
            '334  ' <=DX<= '3349 ' | '335  ' <=DX<= '3359 ' |
            '3411 ' <=DX<= '3419 ' | '3481 ' = DX | DX = '3319  ' |
            '3483 ' = DX
            THEN DO;
                 %FLAGSET(NEURO_OT,FLAGS{NFLAGS+1},NFLAGS,17);
            END;
      END;
*/
     *********  DEMENTIA ****** WEIGHT = 1 *****************************;

      IF DEMENTIA=0 THEN DO;
         IF '290  ' <=DX<= '2909 ' | '331  ' <=DX<= '3312 '
            THEN DO;
                 %FLAGSET(DEMENTIA,FLAGS{NFLAGS+1},NFLAGS,18);
            END;
      END;

     ********** PARALYSIS **************** WEIGHT = 2 ******************;

      IF PARALYS=0 THEN DO;
         IF '342  ' <=DX<= '3429 ' | '3440 ' <=DX<= '3449 '
            THEN DO;
                 %FLAGSET(PARALYS,FLAGS{NFLAGS+1},NFLAGS,19);
            END;
      END;

     ********** ENDO OTHER *************** NO WEIGHT *******************;
/*
      IF ENDO_OT=0 THEN DO;
         IF '243  ' <=DX<= '2449 '  |
            '2532 ' = DX           |  '2537 ' <=DX<= '2539 '  |
            '2554 ' <=DX<= '2555 ' |  '242  ' <=DX<= '2429 '  |
            '2450 ' <=DX<= '2459 ' |  '252  ' <=DX<= '2521 ' |
            DX = '2553 ' | DX = '2556 ' | '255  ' <=DX<= '2551 '
            THEN DO;
                 %FLAGSET(ENDO_OT,FLAGS{NFLAGS+1},NFLAGS,20);
            END;
      END;
*/
     ********* DIABETES ************* WEIGHT = 1 ***********************;

      IF DIABET1=0 THEN DO;
         IF '250  ' <=DX<= '2501 ' THEN DO;
                 %FLAGSET(DIABET1,FLAGS{NFLAGS+1},NFLAGS,21);
            END;
      END;

     ********* DKA, ETC ************** WEIGHT =1 ***********************;

      IF DIABET2=0 THEN DO;
         IF '2501 ' <=DX<= '2503 ' THEN DO;
                 %FLAGSET(DIABET2,FLAGS{NFLAGS+1},NFLAGS,22);
            END;
      END;


     ********** DIABETES WITH SEQUELAE ****** WEIGHT = 2 ***************;

      IF DIABET3=0 THEN DO;
         IF '2504 ' <=DX<= '25099' THEN DO;
                 %FLAGSET(DIABET3,FLAGS{NFLAGS+1},NFLAGS,23);
            END;
      END;

     ********** CHRONIC RENAL FAILURE ******* WEIGHT = 2 ***************;

      IF RENAL1=0 THEN DO;
         IF '585  ' <=DX<= '586  ' THEN DO;
                 %FLAGSET(RENAL1,FLAGS{NFLAGS+1},NFLAGS,24);
             END;
      END;


      IF RENAL2=0 THEN DO;
         IF 'V451 ' = DX | 'V420 ' = DX |
            'V56  '<=DX<= 'V569' THEN DO;
               %FLAGSET(RENAL2,FLAGS{NFLAGS+1},NFLAGS,25);
         END;
      END;

     *************** VARIOUS CIRRHODITES ******** WEIGHT = 1 ********;

      IF LIVER1=0 THEN DO;
         IF '5712 ' = DX | '5715 '<=DX<= '5716 '|
            '5718 ' <=DX<= '5719 ' THEN DO;
                 %FLAGSET(LIVER1,FLAGS{NFLAGS+1},NFLAGS,26);
            END;
      END;

     *************** MODERATE-SEVERE LIVER DISEASE *** WEIGHT = 3 ****;

      IF LIVER2=0 THEN DO;
         IF '5722 ' <=DX<= '5724 ' |
            '4560 ' <=DX<= '45629' THEN DO;
               %FLAGSET(LIVER2,FLAGS{NFLAGS+1},NFLAGS,27);
         END;
      END;

     **************** ULCERS ********** WEIGHT = 1 **************;

      IF ULCERS=0 THEN DO;
         IF '531  ' <=DX<= '53499' THEN DO;
                 %FLAGSET(ULCERS,FLAGS{NFLAGS+1},NFLAGS,28);
            END;
      END;

     **************** INFLAMMATORY BOWEL DISEASE ****************;
 /*
      IF INBOWDIS=0 THEN DO;
         IF '555  ' <=DX<= '5556 ' THEN DO;
                 %FLAGSET(INBOWDIS,FLAGS{NFLAGS+1},NFLAGS,29);
            END;
      END;
*/
     **************** VARIOUS CANCERS ********* WEIGHT = 2 ***********;

      IF ('140  ' <=DX<= '14090') & LIPCA=0 THEN DO;
              %FLAGSET(LIPCA,FLAGS{NFLAGS+1},NFLAGS,30);
         END;
      IF ('141  ' <=DX<= '14990') & ORALCA=0 THEN DO;
              %FLAGSET(ORALCA,FLAGS{NFLAGS+1},NFLAGS,31);
         END;
      IF ('150  ' <=DX<= '15090') & ESOPHCA=0 THEN DO;
              %FLAGSET(ESOPHCA,FLAGS{NFLAGS+1},NFLAGS,32);
         END;
      IF ('151  ' <=DX<= '15190') & STOMCHCA=0 THEN DO;
              %FLAGSET(STOMCHCA,FLAGS{NFLAGS+1},NFLAGS,33);
         END;
      IF ('152  ' <=DX<= '15290') & SMLINTCA=0 THEN DO;
              %FLAGSET(SMLINTCA,FLAGS{NFLAGS+1},NFLAGS,34);
         END;
      IF ('153  ' <=DX<= '15480') & COLONCA=0 THEN DO;
              %FLAGSET(COLONCA,FLAGS{NFLAGS+1},NFLAGS,35);
         END;
      IF ('155  ' <=DX<= '15790') & LIVBILCA=0 THEN DO;
              %FLAGSET(LIVBILCA,FLAGS{NFLAGS+1},NFLAGS,36);
         END;
      IF ('158  ' <=DX<= '15990') & OTHDIGCA=0 THEN DO;
              %FLAGSET(OTHDIGCA,FLAGS{NFLAGS+1},NFLAGS,37);
         END;
      IF ('160  ' <=DX<= '16190') & UPAIRCA=0 THEN DO;
              %FLAGSET(UPAIRCA,FLAGS{NFLAGS+1},NFLAGS,38);
         END;
      IF ('162  ' <=DX<= '16390') & LUNGCA=0 THEN DO;
              %FLAGSET(LUNGCA,FLAGS{NFLAGS+1},NFLAGS,39);
         END;
      IF ('164  ' <=DX<= '16590') & OTCHSTCA=0 THEN DO;
              %FLAGSET(OTCHSTCA,FLAGS{NFLAGS+1},NFLAGS,40);
         END;
      IF ('170  ' <=DX<= '17190') & PRMBONCA=0 THEN DO;
              %FLAGSET(PRMBONCA,FLAGS{NFLAGS+1},NFLAGS,41);
         END;

/* commented out 14.1.93
      IF ('172  ' <=DX<= '17290') & MELANOMA=0 THEN DO;
              %FLAGSET(MELANOMA,FLAGS{NFLAGS+1},NFLAGS,42);
         END;
      IF ('173  ' <=DX<= '17390') & SKINCA=0 THEN DO;
              %FLAGSET(SKINCA,FLAGS{NFLAGS+1},NFLAGS,43);
         END;
*/
      IF ('174  ' <=DX<= '17590') & BREASTCA=0 THEN DO;
              %FLAGSET(BREASTCA,FLAGS{NFLAGS+1},NFLAGS,44);
         END;
      IF ('179  ' <=DX<= '18490') & FEMGUCA=0 THEN DO;
              %FLAGSET(FEMGUCA,FLAGS{NFLAGS+1},NFLAGS,45);
         END;
      IF ('185  ' = DX | DX = 'V1046') & PROSTCA=0 THEN DO;
              %FLAGSET(PROSTCA,FLAGS{NFLAGS+1},NFLAGS,46);
         END;
      IF ('186  ' <=DX<= '18790') & MALEGUCA=0 THEN DO;
              %FLAGSET(MALEGUCA,FLAGS{NFLAGS+1},NFLAGS,47);
         END;
      IF ('188  ' <=DX<= '1899 ') & BLDKIDCA=0 THEN DO;
              %FLAGSET(BLDKIDCA,FLAGS{NFLAGS+1},NFLAGS,48);
         END;
      IF ('190  ' <=DX<= '19090') & EYECA=0 THEN DO;
              %FLAGSET(EYECA,FLAGS{NFLAGS+1},NFLAGS,49);
         END;
      IF ('191  ' <=DX<= '19290') & CNSCA=0 THEN DO;
              %FLAGSET(CNSCA,FLAGS{NFLAGS+1},NFLAGS,50);
         END;
      IF ('193  ' <=DX<= '19490') & ENDOCA=0 THEN DO;
              %FLAGSET(ENDOCA,FLAGS{NFLAGS+1},NFLAGS,51);
         END;
      IF ('195  ' <=DX<= '19590') & OTHERCA=0 THEN DO;
              %FLAGSET(OTHERCA,FLAGS{NFLAGS+1},NFLAGS,52);
         END;
/* Used in Deyo comparison, commented out here
*** KAPOSI SARCOMA ADDED 15/12/92 ***************************;
      IF ('176  ' <=DX<= '17690') & KAPOSI=0 THEN DO;
              %FLAGSET(KAPOSI,FLAGS{NFLAGS+1},NFLAGS,53);
         END;
**************************************************************;
*/
/* Flag 54 removed , added in with flag 56

      IF (DX = '2730 ' | DX = '2733 ' | '203  ' <=DX<= '2038 ')
        & PARPRTCA=0 THEN DO;
              %FLAGSET(PARPRTCA,FLAGS{NFLAGS+1},NFLAGS,54);
         END;
*/
      IF ('196  ' <=DX<= '1990') & SECONDCA=0 THEN DO;
              %FLAGSET(SECONDCA,FLAGS{NFLAGS+1},NFLAGS,55);
         END;
      IF ('200  ' <=DX<= '2038 '| DX = '2730 ' |
          DX = '2733 ') & LYMPHOMA=0 THEN DO;
              %FLAGSET(LYMPHOMA,FLAGS{NFLAGS+1},NFLAGS,56);
         END;

/* NOTE: as PARPRTCA has been commented out it cannot=1-it is now
         included in lymphoma  */
      IF (('204  ' <=DX<= '2089 ') | PARPRTCA=1) & LEUKEMIA=0
         THEN DO;
              %FLAGSET(LEUKEMIA,FLAGS{NFLAGS+1},NFLAGS,57);
         END;

      IF (PROSTCA  | BLDKIDCA | LIPCA | ORALCA | ESOPHCA | STOMCHCA |
          SMLINTCA | COLONCA | LIVBILCA | OTHDIGCA | UPAIRCA | LUNGCA |
          OTCHSTCA | PRMBONCA &^ MELANOMA &^ SKINCA | BREASTCA | FEMGUCA |
          MALEGUCA | EYECA | CNSCA | ENDOCA | OTHERCA | KAPOSI)
        & SOLIDCA=0 THEN DO;
              %FLAGSET(SOLIDCA,FLAGS{NFLAGS+1},NFLAGS,58);
         END;

/*  NOTE: PARPRTCA has been combined with LYMPHOMA */
      IF (PARPRTCA | LYMPHOMA | LEUKEMIA | '2386' =DX)
        & LYMPLEUK=0 THEN DO;
              %FLAGSET(LYMPLEUK,FLAGS{NFLAGS+1},NFLAGS,59);
         END;

/* Used in Deyo comparison (added 15.12.92), commented out here

     **************** RHEUMATOLOGIC DISEASE ****** WEIGHT = 1 *******;

      IF RHEUM=0 THEN DO;
         IF '710  ' <=DX<= '7101 ' | '7104 ' =DX |
            '714  ' <=DX<= '7142 ' | '71481' =DX |
            '725  ' =DX THEN DO;
                 %FLAGSET(RHEUM,FLAGS{NFLAGS+1},NFLAGS,60);
            END;
      END;

     **************** AIDS ************WEIGHT = 6 ****************;

      IF AIDS=0 THEN DO;
         IF '042  ' <=DX<= '0449 ' THEN DO;
                 %FLAGSET(AIDS,FLAGS{NFLAGS+1},NFLAGS,61);
            END;
      END;
*/
   END;
   OUTDX:;
                  ******************************************;
                  * END OF DX-CODE LOOP - ADDED MARCH 6/89 *;
                  ******************************************;

   DO OVER SX;
      IF SX=' ' THEN GOTO OUTSX;

/* Next 2 if statements commented out 9/12/92 */

/*      IF ARRHYTH2=0 THEN DO;
         IF '377 ' <=SX<= '3770' | '3773' <=SX<= '3777' |
            '3781' <=SX<= '3789' THEN DO;
                 %FLAGSET(ARRHYTH2,FLAGS{NFLAGS+1},NFLAGS,4);
            END;
      END;

      IF VALVE2=0 THEN  DO;
         IF '351 ' <=SX<= '3528' THEN DO;
            %FLAGSET(VALVE2,FLAGS{NFLAGS+1},NFLAGS,6);
         END;
      END;
*/
      IF VASCUL2=0 THEN DO;
         IF '3813' <=SX<= '3814' | SX = '3816' |
            SX = '3818' | '3843' <=SX <= '3844' |
            SX = '3846' | SX = '3848' | '3833' <=SX<= '3834' |
            SX = '3836' | SX = '3838' |
            '3922' <=SX<= '3926' | SX = '3929'
            THEN DO;
                 %FLAGSET(VASCUL2,FLAGS{NFLAGS+1},NFLAGS,13);
         END;
      END;

      IF CVD=0 THEN DO;
         IF   SX = '3812' | SX = '3842' THEN DO;
            %FLAGSET(CVD,FLAGS{NFLAGS+1},NFLAGS,14);
         END;
    END;

      IF RENAL2=0 THEN DO;
         IF '3927' = SX | '3993' <=SX<= '3995' |
            '3942' = SX | '5498' = SX THEN DO;
            %FLAGSET(RENAL2,FLAGS{NFLAGS+1},NFLAGS,25);
         END;
      END;

      IF LIVER2=0 THEN DO;
         IF SX = '391 ' | SX = '4291' THEN DO;
            %FLAGSET(LIVER2,FLAGS{NFLAGS+1},NFLAGS,27);
         END;
      END;

      IF PROSTCA=0 THEN DO;
         IF SX='605 ' | SX='624 ' | SX='6241' THEN DO;
            %FLAGSET(PROSTCA,FLAGS{NFLAGS+1},NFLAGS,46);
         END;
      END;
   END;
   OUTSX:;

    DIFF = INPUT(IADMDATE,YYMMDD6.) - INPUT(&DATEADM,YYMMDD6.);
    IF NFLAGS>0 THEN DO;
       DO M=1 TO NFLAGS;
          I=FLAGS{M};
          IF COVAR{I} THEN DO;
             IF 0 < DIFF <= 365   THEN  CLP365{I}=1;
             IF DIFF=0            THEN  CLINDX{I}=1;
          END;
       END;
    END;

   IF LAST.&ID THEN DO;

                PCHRLSON =
/* weight =1 */
                (CVP36507 | CVP36508 | CVINDX08) +
                (CVP36509) +
                (CVP36512 | CVINDX12 | CVP36513 | CVINDX13) +
                (CVP36514) +
                (CVP36515 | CVINDX15 | CVP36516 | CVINDX16) +
                (CVP36518 | CVINDX18) +
               ((CVP36521 | CVINDX21 | CVP36522 | CVINDX22)
                          & ^(CVP36523 | CVINDX23)) +
               ((CVP36526 | CVINDX26)
                          & ^(CVP36527 | CVINDX27)) +
                (CVP36528) +
/* Not for Man  (CVP36560 | CVINDX60) +   */     /* RHEUM DISEASE ADDED */
/* weight=2*/
              (((CVP36519) +
                (CVP36524 | CVINDX24 | CVP36525 | CVINDX25) +
                (CVP36523 | CVINDX23) +
/* Pluses & extra brackets added in cancer statement 13.1.93 as
                      per Sally's e-mail */
                ((CVP36554 | CVINDX54 + CVP36556 | CVINDX56 +
                 CVP36557 | CVINDX57 + CVP36558 | CVINDX58)
                          &^ (CVP36555 | CVINDX55)))*2) +
/* weight=3*/
               ((CVP36527 | CVINDX27)*3) +
/* weight=6*/
               ((CVP36555 | CVINDX55)*6);
/* Not for Man  (CVP36561 | CVINDX61))*6); */   /* AIDS ADDED */


*---------------------------------------------------------------*
*   MARCH 6/89 -  CHANGED CODING FOR 'XCHRLSON' SO THAT IT IS   *
*                 BASED ONLY ON 'INDEX' COVARIATES (I.E. ALL    *
*                 'PRIOR' COVARIATES WERE REMOVED, ALSO A FEW   *
*                 INDEX COVARIATES...)                          *
*                                                               *
*   MARCH 5/91 - removed ULCERS from XCHRLSON ....              *
*                                                               *
*---------------------------------------------------------------*;

                XCHRLSON =
/* weight = 1 */
                (CVINDX08) +
                (CVINDX12 | CVINDX13) +
                (CVINDX15 | CVINDX16) +
                (CVINDX18) +
               ((CVINDX21 | CVINDX22)
                          &^ (CVINDX23)) +
                ((CVINDX26) &^ (CVINDX27)) +
/*              (CVINDX60) +      */       /* RHEUM ADDED - not for Manitoba */
/* weight = 2 */
              (((CVINDX24 | CVINDX25) +
                (CVINDX23) +
/* Pluses & extra brackets added in cancer statement 13.1.93 as
                          per Sally's e-mail */
                ((CVINDX54 + CVINDX56 + CVINDX57 + CVINDX58)
                           &^ (CVINDX55)))*2) +
/* weight = 3 */
                ((CVINDX27)*3) +
/* weight = 6 */
                ((CVINDX55)*6);
/* Not for Manitoba  (CVINDX61))*6);  */         /* AIDS ADDED  */


/* Definition of individual components of the comorbidities
   - used to calculate their frequency over the time period
     of interest for TABLE 2.   */

     ACUTEMI = CVP36507 | CVINDX07;
     OLDMI   = CVP36508 | CVINDX08;
     CHF     = CVP36509 | CVINDX09;
     VASCUL1 = CVP36512 | CVINDX12;
     VASCUL2 = CVP36513 | CVINDX13;
     CVD     = CVP36514 | CVINDX14;
     PULMON1 = CVP36515 | CVINDX15;
     PULMON2 = CVP36516 | CVINDX16;
     DEMENTIA= CVP36518 | CVINDX18;
     PARALYS = CVP36519 | CVINDX19;
     DIABET1 = CVP36521 | CVINDX21;
     DIABET2 = CVP36522 | CVINDX22;
     DIABET3 = CVP36523 | CVINDX23;
     RENAL1  = CVP36524 | CVINDX24;
     RENAL2  = CVP36525 | CVINDX25;
     LIVER1  = CVP36526 | CVINDX26;
     LIVER2  = CVP36527 | CVINDX27;
     ULCERS  = CVP36528 | CVINDX28;
     LIPCA   = CVP36530 | CVINDX30;
     ORALCA  = CVP36531 | CVINDX31;
     ESOPHCA = CVP36532 | CVINDX32;
     STOMCHCA= CVP36533 | CVINDX33;
     SMLINTCA= CVP36534 | CVINDX34;
     COLONCA = CVP36535 | CVINDX35;
     LIVBILCA= CVP36536 | CVINDX36;
     OTHDIGCA= CVP36537 | CVINDX37;
     UPAIRCA = CVP36538 | CVINDX38;
     LUNGCA  = CVP36539 | CVINDX39;
     OTCHSTCA= CVP36540 | CVINDX40;
     PRMBONCA= CVP36541 | CVINDX41;
     MELANOMA= CVP36542 | CVINDX42;
     SKINCA  = CVP36543 | CVINDX43;
     BREASTCA= CVP36544 | CVINDX44;
     FEMGUCA = CVP36545 | CVINDX45;
     PROSTCA = CVP36546 | CVINDX46;
     MALEGUCA= CVP36547 | CVINDX47;
     BLDKIDCA= CVP36548 | CVINDX48;
     EYECA   = CVP36549 | CVINDX49;
     CNSCA   = CVP36550 | CVINDX50;
     ENDOCA  = CVP36551 | CVINDX51;
     OTHERCA = CVP36552 | CVINDX52;
     PARPRTCA= CVP36554 | CVINDX54;
     SECONDCA= CVP36555 | CVINDX55;
     LYMPHOMA= CVP36556 | CVINDX56;
     LEUKEMIA= CVP36557 | CVINDX57;
     LYMLEUK = CVP36559 | CVINDX59;

/* Individual components of the comorbidities over
   the time period of interest as defined in XCHRLSON
   - used in TABLE 4   */

     MI      =  CVINDX08;
     PVD     =  (CVINDX12 | CVINDX13);
     PULMON  =  (CVINDX15 | CVINDX16);
     DEMON   =  (CVINDX18);
     MDIAB   =  ((CVINDX21 | CVINDX22) &^ (CVINDX23));
     MLIVER  =  ((CVINDX26) &^ (CVINDX27));
/*   RHEUMA  =  (CVINDX60);     */           /* RHEUM ADDED */
     KIDNEY  =  (CVINDX24 | CVINDX25);
     SDIAB   =  (CVINDX23);
     CANCERS =  ((CVINDX54 + CVINDX56 + CVINDX57 + CVINDX58)
                           &^ (CVINDX55));
     SLIVER  =  (CVINDX27);
     METAS   =  (CVINDX55);
/*     AID     =  (CVINDX61);   */        /* AIDS ADDED  */

/* Individual components of the comorbidities over
   the time period of interest as defined in PCHRLSON
   - used in TABLE 3   */

  MINFARCT =(CVP36507 | CVINDX08 | CVP36508);
  CONGHF =  (CVP36509);
  PVASC =   (CVINDX12 | CVP36512 | CVINDX13 | CVP36513);
  CVASCD =  (CVP36514);
  DEMEN =   (CVINDX18 | CVP36518);
  COPD =    (CVINDX15 | CVP36515 | CVINDX16 | CVP36516);
  ULCER =   (CVP36528);
  LIVER =  ((CVINDX26 | CVP36526) & ^ (CVINDX27 | CVP36527));
  DIABET = ((CVINDX21 | CVP36521 | CVINDX22 | CVINDX22)
                                  & ^ (CVINDX23 | CVP36523));
  PARAL =   (CVP36519);
  RENAL =   (CVINDX24 | CVP36524 | CVINDX25 | CVP36525);
  SEVDIAB = (CVINDX23 | CVP36523);
  CANCER = ((CVINDX54 | CVP36554 + CVINDX56 | CVINDX56 +
               CVINDX57 | CVP36557 + CVINDX58 | CVP36558)
               & ^ (CVINDX55 | CVP36555));
  SEVLIV =  (CVINDX27 | CVP36527);
  METAST =  (CVINDX55 | CVP36555);
/*  CTD    =  (CVP36560 | CVINDX60); */
/*  AID2   =  (CVP36561 | CVINDX61); */


/*  Other variable agregations which have been examined at one
    time or another include:
     PCAD = CVP36501 | CVP36502 | CVP36507 | CVP36508 | CVINDX08;
     XCAD = PCAD | CVINDX01 | CVINDX02;
     PHEARTDX = PCAD | CVP36509 | CVP36505 | CVP36506 | CVINDX05 |
                CVINDX06 | CVP36503 | CVP36504;
     XHEARTDX = XCAD | PHEARTDX;
     PHYPERTN = CVP36510 | CVP36511;
     XHYPERTN = PHYPERTN | CVINDX10 | CVINDX11;
     PCVD = CVP36514;
     XCVD = PCVD | CVINDX14;
     PLUNG = CVP36515 | CVP36516;
     XLUNG = PLUNG | CVINDX15 | CVINDX16;
     BRAIN = CVP36517 | CVINDX17 | CVP36518 | CVINDX18;
     DIABETES = CVP36521 | CVP36522 | CVP36523 | CVINDX21 |
                CVINDX22 | CVINDX23;
     PRENAL = CVP36524 | CVP36525;
     XRENAL = PRENAL | CVINDX24 | CVINDX25;
     ACUTEMI = CVP36507;
     OLDMI   = CVP36508 | CVINDX08;
     CHF     = CVP36509;
     DEMENTIA= CVP36518 | CVINDX18;
     PVD     = CVP36512 | CVINDX12 | CVP36513 | CVINDX13;
     CVD     = CVP36514 | CVINDX14;
     COPD    = CVP36515 | CVINDX15 | CVP36516 | CVINDX16;
     ULCERS  = CVP36528 | CVINDX28;
     LIVER1  = (CVP36526 | CVINDX26) &^ (CVP36527 | CVINDX27);
     DIABETM = (CVP36521 | CVINDX21 | CVP36522 | CVINDX22)
                                     &^ (CVP36523 | CVINDX23);
     PARALYS = CVP36519 | CVINDX19;
     RENAL2  = (CVP36525 | CVINDX25) &^ (CVP36524 | CVINDX24);
     DIABETS = CVP36523 | CVINDX23;
     SOLIDCA = CVP36557 | CVINDX57;
     LEUKEMIA= CVP36556 | CVINDX56 | CVP36553 | CVINDX53;
     LYMPHOMA= CVP36555 | CVINDX55;
     LIVER2  = (CVP36527 | CVINDX27) &^ (CVP36526 | CVINDX26);
     SECONDCA= CVP36554 | CVINDX54;
*/
  OUTPUT;
END;
run;

************ End of Charlson program March 1991 version ***************;

%if &tables = yes %then %do;

  proc freq data=_covar;
  tables xchrlson pchrlson;
  title1 'Table 1: XCHARLSON and PCHRLSON values';
  run;

  proc tabulate data=_covar noseps f=8.0;
  var mi pvd pulmon demon mdiab mliver kidney sdiab cancers sliver metas;
  tables (mi pvd pulmon demon mdiab mliver kidney sdiab cancers sliver metas),
         (n='Index records' sum='N' mean='%'*f=percent8.2) / rts=12;
  title1 'Table 2: Individual components of XCHARLSON';
  run;

  proc tabulate data=_covar noseps f=8.0;
  var minfarct conghf pvasc cvascd demen copd ulcer liver diabet paral renal
      sevdiab cancer sevliv metast;
  tables (minfarct conghf pvasc cvascd demen copd ulcer liver diabet paral renal
      sevdiab cancer sevliv metast),
         (n='Index records' sum='N' mean='%'*f=percent8.2) / rts=12;
  title1 'Table 3: Individual components of PCHARLSON';
  run;
%end;

%* Attach XCHRLSON and PCHRLSON values to original dataset;

proc sort data=_d1;
by &id &dateadm &datesep;
run;

data &out;
merge _covar(in=a keep=&id xchrlson pchrlson) _d1(in=b);
by &id;
if b;
drop i iadmdate;
run;
/*
proc datasets nolist;
delete _d1 _covar;
run;
quit;
*/
%goto exit;

%error1:
options notes;
%put;
%put WARNING: Dataset %upcase(&data) does not exist.;
%put WARNING: The macro did not execute.;
%put;
%goto exit;

%error2:
options notes;
%put;
%put WARNING: Variable %upcase(&id) does not exist.;
%put WARNING: The macro did not execute.;
%put;
%goto exit;

%error3:
options notes;
%put;
%put WARNING: Variable %upcase(&dateadm) does not exist.;
%put WARNING: The macro did not execute.;
%put;
%goto exit;

%error4:
options notes;
%put;
%put WARNING: Variable %upcase(&datesep) does not exist.;
%put WARNING: The macro did not execute.;
%put;
%goto exit;

%error5:
options notes;
%put;
%put WARNING: Variable %upcase(&index) does not exist.;
%put WARNING: The macro did not execute.;
%put;
%goto exit;

%error6:
options notes;
%put;
%put WARNING: Variable %upcase(&dxv1) does not exist.;
%put WARNING: The macro did not execute.;
%put;
%goto exit;

%error7:
options notes;
%put;
%put WARNING: Variable %upcase(&pxv1) does not exist.;
%put WARNING: The macro did not execute.;
%put;
%goto exit;

%error8:
options notes;
%put;
%put WARNING: Variable %upcase(&dxv2) does not exist.;
%put WARNING: The macro did not execute.;
%put;
%goto exit;

%error9:
options notes;
%put;
%put WARNING: Variable %upcase(&pxv2) does not exist.;
%put WARNING: The macro did not execute.;
%put;
%goto exit;

%error10:
options notes;
%put;
%put WARNING: One of DATA, ID, DATEADM, DATESEP, or INDEX is missing.;
%put WARNING: The macro did not execute.;
%put;
%goto exit;

%exit:
options notes;
%mend _charlsn;
