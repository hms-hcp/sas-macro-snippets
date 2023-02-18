*--------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA   |
|--------------------------------------------------------------------------|
| File Name      = categorical_graph.sas                                       |
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
   Creates graphs of frequency counts by category for categorical variables.

*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Update Information: Repeat below fields for each update                  |
|--------------------------------------------------------------------------|
| Modified Date  = 17 Nov 2009                                             |
| By Whom        =       KZ                                                  |
| Reason: Add example of usage, and add the number of observations in file
to title of graph.

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

   	Creates graphs of frequency counts by category for categorical variables.
The variable that you want to graph by should be a categorical variable,
or formatted to be a categorical variable (such as location, or date formatted 
by month or quarter).

*--------------------------------------------------------------------------*
| Instructions:                                                            |
|--------------------------------------------------------------------------|

categorical_graph(file,byname,varname,bylabel=,varlabel=,byformat=,varformat=,
filetitle=%str(),printcatlist=%str(),noprintcatlist=%str(),condition=%str(),
condtitle=%str())

Required Parameters:
 
FILE - the data file you want to use
BYNAME - the name variable you are graphing by (the x-axis variable). This 
variable should be categorical. It can be either character or numeric, 
but if it's numeric and continuous, like a date or a person's age, then 
it's better to use BYFORMAT= option to specify a format. The macro
will work with a lot of categories for this variable, but it's not 
recommended, and could cause unpredictable results
VARNAME - the name of the variable you want to graph. For this macro, 
required to be a categorical variable, either numeric or character. If 
it's numeric, you might either want to use the varformat= option to define 
a format, or to make sure it's formatted properly in the data file you use.

Optional Parameters:
bylabel= the label for the by variable. If this is blank, the the program 
attempts to get the label from the data file itself. If the by variable has 
no label in the data file, then the name of the by variable is used.

varlabel= the label for the variable we want to graph. If this is blank, the 
the program attempts to get the label from the data file itself. 
If the variable has no label in the data file, then the name of the by 
variable is used.

byformat= the format for the by variable. The program does NOT look in the data 
file specified for a format. If you don't specify a format, then 
the by variable will not be formatted.

varformat= The format for the categorical variable you want to graph. 
If this is blank, the program will look in the dataset you specify for 
a format to use. If there is no format associated with that variable, 
the variable will not be formatted.

filetitle=%str() The title of the cohort of data file, for the graph (blank by default)

printcatlist=%str()	List of the categories of the &vartitle variable that you want to include 
on your graph . Be careful to make sure that the character variable categories are included 
in quotation marks

noprintcatlist=%str()  List of the categories of the &vartitle variable that you do NOT want 
to include on your graph (eg, N/A) . Be careful to make sure that the character variable 
categories are included in quotation marks

condition=%str()  If you only want to graph for a subset of the data, you can use this 
option (it should be whatever goes after the "where" and before the semi-colon in a 
where statement. )

condtitle=%str() Anything else you might want to specify in the title of your graph, such as a 
title for your subset, etc 

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

%categorical_graph(libname.dataset,procdate,age,varformat=agegrp.,byformat=mmyyd.,filetitle=%str(&filetitle),
printcatlist=%str(),noprintcatlist=%str(),condition=%str(mortality=1),condtitle=%str(Mortalities Only));	


ods pdf close;
ods graphics off;
ods listing;

*/


*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Macro Code Begins Here.                                                  |
*--------------------------------------------------------------------------*;


%macro categorical_graph(file,byname,varname,bylabel=,varlabel=,byformat=,varformat=,
filetitle=,printcatlist=%str(),noprintcatlist=%str(),condition=%str(),condtitle=);

data file;
set &file;
%if %length(&condition) > 0  %then %do;
where &condition ;
%end;
run;

proc contents data = file noprint out = contents;
run;

data _null_;
set contents;
where lowcase(name) = lowcase("&varname");

%if %length(&varlabel)=0 %then %do;
if label ne "" then do;
call symput("varlabel", left(trim(label))) ;
end;
else do;
call symput("varlabel", left(trim(name))) ;
end;
%end;

call symput("vartype", left(trim(type))) ;
call symput("nobs", left(compress(nobs))) ;

%if %length(&varformat)=0 %then %do;
if format ne "" then do;
call symput("varformat", left(trim(format))) ;
end;
%end;

run;

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
run;


proc sort data = file;
by &byname;
run;

proc freq data = file noprint;
by &byname;
tables &varname / out=varfreqs missing;
%if %length(&byformat) > 0  %then %do;
format &byname &byformat.;
%end;
%if %length(&varformat) > 0 %then %do;
format &varname &varformat..;
%end;
run;

data flength(keep=flength bflength);
set varfreqs;
%if %length(&varformat) > 0 %then %do;
flength = length(put(&varname,&varformat..));
%end;
%else %do;
flength = length(&varname);
%end;
%if %length(&byformat) > 0  %then %do;
bflength = length(put(&byname,&byformat.));
%end;
%else %do;
bflength = length(&byname);
%end;
run;

proc summary data = flength;
var flength bflength;
output out =  flength(keep=flength bflength) max=flength bflength;
run;

data _null_;
set  flength;
call symput('flength',left(compress(flength," ")));
call symput('bflength',left(compress(bflength," ")));
run;

data varfreqs;
length var_formatted_value $&flength.; 
set varfreqs;
%if %length(&varformat) > 0 %then %do;
var_formatted_value = left(trim(put(&varname,&varformat..)));
%end;
%else %do;
%if &vartype = 1 %then %do; 
var_formatted_value = left(trim(put(&varname,&flength..)));
%end;  
%else %if &vartype ne 1 %then %do; 
var_formatted_value = left(trim(put(&varname,$&flength..))); 
%end;
%end;
run;

proc sort data =  varfreqs;
by var_formatted_value;
run;


data categoriesonly(keep = var_formatted_value &varname catcount);
set varfreqs;
by var_formatted_value;
if first.var_formatted_value;
retain catcount 0;
catcount = catcount + 1;
call symput('cat'||left(trim(catcount)),left(trim(var_formatted_value)));
call symput('catorig'||left(trim(catcount)),left(trim(&varname)));
call symput('numcats',left(trim(catcount)));
run;

data varfreqs;
merge  categoriesonly  varfreqs;
by var_formatted_value;
run;



proc sort data =  varfreqs;
by &byname catcount;
run;

data categories_&byname;
length var_formatted_value $200 
%if &vartype = 2 %then %do; &varname.2 $&flength. %end; ; 
set varfreqs(keep=&byname);
by &byname;
if first.&byname;
%do count = 1 %to &numcats;
catcount = &count;
var_formatted_value = "&&cat&count";
&varname.2 = %if &vartype = 1 %then %do; &&catorig&count %end;  %else %if &vartype = 2 %then %do; left(trim("&&catorig&count")) %end; ;
output;
%end;
run;

proc sort data = categories_&byname; 
by &byname catcount;
run;


data varfreqs_final;
length 	&byname._categories $&bflength. ;
merge categories_&byname varfreqs;
by &byname catcount;

%if %length(&byformat) > 0  %then %do;
&byname._categories = left(trim(put(&byname,&byformat.)));
%end;
%else %do;
&byname._categories = left(trim(put(&byname,$&bflength..)));
%end;

if &varname = %if &vartype = 1 %then %do; . %end;  %else %if &vartype = 2 %then %do; "" %end; then do ;

percent = 0;
count = 0;
var_formatted_value = left(trim(var_formatted_value));
&varname = 	&varname.2;
end;

run;


proc sort data =  varfreqs_final;
by &byname;
%if %length(&byformat) > 0 %then %do;
format &byname &byformat.;
%end;
run;

data bycats;
set  varfreqs_final;
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
axis2  label=(angle=90 "Percent") ;

/*
symbol1 v=dot i=j c=blue;
symbol2 v=triangle i=j c=red;
symbol3 v=diamond i=j c=green;
symbol4 v=star i=j c=brown;
symbol5 v=square i=j c=black;
symbol6 v=circle i=j c=violet;
symbol7 v=_ i=j c=tan;
symbol8 v=$ i=j c=darkred;
*/

%let symbollist =  dot triangle diamond circle square $ = _ x : star ;
%let colorlist= blue red green brown violet black tan grayishblue gray orange olive rosybrown purple;
%do  sc = 1 %to %eval(%sysfunc(min(&numcats,255)));
  symbol&sc  v=%scan(%str(&symbollist),%eval(%sysfunc(mod(&sc-1,11))+1),%str( )) i=j 
  c=%scan(%str(&colorlist),%eval(%sysfunc(mod(&sc-1,13))+1),%str( )) 
  %if &sc > 11 %then %do; line=%eval(%sysfunc(mod(&sc-10,46))+1) %end; ;
%end;


proc gplot 	data=varfreqs_final;
%if %length(&printcatlist) > 0 or %length(&noprintcatlist) > 0  %then %do;
where %if %length(&printcatlist) > 0 %then %do; &varname in (&printcatlist)  %if %length(&noprintcatlist) > 0 %then %do; and %end; %end; 
%if %length(&noprintcatlist) > 0 %then %do; &varname not in (&noprintcatlist) %end; ;
%end;
plot percent*&byname._categories = var_formatted_value / haxis=axis1 vaxis=axis2 legend;

label var_formatted_value = "&varlabel"
       &byname._categories = "&bylabel";


title "Frequency counts for &varlabel by &bylabel";
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
