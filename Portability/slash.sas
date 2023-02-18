/*-------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA
*--------------------------------------------------------------------------*
File Name   : slash.sas
Version     : 1.0
Create Date : 22 Mar 2018
Author      : Matthew Cioffi
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
Returns the proper slash character for the operating system.  
If Windows, return a backslash [\], otherwise return a common slash [/].

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
%put %nrstr(%slash:) Slash for OS | %slash | ;
%put %nrstr(%slash w/ catt:) %sysfunc( catt( W:, %slash, data, %slash, test.sas)) ;
%put %nrstr(%slash w/ tranwrd:) %sysfunc( tranwrd( W:/some/long/path/name, /, %slash )) ;
*--------------------------------------------------------------------------*
*/

%macro slash ;     /* Selects the correct slash symbol based on OS */
   %qsysfunc(ifc( &sysscp = WIN, \, / ))  
%mend slash ;



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
