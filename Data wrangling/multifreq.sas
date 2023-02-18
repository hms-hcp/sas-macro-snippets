*--------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA   |
|--------------------------------------------------------------------------|
| File Name      = multifreq.sas                                           |
| Path or URL    = /usr/apps/sas/maclib/                                   |
| Version        =                                                         |
| Creation Date  = 13 Jan 2009                                             |
| Author         = Stephanie Segers                                        |
| Affiliation    = HCP                                                     |
| Category       = Utility                                                 |
| Keys           = libref (library where source set is)                    |
|                  dsn (dataset name)                                      |
|                  indvar (covariate in model)                             |
|                  crossvar (dependent variable)                           |
|                  indset (temporary set output by proc)                   |
|                  mnum (measure number - for tracking multiple runs of    |
|                   macro on different sets - not necessary for one run)   |                                                    |
|                                                                          |
|--------------------------------------------------------------------------|
| Brief Description: This macro uses ODS and the output set from proc freq |
| to extract selected information from proc freq output for multiple cross-|
| tabs and arrange it in a table to be sent to an .RTF file for pasting    |
| into an Excel or Word document.  Using it allows easy updates when cohort|
| changes or variables of interest in the table change.                    |
|--------------------------------------------------------------------------|
   Template for Macro Header.

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

* %multifreq                                                                           *                                                                                      
* Unadjusted cross-freq macros                                                         *
* developer Stephanie Segers                                                           *
* date: January 13, 2009                                                               *
*                                                                                      *
* information needed to call macro:                                                    *
* libref = library where source set is                                                 *
* dsn = dataset name                                                                   *
* indvar = covariate in model                                                          *
* crossvar = dependent variable                                                        *
* indset = temporary set output by proc                                                *
* mnum = measure number (numeric) - this is for tracking; not essential to run macro   *
*                                                                              example call: 
set parameters that don't vary as much 

running meas 11 

%let lib = me;
%let set = meas11_wexcl; 
%let measvar = curative_surg;
%let measnum = 11;
%let date = Feb5;

%multifreq(&lib,&set,age_grp,&measvar,ageset,&measnum)
%multifreq(&lib,&set,fin_sex,&measvar,sexset,&measnum)
%multifreq(&lib,&set,fin_race,&measvar,raceset,&measnum)
%multifreq(&lib,&set,marvnot,&measvar,marset,&measnum)
|--------------------------------------------------------------------------|
   
*--------------------------------------------------------------------------*
| Instructions:                                                            |
|--------------------------------------------------------------------------|

*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Macro Code Begins Here.                                                  |
*--------------------------------------------------------------------------*;/*

%macro multifreq(libref,dsn,indvar,crossvar,indset,mnum);

ODS output CrossTabFreqs = freqset;
ODS output ChiSq = testset;

proc freq data=&libref..&dsn;
  tables &indvar*&crossvar / chisq out=&indset outpct;
  title1 "unadjusted freqs for covariates for Measure &mnum (&crossvar)";
run;

data keepfreq;
  set freqset (keep = &indvar _TYPE_ Frequency Percent Table);
    where _TYPE_ = '10';
run;

data &indset;
   set &indset (keep = &indvar &crossvar PCT_ROW);
     where &crossvar = 1;
    length varname $16 value $5;
    measnum=&mnum;
    varname="&indvar";
    %if &indvar = grade_new %then %do;
    value=&indvar;
    %end;
    %else %do;
    value=compress(put(&indvar, 8.));
    %end;
run;

data keeptest;
   set testset (keep = Prob Statistic Table);
     where Statistic = 'Chi-Square';
run;

proc sort data=keepfreq;
  by &indvar;
run;

proc sort data=&indset;
  by &indvar;
run;

data both;
  merge keepfreq &indset;
    by &indvar;
run;
 
data all_info_&indset;
  merge both keeptest;
    by Table;
  if varname = lag(varname) and lag(Prob) ne . then Prob = .;
  drop &indvar; 

  label Frequency = 'N'
        Percent = '%'
        PCT_ROW = "% received &crossvar"
        Prob = 'P-Value';
run;

proc print data=all_info_&indset label;
  var varname value Frequency Percent PCT_ROW Prob;  
  title1 "all unadjusted info for &indvar";
run;

/** stack up the sets to make one table of multiple covariates **/

  proc append base=info data=all_info_&indset force;
    run;

ODS listing;
ODS RTF file = "/H-drive_file_directory_for_project/Meas&mnum._unadj_xfreqs_all_covars_&date..rtf";

proc print data=info label noobs;
  var varname value Frequency Percent PCT_ROW Prob;  
  title1 "all unadjusted info for &crossvar for Measure &mnum";
run;
  
ODS RTF close;
ODS listing close;

%mend multifreq;


