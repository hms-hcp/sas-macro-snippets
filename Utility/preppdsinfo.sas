/*--------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA   |
|--------------------------------------------------------------------------|
| File Name      = preppdsinfo.sas                                          |
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
   Preparatory macro to get the path of the log to run the documentation 
macro %pdsinfo within a SAS program.

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
  Preparatory macro to get the path of the log to run the documentation 
macro %pdsinfo within a SAS program. Needs to be run in both batch mode and 
interactive SAS, but interactive SAS also requires the %printto macro to be 
run as well


*--------------------------------------------------------------------------*
| Instructions:                                                            |
|--------------------------------------------------------------------------|
 A typical call for the macro wthin a program run on unix in batch mode 
looks as follows: 

At the bottom of the program, put:

options nosource nonotes nomprint;

%preppdsinfo;
%pdsinfo(lpath=&lpath,lfilename = lfile, outpath=&docpath,
printcomments=0,
inprogram=1,dsinfo=1,exclpdsinfo=1);  

options notes source mprint;


NOTE: For interactive SAS, you also need to call the %pdsprintto macro at the 
top of the program. (See the %pdsprintto documentation for more details)



*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Macro Code Begins Here.                                                  |
*--------------------------------------------------------------------------*; */



%macro preppdsinfo;
/* get all the paths and program names to run %pdsinfo within program */

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


 %if &SYSSCP ne WIN %then %do;

/* create filename for the current log file */

 %let lfileq = %str(%'cat %"&lpath.%"%');
  filename lfile pipe %unquote(&lfileq.);

%end;

%else %if  &SYSSCP = WIN %then %do;
 
 %let lfileq = %str(%'type %"&lpath.%"%');
  filename lfile pipe %unquote(&lfileq.);
%end;


%mend;
