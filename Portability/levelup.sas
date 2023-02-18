/*-------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA
*--------------------------------------------------------------------------*
File Name  : levelup.sas
Version    : 1.0
Create Date: 27 Mar 2018
Author     : Adapted by Matthew Cioffi
Project    : Portable programming 
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
This macro accepts a path and a displacement and returns a path with the
lower levels removed. We can use the %execpath macro to get the location of
the executing program and then use %levelup to determine the next higher
level. All inputs are environmental variables or system options.

Original macro from SAS Global Forum paper 834-2017 by Art Carpenter and 
Mary Rosenbloom, I’ve Got to Hand It to You; Portable Programming Techniques

REQUIRED MACROS
---------------
NONE

PARAMETERS:
-----------
NONE

EXAMPLE CODE:
-------------
## Hard-coded example ##
%let mypath = c:\project\programs ;
%put %nrstr(%levelup:) One level up from &mypath is %levelup(uppath=&mypath, up=1) ;

## The following requires the macros checkloc, slash, and execpath to work ##
libname mydata "%checkloc( dirloc=%levelup( uppath=%execpath, up=1 ), dirname=dataplots )" ; 
%put New Data Folder: %qsysfunc( pathname( mydata )) ;
*--------------------------------------------------------------------------*
*/

%macro levelUp( uppath=, up=1 ) ;
   %local up_len full_len lev ;
   %if &up gt 0 %then %do ;
      %let up_len = 0 ;

      %* Add the length of this level to total length to be eliminated ;
      %do lev = 1 %to &up ;
         %let up_len = %eval( &up_len + %length( %qscan( &uppath, -&lev, %str(\/.)))) ;
      %end;
   
      %* Return the path without the lower &up levels ;
      %* Each eliminated level has a delimiter to remove as well ;
      %qsubstr( &uppath, 1, %length( &uppath ) - &up_len - &up )
   %end;
   %else %do ;
      %* No change requested return the incoming path ;
      &uppath
   %end ;
%mend levelup;



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
