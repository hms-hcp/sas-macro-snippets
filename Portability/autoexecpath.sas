/*-------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA
*--------------------------------------------------------------------------*
File Name   : autoexecpath.sas
Version     : 1.0
Create Date : 26 Mar 2018
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
A method to get the project root path that may be used in all current 
session code.

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
Place the macro code below in the autoexec.sas program and call it using:
%autoexecpath ;
This creates the macro variable &_projpath.
*--------------------------------------------------------------------------*
*/

%macro autoexecpath ;
   %local fullname name_len full_len bat_len ;
   /* Batch Execution */
   %let bat_len = %length(%sysfunc( getoption( sysin ))) ;
   %if &bat_len > 0 %then %do ;
      %let fullname = %sysfunc( getoption( sysin ));
   %end;
   /* Interactive Execution */
   /* The VEXTFL view contains a list of known external files. */
   /* This list includes the autoexec that is currently executing. */
   %else %do ;
      data _null_ ;
         set sashelp.vextfl ;
         if ( substr( fileref, 1, 3) = '_LN' or 
              substr( fileref, 1, 3) = '#LN' or 
              substr( fileref, 1, 3) = 'SYS'    ) and
            index( upcase( xpath ), 'AUTOEXEC.SAS' ) > 0 then do ;
            call symputx( "fullname", xpath ) ;
            stop ;
         end ;
      run;
   %end;

   /* Length of the name + next higher level */
   %let name_len = %length( %qscan( &fullname, -3, %str(\/.)).%qscan( &fullname, -2, %str(\/.)).%qscan( &fullname, -1, %str(\/.))) ;
   /* Length of the whole path - including the name */
   %let full_len = %length( &fullname ) ;
   /* Return the path without the program name */
   %put NOTE: AUTOEXEC.SAS assigned macro variable _PROJPATH ;
   %let _projpath = %qsubstr( &fullname, 1, &full_len - &name_len - 1 ) ;
%mend autoexecpath ;


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
