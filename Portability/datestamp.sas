/*-------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA
*--------------------------------------------------------------------------*
File Name   : datestamp.sas
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
Returns the current date in a the format YYYYMMDD, ideal for date stamp 
on files for backup or creation dates.

REQUIRED MACROS
---------------
NONE

PARAMETERS:
-----------
NONE

EXAMPLE CODE:
-------------
%put %nrstr(%datestamp:) This Report Generated on %datestamp ;
*--------------------------------------------------------------------------*
*/

%macro datestamp ;
   %qtrim( %qleft( %qsysfunc( date(), yymmddn8. )))
%mend datestamp ;



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
