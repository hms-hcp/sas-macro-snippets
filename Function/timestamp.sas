*--------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA   |
|--------------------------------------------------------------------------|
| File Name      = timestamp.sas                                           |
| Path or URL    = /usr/apps/sas/maclib/                                   |
| Version        = 1.0                                                     |
| Creation Date  = 28 May 1998                                             |
| Author         = Matthew J. Cioffi                                       |
| Affiliation    = HCP                                                     |
| Category       = Utility                                                 |
| Keys           = log now time stamp date                                 |
|                                                                          |
|--------------------------------------------------------------------------|
| Brief Description: (1-2 sentences)                                       |
|--------------------------------------------------------------------------|
   Assigns a global variable, _now, the current system date and time in
a text format and places a date and time stamp line into the current log,
prefixed with default, HCP DATE-TIME:, or user defined text.
*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Update Information: Repeat below fields for each update                  |
|--------------------------------------------------------------------------|
| Modified Date  = 15 Dec 2003                                             |
| By Whom        = Matthew Cioffi                                          |
| Reason:
   Added the standard macro heading and changed the default text.
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
   This macro uses the system functions date() and time() to get the 
current time and converts them to a text string with the day of the week,
followed by the day, the full text month, the four digit year and then the 
time.  When %timestamp is called, it creates a global variable, &_now, 
which can be used anywhere in the SAS program, once the first time stamp 
is written to the log.  The time stamp will be prefixed with HCP DATE-TIME:
by default, but can be defined or removed by the user, followed by 
the date and time.

*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Instructions:                                                            |
|--------------------------------------------------------------------------|
   To call this macro with default settings, do not use any parameters,
%timestamp.  If you want to add your own text, set the logtext parameter
in the call, %timestamp (logtext = Begin Execution of Data Step). If you
want to have no text prefix on the date and time, set the logtext parameter
to blank, %timestamp (logtext=  ).

   The macro has only one parameter and one global variable it sets.
   
   Parameters: 
      logtext = This is the is set to  'HCP DATE-TIME:' by default, but
                the user can put in what ever text they want or leave it
                blank to get just the date and time.

   Global Variables:
      _now = This will be a text string up to 42 characters long consisting 
             of the day of the week, day, month, year, and time.

*--------------------------------------------------------------------------*;

/*-------------------------------------------------------------------------*
| Examples:                                                                |
|--------------------------------------------------------------------------|

%timestamp (logtext = Begin first data step at ) ;
data test ;
   a = 'HCP' ;
   do i = 1 to 10000 ;
      output ;
   end ;
run ;

%timestamp (logtext = ) ;
proc means ;
run ;

%timestamp ;
proc freq ;
   table a ;
run ;
%timestamp (logtext = Program Ending at ) ;
*--------------------------------------------------------------------------*/

%macro timestamp (logtext= HCP DATE-TIME: ) ;
   %global _now  ;
   %local  
      date_a
      time_a
   ;

   %let date_a = %trim ( %left ( %sysfunc (date(), worddatx32. ))) ;
   %let time_a = %trim ( %left ( %sysfunc (time(), time9. ))) ;
   %let _now   = &date_a at &time_a ;
   %put *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~* ;
   %put &logtext &_now ;
   %put *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~* ;
%mend timestamp ;
