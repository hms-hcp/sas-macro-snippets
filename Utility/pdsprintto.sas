/*--------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA   |
|--------------------------------------------------------------------------|
| File Name      = pdsprintto.sas                                          |
| Path or URL    = /usr/apps/sas/maclib/                                   |
| Version        =                                                         |
| Creation Date  = 15 JUN 2016                                             |
| Author         =                                                         |
| Affiliation    = HCP                                                     |
| Category       = Documentation/Debugging                                 |
| Keys           =                                                         |
|                                                                          |
|--------------------------------------------------------------------------|
| Brief Description: (1-2 sentences)                                       |
|--------------------------------------------------------------------------|
   Preparatory macro to help get all the paths and PROC PRINTTO calls 
to create the SAS log file to run the documentation macro %pdsinfo 
within the program in interactive PC SAS 

*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Update Information: Repeat below fields for each update                  |
|--------------------------------------------------------------------------|
| Modified Date  = DD MMM YYYY                                             |
| By Whom        =                                                         |
| Reason:

*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| DISCLAIMER:                                                              |
|--------------------------------------------------------------------------|
   The information contained within this file is provided "AS IS" by the
Department of Health Care Policy (HCP), Harvard Medical School, as a 
service to the HCP Programmers Group and the Department's other users of
SAS.  There are no warranties, expressed or implied, as to the
merchantability or fitness for a particular purpose regarding the accuracy
of the materials or programming code contained herein. This macro may be
distributed freely as long as all comments, headers and related files are
included.

   Copyright (C) 2005 by The Department of Health Care Policy, Harvard 
Medical School, Boston, MA, USA. All rights reserved.
*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Full Description:                                                        |
|--------------------------------------------------------------------------|
  Preparatory macro to help get all the paths and PROC PRINTTO calls 
to create the SAS log file to run the documentation macro %pdsinfo 
within the program in interactive PC SAS 


*--------------------------------------------------------------------------*
| Instructions:                                                            |
|--------------------------------------------------------------------------|
 A typical call for the macro looks as follows: 

IN INTERACTIVE SAS ONLY, PUT THE FOLLOWING CODE AT THE TOP OF THE PROGRAM:

%let macropath = W:\DATA\Mass-DAC\Programmers_data\macros\;
%pdsprintto;

THEN, AT THE BOTTOM OF THE DOCUMENT, YOU CAN CALL THE %PDSINFO MACRO AS FOLLOWS:

%preppdsinfo;
%pdsinfo(lpath=&lpath, lfilename=lfile, outpath=, inprogram=1,tsets=1,dsinfo=1,exclpdsinfo=1);

proc printto print = print log = log;
run;

IF YOU ARE RUNNING ON UNIX IN BATCH MODE, YOU DON'T NEED THE %PDSPRINTTO MACRO - 
RUNNING %PREPPDSINFO BEFORE CALLING %PDSINFO IS ENOUGH


*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Macro Code Begins Here.                                                  |
*--------------------------------------------------------------------------*; */


%macro pdsprintto;


%global FullName FNameStart ProgramPath PNameNoPath macropath lpath;

/* Find PathName of folder containing program */

%let FullName=%sysfunc(GetOption(SYSIN));
%if %length(&FullName)=0
   %then %let FullName=%sysget(SAS_EXECFILEPATH);
%put FullName: &FullName.;
%let FullLen=%length(&FullName);
%put FullLen: &FullLen.;


%let PNameNoPath = %scan(&FullName,-1,"\/");
%let NoPathLen = %length(&PNameNoPath);
%let ProgramPath = %substr(&FullName,1,&FullLen.-&NoPathLen.);

%put PNameNoPath = &PNameNoPath;
%put NoPathLen: &NoPathLen.;
%put ProgramPath: &ProgramPath.;


%let FNameStart=%substr(&FullName,1,&FullLen.-4);
%put FNameStart = &FNameStart;

/* define path for the log */

%let lpath = &FNameStart..log;
%put lpath=&lpath;

 proc printto print = "&FNameStart..lst" log = "&lpath" new; 
 run;

%mend;
