/*--------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA   |
|--------------------------------------------------------------------------|
| File Name      = pdsinfo.sas                                             |
| Path or URL    = /usr/apps/sas/maclib/                                   |
| Version        =   1                                                     |
| Creation Date  = 05 JUN 2016                                             |
| Author         = KATYA ZELEVINSKY                                        |
| Affiliation    = HCP                                                     |
| Category       = Utility                                                 |
| Keys           =                                                         |
|                                                                          |
|--------------------------------------------------------------------------|
| Brief Description: (1-2 sentences)                                       |
|--------------------------------------------------------------------------|

Runs the %GETDSNAMES program to get a list of  datasets and libnames
created within the program we are interested in and and if possible 
provides some other useful information about that program.

*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Update Information: Repeat below fields for each update                  |
|--------------------------------------------------------------------------|
| Modified Date  = 15 JUN 2016                                             |
| By Whom        = KATYA ZELEVINSKY                                        |
| Reason: Change the macro to work with the log instead of macro code

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
   
This macro is designed to run within a program being run, to provide real time 
information about that program, and the datasets created in it. However, if you
already have a file with the log from the program you are interested in, 
you can run the macro setting 
inprogram=0,dsinfo=0 (Or simply not changing those values, 
since those are the default values for those variables for the macro)
during the macro call to get only the information from the log, and no information 
from the local files created while the program is running. 



The macro uses the %READIN_LOG and %GETDSNAMES macros, to create a list of 
libnames and datasets referred to in the following places in the log:

Input datasets:

the set or merge statements of the data step
the data= option of procedures
the from clause of proc sql
the notes printed to the log after a dataset is used

Output datasets:

the data statement of the data step
the create table clause of proc sql
the out= option of procedures
ods output
the notes printed to the log after a dataset is defined


If the macro is being run within a program with the options mprint mfile option 
turned on, then the macro will get summary information about these libnames 
and libnames from the SASHELP views created by the program being run, and 
create a text file summary with the directories of the libnames and the list 
of datasets, and a pdf file with the number of variables and observations for 
each of the datasets created in this program.

If the macro is run outside any other program using an already defined log,
the macro will return a text file with the name of the program, and a list of 
libnames and datasets used, and, if prompted, the last information 
about the number of observations and variables found in 
the log for each of those datasets. 


pdsinfo(lpath,lfilename=,sumoutfile=,outpath=,tsets=1,printcomments=0,
inprogram=0,dsinfo=0,exclpdsinfo=1);

PARAMETERS:

LPATH - path and name for the log you want to read in (NO DEFAULT - needs to be defined)

LFILENAME - if run within program, the filename defined with the pipe for that 
program's log (default: blank)

SUMOUTFILE- the path and name of the summary text file created by 
this program. 
If this is left blank, then this name will be as follows: 
	-If the macro is being run withing the program:
	[name of program macro is run in]_summary.txt or
	-If the macro is being run outside the program using a file 
	with the code:
	[name of log file without extension]_summary.txt 

OUTPATH - if you want to output the summary file into a separate documentation folder,
		  set the path for that here; leave blank if you want to leave the 
		  summary files in the same directory as the log/program you want to check (default=blank)

TSETS = 1 if you want to show output about temporary datasets
	    0 if you want to suppress output about temporary datasets
	    (default = 1)

INPROGRAM = 1 if run within a program
		    0 if NOT run within a program
		    (default = 0)

PRINTCOMMENTS = 1 if you want to print in the summary text file the comments you marked with [slash]* !!!!! in your code 
				0 otherwise
				(default = 0)

DSINFO =
		1 if you want to see a separate pdf file with the number of observations 
		and variables for the datasets 
		0 if you want to suppress this separate pdf file
		(default=0)
		The name of the summary pdf file would be &SUMOUTFILE._dsinfo.pdf
		if tsets=1 then a similar table about the temporary files will be 
		included on the next page

		If INPROGRAM = 0 and DSINFO = 1 then this information comes from wahtever latest 
		information about the dataset can be found in the log file
 
EXCLPDSINFO = 1 if you want to exclude the files created by %PDSINFO from your summary list of 
				libnames and datasets
			  0 otherwise (default = 0)



*--------------------------------------------------------------------------*
| Instructions:                                                            |
|--------------------------------------------------------------------------|

A typical call of the macro WITHIN THE PROGRAM YOU ARE INTERESTED IN:


options nosource nonotes nomprint;

%preppdsinfo;
%pdsinfo(lpath=&lpath,lfilename = lfile, outpath=/path/to/doc/folder/,
printcomments=0,
inprogram=1,dsinfo=1,exclpdsinfo=1);  

options notes source mprint;

(NOTE: these lines need to be to be included AT THE VERY END 
OF THE PROGRAM you are interested in. )


A typical call of the macro OUTSIDE of the program you are interested in:

%let testlog = /path/to/log/name_of_program.log;

%pdsinfo(&testlog,
         lfilename=,sumoutfile=,
         outpath=&docpath,tsets=1,
         printcomments=0,inprogram=0,
         dsinfo=1,exclpdsinfo=1);

*--------------------------------------------------------------------------*;*/

*--------------------------------------------------------------------------*
| Macro Code Begins Here.                                                  |
*--------------------------------------------------------------------------*;




%macro pdsinfo(lpath,lfilename=,sumoutfile=,outpath=,tsets=1,printcomments=0,
inprogram=0,dsinfo=0,exclpdsinfo=1);

%let programname=;

%if &inprogram. gt 0 %then %do;
	%let programname=%sysfunc(GetOption(SYSIN));
	%if %length(&programname)=0
   		%then %let programname=%sysget(SAS_EXECFILEPATH);
	%if %length(&sumoutfile.) eq 0 %then %do;
		%if %sysfunc(countc(&programname,".")) eq 1 %then %do;
			%let sumoutfile = %scan(&programname,1,".")_summary.txt;
		%end;
		%else %if %sysfunc(countc(&programname,".")) ne 1 %then %do;
			%let sumoutfile = %substr(&programname,1,%length(&programname.)-4)_summary.txt;
		%end;
	%end;
%end;

%if %length(&programname) = 0 and %length(&lpath) gt 0 %then %do;
	%let programname = &lpath;
%end;

%if %length(&sumoutfile.) eq 0 %then %do;
		%if %sysfunc(countc(&programname,".")) eq 1 %then %do;
			%let sumoutfile = %scan(&programname,1,".")_summary.txt;
		%end;
		%else %if %sysfunc(countc(&programname,".")) ne 1 %then %do;
			%let sumoutfile = %substr(&programname,1,%length(&programname.)-4)_summary.txt;
		%end;
%end;

%let sumoutname = %scan(&sumoutfile.,-1,"/\");

%put sumoutname = &sumoutname;


%if %length(&outpath) gt 0 and %length(&sumoutname) gt 0 %then %do;
		%let sumoutfile = &outpath.&sumoutname.;
%end; 


%put programname=&programname;
%put lpath = &lpath;
%put sumoutfile=&sumoutfile;


%getdsnames(logpath=&lpath,logfilename=&lfilename,indsname=indata,outdsname=outdata,suffix=_log,
exclpdsinfo=&exclpdsinfo.);


proc sort data = outdata_log;
by ds_libname ds_name line_order;
run;

data outsets(keep=ds_libname ds_name ds_fullname ds_nmerge source nobs_log nvars_log created_in_program) 
outlibs(keep=ds_libname);
length ds_nmerge ds_fullname $80;
set outdata_log;
by ds_libname ds_name line_order;

ds_nmerge=lowcase(ds_fullname);

if last.ds_name then output outsets;
if last.ds_libname then output outlibs;
run;



proc sort data = indata_log;
by ds_libname ds_name line_order;
run;

data insets(keep=ds_libname ds_name ds_fullname ds_nmerge source nobs_log_in) 
inlibs(keep=ds_libname);
length ds_nmerge ds_fullname $80;
set indata_log;
by ds_libname ds_name line_order;

ds_nmerge=lowcase(ds_fullname);

nobs_log_in = nobs_log;

if last.ds_name then output insets;
if last.ds_libname then output inlibs;
run;




/* If you are running the macro from within your program */
/* you can get more information */

%if &inprogram. > 0 %then %do;


proc sql noprint;

/* get information about libnames */

create table inlibs_path as 
select distinct d.libname as ds_libname,
d.path as path  
from dictionary.libnames d, 
inlibs inl
where upcase(inl.ds_libname) = upcase(d.libname) 
order by ds_libname;

create table outlibs_path as 
select distinct d.libname as ds_libname,
d.path as path 
from dictionary.libnames d, 
outlibs outl
where upcase(outl.ds_libname) = upcase(d.libname) 
order by ds_libname;

%if &dsinfo. gt 0 %then %do;

create table setlist as 
select distinct ds_name 
from outsets(keep=ds_name) NATURAL FULL JOIN 
insets(keep=ds_name) 
order by ds_name;

/* get information about the datasets */


create table dsinfo as 
select d.libname as ds_libname,
d.memname as ds_name, 
d.nobs as nobs,
d.nvar as nvar,
d.memlabel as memlabel,
case 
	when upcase(d.libname) ne "WORK" then catx(".",d.libname,d.memname) 
	else d.memname 
end as ds_fullname,
lowcase(calculated ds_fullname) as ds_nmerge 
from dictionary.tables d, 
setlist s 
where upcase(s.ds_name) = upcase(d.memname) 
order by calculated ds_nmerge, d.nobs;

proc sort data = dsinfo;
by ds_nmerge nobs;
run;


data dsinfo;
set dsinfo;
by ds_nmerge nobs;
if last.nobs;
run;

%end;
quit;

%end;


proc sort data = insets;
by ds_nmerge;
run;

proc sort data = outsets;
by ds_nmerge;
run;



data allsets;
length source_inout $15;
merge insets(in=insets)
      outsets(in=outsets) 
      %if &dsinfo. gt 0 and &inprogram. gt 0 %then %do;
	  dsinfo(in=dsi keep = ds_nmerge nobs nvar memlabel)
	  %end;
      ;
by ds_nmerge;
if insets or outsets;

if nobs_log = . then nobs_log = nobs_log_in;

%if &inprogram. gt 0 %then %do;
nobs_final = nobs;
if nobs = . then nobs_final = nobs_log;

nvars_final = nvar;
if nvar = . then nvars_final = nvars_log;
%end;


if insets = 1 and outsets = 0 then  source_inout = "In only";
else if insets = 0 and outsets = 1 then source_inout = "Out only";
else if insets = 1 and outsets = 1 then source_inout = "In and out" ;

if created_in_program = 1 then cip = "Created in program";
else if created_in_program = 0 then cip = "";


if source_inout = "In only" then sort_order = 1;
else if created_in_program = 0 
and  source_inout = "In and out" then sort_order = 2;
else if created_in_program = 1 
and source_inout = "In and out"  then sort_order = 3;
else if created_in_program = 1 
and source_inout = "Out only"  then sort_order = 4;


label ds_libname = "Libname" ds_name = "Dataset Name" 
source_inout = "In/Out" cip = "Created in program?" 
%if &inprogram. gt 0 %then %do;
nobs_final = "Number of Observations" nvars_final = "Number of Variables" 
%end;
nobs_log = "Number of Observations (from log)" 
nvars_log = "Number of Variables (from log)";
run;



proc sort data = allsets;
by sort_order ds_fullname;
run;



%if &dsinfo. gt 0 and &inprogram. gt 0 %then %do;
data outsets;
merge outsets(in=outsets) 
dsinfo(in=dsi keep = ds_nmerge nobs nvar memlabel);
by ds_nmerge;
if outsets = 1 then output outsets;
run;

data insets;
merge insets(in=insets) 
dsinfo(in=dsi keep = ds_nmerge nobs nvar memlabel);
by ds_nmerge;
if insets = 1 then output insets;
run;


%end;

/* output the summary files */


data _null_;
file "&sumoutfile.";
put / "/***---------------------------------------------------------";
put / "|               PROGRAM SUMMARY                              |";
put / "|------------------------------------------------------------";
put / "Name of program: ";
put / "%unquote(&programname.)";
put / ;
run;

data _null_;
file "&sumoutfile." mod;
%if &inprogram. le 0 %then %do;
set inlibs(in=inlib);
%end;
%else %if &inprogram. gt 0 %then %do;
set inlibs_path(in=inlib);
%end;
where upcase(ds_libname) ne "WORK";
if _n_=1 then do;
put / "------------------------------------------------------------";
put / " The libnames used to read input datasets were:";
end;
put / ds_libname %if &inprogram. gt 0 %then %do; path %end; ;
run;

data _null_;
file "&sumoutfile." mod;
%if &inprogram. le 0 %then %do;
set outlibs(in=inlib);
%end;
%else %if &inprogram. gt 0 %then %do;
set outlibs_path(in=inlib);
%end;
where upcase(ds_libname) ne "WORK";
if _n_=1 then do;
put / ;
put / "-----------------------------------------------------------";
put / "The libnames used to save output datasets were:";
end;
put / ds_libname %if &inprogram. gt 0 %then %do; path %end; ;
run;


%if &inprogram. gt 0 %then %do;
data _null_;
file "&sumoutfile." mod;
set outlibs_path;
where upcase(ds_libname) eq "WORK";
if _n_=1 then do;
put / ;
put / "------------------------------------------------------------";
put / "The path for the work directory is:";
end;
put / path ;
run;

%end;



data _null_;
file "&sumoutfile." mod;
set allsets;
where source_inout = "In only" 
and upcase(ds_libname) ne "WORK" ;
if _n_=1 then do;
put / ;
put / "-------------------------------------------------------------";
put / "Datasets used as input but not output: ";
end;
put / ds_fullname;
run; 




data _null_;
file "&sumoutfile." mod;
set allsets;
where created_in_program = 0 
and  source_inout = "In and out" 
and upcase(ds_libname) ne "WORK" ;
if _n_=1 then do;
put / ;
put / "--------------------------------------------------------------";
put / "Datasets created somewhere else, but also used and edited "; 
put / "in this program: ";
end;
put / ds_fullname;
run; 


data _null_;
file "&sumoutfile." mod;
set allsets;
where created_in_program = 1 
and source_inout = "In and out" 
and upcase(ds_libname) ne "WORK" ;
if _n_=1 then do;
put / ;
put / "-------------------------------------------------------------";
put / "Datasets created and used as input in this program: ";
end;
put / ds_fullname;
run; 



data _null_;
file "&sumoutfile." mod;
set allsets;
where created_in_program = 1 
and source_inout = "Out only" 
and upcase(ds_libname) ne "WORK" ;
if _n_=1 then do;
put / ;
put / "-------------------------------------------------------------";
put / "Datasets created in this program but not used as input: ";
end;
put / ds_fullname;
run; 




%if  &tsets gt 0 %then %do;


data _null_;
file "&sumoutfile." mod;
set outsets;
where upcase(ds_libname) = "WORK";
if _n_=1 then do;
put / ;
put / "------------------------------------------------------------------";
put / "Temporary datasets created in this program: ";
end;
put / ds_name;
run; 


%end;

%if &printcomments gt 0 %then %do;

data _null_;
file "&sumoutfile." mod;
set comments;

lag_mname = lag(macro_name);

if _n_=1 then do;
put / ;
put / "------------------------------------------------------------------";
put / "Comments on program ";
end;
if lag_mname ne macro_name then do;
put / macro_name":";
end;
put / text;
run; 


%end;


%if &dsinfo. gt 0 %then %do;


%let snamelength = %length(&sumoutfile.);
%let dssumfile = %substr(&sumoutfile.,1,&snamelength.-4)_dsinfo.pdf;
%put dssumfile = &dssumfile;




ods listing close;
ods pdf file = "&dssumfile." notoc;

proc print data = allsets noobs label;
var cip source_inout ds_libname ds_name 
%if &inprogram. gt 0 %then %do;
nobs_final nvars_final
%end;
%else %if &inprogram. le 0 %then %do;
nobs_log nvars_log
%end;
;
where upcase(ds_libname) ne "WORK" ;
title "Summary information for permanent datasets";
run;

%if  &tsets gt 0 %then %do;

/*outsets*/

proc print data = allsets noobs label;
var ds_name %if &inprogram. gt 0 %then %do;
nobs_final nvars_final
%end;
%else %if &inprogram. le 0 %then %do;
nobs_log nvars_log
%end;
;
where upcase(ds_libname) = "WORK" ;
title "Summary information for temporary datasets";
run;

%end;

ods pdf close;
ods listing;

%end;

data _null_;
file "&sumoutfile." mod;
put / ;
put / "--------------------------------------------------------------------;*/";
run;



%mend;

