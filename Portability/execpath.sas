/*-------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA
*--------------------------------------------------------------------------*
File Name  : execpath.sas
Version    : 1.0
Create Date: 27 Mar 2018
Author     : Adapted by Matthew Cioffi
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
Returns the current program path from the current executing program path 
information. It detects whether the program is being executed in batch or
in an interactive session using the same technique as the execprg macro.
The QSCAN function is used to extract the last two words from the path as
the file name. All inputs are environmental variables or system options.

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
%put %nrstr(%execpath:) Program path is %execpath ;
*--------------------------------------------------------------------------*
*/

%macro execpath ; 
   %local fullname name_len full_len bat_len ;
   %* Batch Execution ;
   %let bat_len = %length( %sysfunc( getoption( sysin ))) ;
   %if &bat_len > 0 %then %do ;
      %let fullname = %sysfunc( getoption( sysin )) ;
   %end;

   %* Interactive Execution ;
   %else %do;
      %let fullname = %sysget( SAS_EXECFILEPATH ) ;
   %end;

   %* Length of the name only ;
   %let name_len = %length( %qscan( &fullname, -2, %str(\/.)).%qscan( &fullname, -1, %str(\/.))) ;
   %* Length of the whole path - including the name ;
   %let full_len = %length( &fullname ) ;

   %* Return the path name only, see notes in description to modify ;
   %qsubstr( &fullname, 1, &full_len - &name_len - 1 )
%mend execpath;



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
