/*-------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA
*--------------------------------------------------------------------------*
File Name   : execprg.sas
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
Returns the current executing program and path information. It detects 
whether the program is being executed in batch or in an interactive session.
All inputs are either environmental variables or system options.

NOTE:  If in interactive mode, the code in the program editor must be saved
to a file.  If it is not, e.g., Untitled*, the macro returns a blank.

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
%put %nrstr(%execprg:) Program path and name is %execprg ;
*--------------------------------------------------------------------------*
*/

%macro execprg ;
   %local bat_len ;
   %* Batch Execution ;
   %let bat_len = %length( %sysfunc( getoption( sysin ))) ;
   %if &bat_len > 0 %then %do ;
      %sysfunc( getoption( sysin ))
   %end;

   %* Interactive Execution ;
   %else %do ;  
      %sysget( SAS_EXECFILEPATH )
   %end;
%mend execprg ;



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
