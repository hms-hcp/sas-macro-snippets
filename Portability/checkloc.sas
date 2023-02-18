/*-------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA
*--------------------------------------------------------------------------*
File Name   : checkloc.sas
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
Checks if a folder exists and creates it if the location does not already 
This macro uses the FILEEXIST function to determine if the desired location
already exists, and if the location does not exist it is created. The DREATE
function takes two arguments. The first argument is the name of the root 
directory, stored in a variable, expression, or string, and the second is 
the name of the new subfolder(s), also stored in a variable, expression 
or string.

Original macro from SAS Global Forum paper 834-2017 by Art Carpenter and 
Mary Rosenbloom, I’ve Got to Hand It to You; Portable Programming Techniques

REQUIRED MACROS
---------------
%slash

PARAMETERS:
-----------
DirLoc:    The path to where the folder should exist.
           default = NONE
DirName:   The name of the folder to check if it exists. 
           default = NONE

EXAMPLE CODE:
-------------
%checkloc( DirLoc=., DirName=data ) ;

*--------------------------------------------------------------------------*
*/

%macro checkloc( DirLoc=, DirName= ) ; 
   %local _s ;      
   %let _s = %slash ;
    
   %* if folder does not exist make it and return path ;   
   %if %sysfunc( fileexist( "&dirloc&_s&dirname" )) = 0 %then %do ; 
      %put Create the folder: "&dirloc&_s&dirname" ; 
      %sysfunc( dcreate( &dirname, &dirloc ))   
   %end ; 
   
   %* If folder exists, return the path ;
   %else %do ; 
      %put The folder "&dirloc&_s&dirname" already exists ; 
      &dirloc&_s&dirname 
   %end; 
%mend checkloc ;



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
*---------------------------------------------------------------------------*
*/
