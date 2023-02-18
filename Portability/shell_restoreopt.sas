/*-------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA
*--------------------------------------------------------------------------*
File Name   : shell_restoreopt.sas
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
Often times macros modify or change the settings of system options during
execution. Since we anticipate that our programs will be passed around, we
can’t be sure of the system options settings that they will encounter. After
execution it is always wise to reset these options to the setting that they
enjoyed prior to the execution of your macro. This is easily accomplished by
grabbing and saving the initial setting, and then restoring it afterwards. 
The easiest way to do this is through the use of the GETOPTION function. 
In the macro %shell_restoreopt example it saves then restores the DATE and
LINESIZE system options.

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
%shell_restoreopt ;
*--------------------------------------------------------------------------*
*/

%macro shell_restoreopt ;
   %* Prepare to change DATE and LS system options ;
   %let old_date = %qsysfunc( getoption( date )) ;
   %* When KEYWORD is used, it includes the name of the option with its value ;
   %let old_ls   = %qsysfunc( getoption( ls , keyword )) ;
   %put &=old_date ;
   %put &=old_ls ;
   
   %* your macro code here ;
   options nodate ls = 85 ;
   %* your macro code here ;
   
   %* reset options to original values ;
   options &old_date &old_ls ;
%mend shell_restoreopt ;


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
