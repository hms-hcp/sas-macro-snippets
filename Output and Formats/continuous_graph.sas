*--------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA   |
|--------------------------------------------------------------------------|
| File Name      = dummy_graph.sas                                       |
| Path or URL    = /usr/apps/sas/maclib/                                   |
| Version        =                                                         |
| Creation Date  = 01 Nov 2009                                             |
| Author         = Katya Zelevinsky                                                        |
| Affiliation    = HCP                                                     |
| Category       = Graphics                                                 |
| Keys           =                                                         |
|                                                                          |
|--------------------------------------------------------------------------|
| Brief Description: (1-2 sentences)                                       |
|--------------------------------------------------------------------------|
   Creates graphs of means or medians by category for continuous variables.

*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Update Information: Repeat below fields for each update                  |
|--------------------------------------------------------------------------|
| Modified Date  = 17 Nov 2009                                             |
| By Whom        =       KZ                                                  |
| Reason: Add example of usage, fix some formatting, and add the number 
of observations in file to title of graph.

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

   	Creates graphs of frequency counts by category for continuous variables.
The variable that you want to graph by should be a categorical variable,
or formatted to be a categorical variable (such as location, or date formatted 
by month or quarter).

*--------------------------------------------------------------------------*
| Instructions:                                                            |
|--------------------------------------------------------------------------|

continuous_graph(file,byname,varname,bylabel=,varlabel=,byformat=,
filetitle=,condition=%str(),condtitle=)

Required Parameters:
 
FILE - the data file you want to use
BYNAME - the name variable you are graphing by (the x-axis variable). This 
variable should be categorical. It can be either character or numeric, 
but if it's numeric and continuous, like a date or a person's age, then 
it's better to use BYFORMAT= option to specify a format. The macro
will work with a lot of categories for this variable, but it's not 
recommended, and could cause unpredictable results
VARNAME - the name of the variable you want to graph. For this macro, 
required to be a numeric, continuous variable. 

Optional Parameters:

stat = a way for you to choose which statistic you want to graph. By default, 
it's the MEAN. You can also choose any statistic 
calculated in a PROC MEANS statement, such as MEDIAN, MIN, MAX, 
etc.

bylabel= the label for the by variable. If this is blank, the the program attempts 
to get the label from the data file itself. If the by variable has no label in the 
data file, then the name of the by variable is used.

varlabel= the label for the variable we want to graph. If this is blank, the the 
program attempts to get the label from the data file itself. If the variable has no 
label in the data file, then the name of the by variable is used.

byformat= the format for the by variable. The program does NOT look in the data file 
specified for a format. If you don't specify a format, then 
the by variable will not be formatted.

filetitle=%str() The title of the cohort of data file, for the graph (blank by default)

condition=%str()  If you only want to graph for a subset of the data, you can use this 
option (it should be whatever goes after the "where" and before the semi-colon in a 
where statement. )

condtitle=%str() Anything else you might want to specify in the title of your graph, such 
as a title for your subset, etc

NOTE: This macro does NOT include a goptions statment, so all the graphical options for the graph
(such as size of graph, etc) have to be set before the macro is run, or there will be 
unpredictable results.                                                                               ;

/* 

Example of calling the macro (with the graphical options set to create a landscape graph per page):

ods pdf notoc file="Test graphs.pdf" ;
ods graphics on ;
ods listing close;

options orientation = landscape;
goptions reset=global cback=white  lfactor=2 border   
vsize=8in hsize=11in rotate=landscape;

[if you are running this in unix, you should  also add "device= PDFC" to the goptions statment]

%let filetitle = The Full Dataset;

%continuous_graph(libref.dataset,hospital,age,stat=mean,byformat=,filetitle=&filetitle,
condition=%str(mortality=1),condtitle=%str(Mortalities Only));


ods pdf close;
ods graphics off;
ods listing;

*/


*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Macro Code Begins Here.                                                  |
*--------------------------------------------------------------------------*;



%macro continuous_graph(file,byname,varname,stat=MEAN,bylabel=,varlabel=,byformat=,filetitle=,condition=%str(),condtitle=);

data _null_;
stat_propcase = propcase("&stat.");
call symput('stat_propcase',left(trim(stat_propcase)));
run;


data file;
set &file;
%if %length(&condition) > 0  %then %do;
where &condition ;
%end;
run;

proc contents data = file noprint out = contents;
run;

%if %length(&varlabel)=0 %then %do;
data _null_;
set contents;
where lowcase(name) = lowcase("&varname");
if label ne "" then do;
call symput("varlabel", left(trim(label))) ;
end;
else do;
call symput("varlabel", left(trim(name))) ;
end;
run;
%end;


data _null_;
set contents;
where lowcase(name) = lowcase("&byname");

%if %length(&bylabel)=0 %then %do;
if label ne "" then do;
call symput("bylabel", left(trim(label))) ;
end;
else do;
call symput("bylabel", left(trim(name))) ;
end;
%end;

call symput("bytype", left(trim(type))) ;
call symput("nobs", left(compress(nobs))) ;
run;



proc means data = file noprint;
class &byname;
var &varname ;
output out=varmeans(where=(_TYPE_=1)) &stat=&varname;
format
%if %length(&byformat) > 0  %then %do;
&byname &byformat.
%end;
&varname;
run;


data flength(keep= bflength);
set varmeans;
%if %length(&byformat) > 0 %then %do;
bflength = length(put(&byname,&byformat.));
%end;
%else %do;
bflength = length(&byname);
%end;
run;

proc summary data = flength;
var  bflength;
output out =  flength(keep= bflength) max= bflength;
run;

data _null_;
set  flength;
call symput('bflength',left(compress(bflength," ")));
run;


proc sort data = varmeans;
by &byname &varname;
run;

data varmeans(keep = &byname &varname &byname._categories);
length 	&byname._categories $&bflength. ;
set  varmeans;
by &byname &varname;
%if %length(&byformat) > 0 %then %do;
&byname._categories = left(trim(put(&byname,&byformat.)));
%end;
%else %do;
&byname._categories = left(trim(put(&byname,$&bflength..)));
%end;
run;


proc sort data =  varmeans;
by &byname;
%if %length(&byformat) > 0 %then %do;
format &byname &byformat.;
%end;
run;


data bycats;
set  varmeans;
by &byname;
if first.&byname;

retain bycount 0;
bycount = bycount + 1;
call symput('bycat'||left(trim(bycount)),left(trim(&byname._categories)));
call symput('numbycats',left(trim(bycount)));
%if %length(&byformat) > 0 %then %do;
format &byname &byformat.;
%end;
run;



axis1 order = (%do count = 1 %to &numbycats;"&&bycat&count" %end;) %if (&numbycats > 10 and (&bytype ne 1 or %length(&byformat)> 0)) %then %do; value=(angle=90) %end; ;
axis2  label=(angle=90 "&stat_propcase.") ;
symbol1 v=dot i=j c=blue;

proc gplot 	data=varmeans;	
	plot &varname*&byname._categories/ haxis=axis1 vaxis=axis2 ;
label  &varname = "&varlabel" &byname._categories = "&bylabel";
format &varname;

title "&stat_propcase &varlabel by &bylabel";
%if   %length(&filetitle) <= 0 and 	%length(&condtitle) <= 0  and  %length(&condition) <= 0 %then %do;
title2 "(N=&nobs.)";
%end;
%if %length(&filetitle) > 0 %then %do;
%if %length(&condition) > 0 or %length(&condtitle) > 0 %then %do;
title2 "in &filetitle";
%end;
%else %do;
title2 "in &filetitle.    (N=&nobs.)";
%end;
%end;
%if %length(&condition) > 0 or %length(&condtitle) > 0 %then %do;
%if %length(&filetitle) > 0 %then %do; title3 %end; %else %do; title2 %end;   
%if  %length(&condtitle) <= 0  %then %do;
"where &condition.    (N=&nobs.)" ;
%end;
%else %if %length(&condtitle) > 0  %then %do;
"&condtitle.    (N=&nobs.)" ;
%end;
%end;
run;
quit;



%mend;
