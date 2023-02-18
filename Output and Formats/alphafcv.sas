*--------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA   |
|--------------------------------------------------------------------------|
| File Name      = alphafcv.sas                                            |
| Path or URL    =                                                         |
| Version        = 1.3                                                     |
| Creation Date  = 06 Jun 1999                                             |
| Author         =                                                         |
| Affiliation    =                                                         |
| Category       = Data                                                    |
| Keys           =                                                         |
|                                                                          |
|--------------------------------------------------------------------------|
| Brief Description: (1-2 sentences)                                       |
|--------------------------------------------------------------------------|
   Performs field-content analysis on all character fields in a SAS data 
object, data sets and views. 
*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Update Information: Repeat below fields for each update                  |
|--------------------------------------------------------------------------|
| Modified Date  = 02 Jul 1999                                             |
| By Whom        =                                                         |
| Reason:
   Accept HTML File Name
*--------------------------------------------------------------------------*
| Modified Date  = 03 Jul 1999                                             |
| By Whom        =                                                         |
| Reason:
   Accept Table Name
*--------------------------------------------------------------------------*
| Modified Date  = 11 Dec 2003                                             |
| By Whom        = Matthew J. Cioffi                                       |
| Reason:
   Added standard HCP macro header and added HCP NOTE: put statements for
start and end of macro.
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

   Copyright (C) 2003 by The Department of Health Care Policy, Harvard 
Medical School, Boston, MA, USA. All rights reserved.
*--------------------------------------------------------------------------*;


*--------------------------------------------------------------------------*
| Full Description:                                                        |
|--------------------------------------------------------------------------|
   Performs field-content analysis on all character fields in a SAS data 
object. Works on data sets and views.  For HTML, assumes HTML macro symbol
exits which points to a directory.  This version of the macro, as received
appears to be version 1.3 and has three edit histories noted:
   001 Original
   002 Accept HTML file name
   003 Accept Table Name

*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Instructions:                                                            |
|--------------------------------------------------------------------------|
   Takes four parameters
     LIB - name of SAS libname
     MEM - name of member
     TOP - number of values to display
           ( default = 50 )
     O   - if HTML, will call %OUT2HTM to
           generate HTML output.
           This won't work if %OUT2HTM is
           not available.
           ( default = LST )

   For HTML, assumes HTML macro symbol
   exists which points to a directory.
*--------------------------------------------------------------------------*;

%macro AlphaFCV(LIB=,MEM=,TOP=50,O=LST,HTML=,TNAM=X);

   %put HCP NOTE:  Start Macro AlphaFCV v1.3;

   %local _N i DENOM;

   %let LIB = %upcase( &LIB );
   %let MEM = %upcase( &MEM );

   %if &TNAM = X %then %do;
      %let TNAM = &LIB..&MEM;
   %end;

   proc sql;
     create view alpha as
     select name, label
     from dictionary.columns
     where type = 'char' &
        libname = "&LIB." &
        memname = "&MEM";

   data _null_;
     set alpha end = lastrec;
     call symput( '_V' || left( _n_ ), name );
     if label ^= "" then
        call symput( '_L' || left( _n_ ), trim( name ) || '[' || label || ']' );
     else call symput( '_L' || left( _n_ ), name );
     if lastrec then call symput( '_N', left( _n_ ) );
   run;

   proc sql;
     reset noprint;

     select count( * ) into :DENOM
     from &LIB..&MEM.;

   %do i = 1 %to &_N;
     create view &&_V&i as
     select &&_V&i as value, count( * ) as rows
     from &LIB..&MEM
     group by &&_V&i
     order by rows desc, value;
   %end;

   options nobyline;

   %if &O = HTML %then %do;
     options linesize = 100 pagesize = 47;
     %Out2HTM( capture=on, runmode = b, window = output );
   %end;

   %do i = 1 %to &_N;
     data peek;
       set &&_V&i end = lastrec;
       pct = rows / &DENOM.;
       if _n_ > &TOP then do;
         call symput( 'PRETTY', put( &DENOM, comma12. ) );
         stop;
       end;
       if lastrec then call symput( 'PRETTY', put( &DENOM, comma12. ) );
     run;

     proc report data = peek missing;
       columns value rows pct;
       define value / format=$40. 'Field Contents/==';
       define rows / format=comma12. 'Occurs/==';
       define pct / format=percent8.1 'Pct/==';
       title2 "Table Under Analysis:  &TNAM.    &PRETTY Total rows";
       title3 "Field Under Analysis: &&_L&i";
     run;
   %end;

   %if &O = HTML %then %do;

      %Out2HTM(capture=off,
         htmlfile = &HTML,
         brtitle = PharMetrics Character Field Content Analysis,
         proploc = library.htmlgen.outprop.slist )
   %end;

   %put HCP NOTE:  End Macro AlphaFCV v1.3;
%mend AlphaFCV;

