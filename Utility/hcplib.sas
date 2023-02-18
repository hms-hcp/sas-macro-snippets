*--------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA   |
|--------------------------------------------------------------------------|
| File Name      = hcplib.sas                                              |
| Path or URL    = /usr/apps/sas/maclib/                                   |
| Version        =                                                         |
| Creation Date  = 21 Oct 2003                                             |
| Author         = Ed Rosen                                                |
| Affiliation    = HCP                                                     |
| Category       = Utility                                                 |
| Keys           =                                                         |
|                                                                          |
|--------------------------------------------------------------------------|
| Brief Description: (1-2 sentences)                                       |
|--------------------------------------------------------------------------|
   Assigns libnames datalib and library to the HCP data and format 
libraries, assigns HCP specific title and sets the log message
level to I.
*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Update Information: Repeat below fields for each update                  |
|--------------------------------------------------------------------------|
| Modified Date  = 11 Dec 2003                                             |
| By Whom        = Matthew J. Cioffi                                       |
| Reason:
   Add common HCP header information and added a footnote, and HCP NOTE:
put statements for start and end of macro.
*--------------------------------------------------------------------------*
| Modified Date  = 10 May 2005                                             |
| By Whom        = Matthew J. Cioffi                                       |
| Reason:
   Change the data library to reference the subfolders as well as the main
folder of the SAS data set libraries.  Due to data set sizes, the location
of the HCP SAS data set library has been moved to Mikao in 
/data/share/sas_datalib.
*--------------------------------------------------------------------------*;
*--------------------------------------------------------------------------*
| Modified Date  = 07 Mar 2006                                             |
| By Whom        = Matthew J. Cioffi                                       |
| Reason:
   Update fmtsearch path to include datalib format catalogs and move the 
   footnote2 statement to the autoid macro.  Make it work on Windows or Unix
*--------------------------------------------------------------------------*
| Modified Date  = 27 Apr 2007                                             |
| By Whom        = Matthew J. Cioffi                                       |
| Reason:
   - Add in brfss folder to datalib libname.
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

   Copyright (C) 2007 by The Department of Health Care Policy, Harvard 
Medical School, Boston, MA, USA. All rights reserved.
*--------------------------------------------------------------------------*;


*--------------------------------------------------------------------------*
| Full Description:                                                        |
|--------------------------------------------------------------------------|
   This macro can be run by itself and is a submacro to the autoid.sas 
used to assign the SASAUTOS paths.  It sets up two library names, datalib,
for the HCP common SAS data sets in /usr/apps/sas/datalib/, and assigns the 
SAS libname LIBRARY, to the common formats in /usr/apps/sas/formatlib/.
It also sets the default heading title to indicate the program is from our
department.  It sets the SAS option msglevel to I, which tells SAS to print 
additional notes pertaining to index usage, merge processing, and sort
utilities along with standard notes, warnings, and error messages. 

   Some of the conditions under which the MSGLEVEL=I system option
applies are as follows: 

   A message displays the IDXWHERE= or IDXNAME= data set option value if 
the setting can affect index processing.

   SAS writes a warning to the SAS log whenever a MERGE statement would 
cause variables to be overwritten.

   SAS writes a message that indicates which sorting product was used.

   SAS writes informative messages to the SAS log about index processing. 
In general, when a WHERE expression is executed for a data set with 
indexes: 

   If an index is used, a message displays that specifies the name of the
   index.

   If an index is not used but one exists that could optimize at least one 
   condition in the WHERE expression, messages provide suggestions that
   describe what you can do to influence SAS to use the index. For example, 
   a message could suggest to sort the data set into index order or to 
   specify more buffers.
   
*--------------------------------------------------------------------------*
| Instructions:                                                            |
|--------------------------------------------------------------------------|
   To use this macro include the command %hcplib in your SAS code.
*--------------------------------------------------------------------------*;


%macro hcplib;
   %put HCP NOTE:  Start Macro hcplib ;
%if &sysscp = WIN %then %do ;
   libname  datalib ( "W:\data\share\sas_datalib\",
                      "W:\data\share\sas_datalib\brfss
                      "W:\data\share\sas_datalib\census1990",
                      "W:\data\share\sas_datalib\census2000",
                      "W:\data\share\sas_datalib\cms",
                      "W:\data\share\sas_datalib\medicare5pct"
                     ) ;
   libname library "W:\data\share\sas_datalib\" ;
%end ;
%else %do ;
   libname  datalib ( "/data/share/sas_datalib/",
                      "/data/share/sas_datalib/brfss
                      "/data/share/sas_datalib/census1990",
                      "/data/share/sas_datalib/census2000",
                      "/data/share/sas_datalib/cms",
                      "/data/share/sas_datalib/medicare5pct"
                     ) ;

   libname library "/data/share/sas_datalib/" ;
%end ;

*--------------------------------------------------------------------------*
| Determine the version of SAS being used and set format search path to    |
| use correct version.                                                     |
*--------------------------------------------------------------------------*;
   %let ver = %substr(&sysver, 1, 1) ;
   %put  "HCP NOTE:  Using SAS Version &ver format catalog in fmtsearch path)" ;
   options 
	fmtsearch=(work library datalib.formats_v&ver datalib)
	msglevel=i 
   ;
   proc options option=fmtsearch ;
   run ;
   title1 'Health Care Policy - Harvard Medical School' ;

   %put HCP NOTE:  End Macro hcplib ;
%mend hcplib;
