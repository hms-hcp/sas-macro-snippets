/*-------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA
*--------------------------------------------------------------------------*
File Name   : filelist.sas
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
This macro writes the names of all the files in a directory to the SAS Log.
To access the names of the files in a directory you need to open and close 
the directory using the DOPEN and DCLOSE functions. Once the directory is
opened, you can use the DREAD and DNUM functions to step through the files. 

Original macro from SAS Global Forum paper 835-2017 by Art Carpenter,
Building Intelligent Macros: Using Metadata Functions with the SAS Macro
Language.

REQUIRED MACROS
---------------
NONE

PARAMETERS:
-----------
fileref:   The SAS fileref name pointing to a folder or directory.

EXAMPLE CODE:
-------------
filename afldr 'W:\DATA\share\sas_datalib' ;
%filelist( fileref = afldr ) ;
filename afldr ;
*--------------------------------------------------------------------------*
*/

%macro filelist(  fileref= ) ;
   %local dinfo dname fid fname i ;
   %* Open the directory ;
   %let fid = %sysfunc( dopen( &fileref )) ;
   %* If it exists, cycle through the file names, printing each ;
   %put START FILELIST:: ;
   %put -------------------------- ;
   %if &fid %then %do ;
      %let dname = %sysfunc( doptname( &fid, 1 )) ;
      %let dinfo = %sysfunc( dinfo( &fid, &dname )) ;
      %put &dinfo ;
      %do i= 1 %to %sysfunc( dnum( &fid )) ;
         %let fname = %sysfunc( dread( &fid, &i )) ;
         %put &i.. &fname ;
      %end ;
   %end ;
   %put -------------------------- ;
   %put END FILELIST:: ;
   %put  ;
   %let fid = %sysfunc( dclose( &fid )) ;
%mend filelist ;


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
