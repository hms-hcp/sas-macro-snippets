/*-------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA
*--------------------------------------------------------------------------*
File Name   : execroot.sas
Version     : 1.0
Create Date : 22 Mar 2018
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
Returns the current program name without the extension from the current
executing program path information. It detects whether the program is being
executed in batch or in an interactive session using the same technique as
the execprg macro. The QSCAN function is used to extract the second to last
word from the path as the file name. All inputs are environmental variables 
or system options.

NOTE:  If in interactive mode, the code in the program editor must be saved
to a file.  If it is not, e.g., Untitled*, the macro returns a blank.

NOTE: The return value formula uses a negative word number to read string 
from right to left. This may need to be modified if single word file names
are used or if the path separators are other than slashes and dots.

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
%put %nrstr(%execroot:) Program name is %execroot ;
*--------------------------------------------------------------------------*
*/

%macro execroot ; 
   %local fullname bat_len ; 
   %* Batch Execution ;
   %let bat_len = %length(%sysfunc( getoption( sysin ))) ;
   %if &bat_len > 0 %then %do ;
      %let fullname = %sysfunc( getoption( sysin )) ; 
   %end; 

   %* Interactive Execution ;
   %else %do ; 
      %let fullname = %sysget( SAS_EXECFILEPATH ) ; 
   %end; 

   %* Return the program name only, see notes in description to modify ;
   %qscan(&fullname, -2, %str(\/.)) 
%mend execroot ;


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
