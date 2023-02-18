/*-------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA
*--------------------------------------------------------------------------*
File Name   : obscnt.sas
Version     : 1.0
Create Date : 27 Mar 2018
Author      : Adapted by Matthew Cioffi
Project Name: Portable programming 
*--------------------------------------------------------------------------*

*--------------------------------------------------------------------------*
| Update Information:
*--------------------------------------------------------------------------*
Modify Date: DD Mmm YYYY         By: 
...Reason...   
*--------------------------------------------------------------------------*

*--------------------------------------------------------------------------*
| Description and Usage:
*--------------------------------------------------------------------------*
Returns the number of observations in a data set.  

Original macro from SAS Global Forum paper 835-2017 by Art Carpenter,
Building Intelligent Macros: Using Metadata Functions with the SAS Macro
Language.

REQUIRED MACROS
---------------
NONE

PARAMETERS:
-----------
dsn:   The name of the data set to get the number of observations from.
       The libname component is optional for temporary sets.

EXAMPLE CODE:
-------------
data test ;
   do i = 1 to 999 ;
       a = ceil( rand( 'NORMAL' ) * 100 ) ;
       if mod ( a, 3 ) = 0 then output ;
   end ;
run ;
%put The number of observations in data set 'test' is %obscnt( test ). ;
*--------------------------------------------------------------------------*
*/

%macro obscnt( dsn );
   %local nobs dsnid rc ;
   %let nobs = . ;
   %* Open the data set of interest ;
   %let dsnid = %sysfunc( open( &dsn )) ;
   
   %* If the OPEN was successful get # of observations and CLOSE ;
   %if &dsnid %then %do ;
      %let nobs = %sysfunc( attrn( &dsnid, nlobs )) ;
      %let rc   = %sysfunc( close( &dsnid )) ;
   %end;
   %else %do;
      %put WARNING: Unable to open &dsn ;
      %put %sysfunc( sysmsg()) ;
   %end;

   %* Return the number of observations;
   &nobs
%mend obscnt;


/*-------------------------------------------------------------------------*
| Disclaimer and Copyright:
*--------------------------------------------------------------------------*
The information contained within this file is provided "AS IS" by the
Department of Health Care Policy, Harvard Medical School, as a service to 
department programmers and researchers. There are no warranties, expressed
or implied, as to the merchantability or fitness for a particular purpose
regarding the accuracy of the materials or programming code contained
herein. This file may be distributed freely in its entirety with references
to related files required by the code.

Copyright (C) 2018 by the President and Fellows of Harvard College
Department of Health Care Policy, Harvard Medical School, Boston, MA, USA
All rights reserved.
*--------------------------------------------------------------------------*/
