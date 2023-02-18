/*--------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA   |
|--------------------------------------------------------------------------|
| File Name      = getdsnames.sas                                          |
| Path or URL    = /usr/apps/sas/maclib/                                   |
| Version        =   1                                                     |
| Creation Date  = 05 JUN 2016                                             |
| Author         = KATYA ZELEVINSKY                                        |
| Affiliation    = HCP                                                     |
| Category       =                                                         |
| Keys           =                                                         |
|                                                                          |
|--------------------------------------------------------------------------|
| Brief Description: (1-2 sentences)                                       |
|--------------------------------------------------------------------------|
   

Provides datasets containing libnames, names and source for input and output 
datasets defined in a SAS program by using the program log file. 

*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Update Information: Repeat below fields for each update                  |
|--------------------------------------------------------------------------|
| Modified Date  = 15 JUN 2016                                             |
| By Whom        = Katya Zelevinsky                                        |
| Reason: 
  
  Fix some issues and change the macro so it runs the %readin_log macro to
read in log files to get datasets from the entire program, instead of using 
macro code only. 


*--------------------------------------------------------------------------*
| Update Information: Repeat below fields for each update                  |
|--------------------------------------------------------------------------|
| Modified Date  = 30 JAN 2017                                             |
| By Whom        = Katya Zelevinsky                                        |
| Reason: 
  
  Make some corrections to the macro so that it deals better with PROC SQL

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



The macro creates uses the %readin_log macro to read in SAS program logs, 
and uses the output from that macro to create three datasets -  
&indsname.&suffix., &outdsname.&suffix., and (in some situations) &commentname.&suffix

1. &indsname.&suffix. CONTAINS:
names, libnames, source and order of creation of INPUT DATASETS 
used in the following places in the program:

the set or merge statements of the data step
the data= option of procedures
the from clause of proc sql
any other datasets we can pick up from the notes in the log 
(currently marked as "LOG IN" or "LOG OUT" or "LOG SQL" 
in the source variable, although this will probably 
change in the next version)

VARIABLES IN DATASET: 

LOGPATH - the path and name of the log being parsed

LOG_LINE - the line number the log assigns to the location in the code where the dataset 
was found. (For ease of look-up of the dataset) 
For datasets defined in macros, this would be the last line of the code before the mprint code 
for that macro in the log

LINE_ORDER = since LOG_LINE is the same for macro code, this variable shows the order of 
the line the dataset is defined in, so we can sort the datasets in oder they were defined
on the original program

ORIGIN_MACRO = 1 if the dataset was defined inside a macro; 0 otherwise

MACRO_NAME - name of the macro the dataest was defined in; 
if the dataset is defined outside a macro, MACRO_NAME = the text version of LOG_LINE

SOURCE - the name of the step the dataset is defined in. If the code can't get the 
name of a procedure the dataset is defined in, SOURCE = "PROCEDURE"

DS_FULLNAME - the full name of the datasets - ie, [LIBNAME].[DATASET NAME]

DS_LIBNAME - the libname of the datasets (all capitalized)

DS_NAME - the name of the dataset (all capitalized)

CODE = 1 if the dataset name was first found in the code of the program that 
	   is printed in the log (even though we might later get more information fron the notes),
	   0 if the dataset was only found in the notes added in the log

NOBS_LOG - the number of observations in the dataset at that step of the program, 
as obtained from the log notes 

INPUT_CONDITION - if the dataset is invoked with a WHERE statement, this variable 
				   includes the condition that was used (so you know that the NOBS_LOG 
				   variable refers to the number of observations fitting that condition 
			       and not the number of observations in the dataset overall)



2. &outdsname.&suffix. CONTAINS:
names, libnames, source, and order of creation of OUTPUT DATASETS 
created in the following places:

the data statement of the data step
the create table clause of proc sql
the out= option of procedures
ods output

VARIABLES IN DATASET: 

LOGPATH, LOG_LINE, LINE_ORDER, ORIGIN_MACRO, MACRO_NAME, SOURCE, 
DS_FULLNAME, DS_LIBNAME, DS_NAME, CODE, NOBS_LOG - all defined the same as above; 

NVARS_LOG - the number of variables the dataset contained when it was created

CREATED_IN_PROGRAM = 1 if the dataset is first created in the program
					 0 if this is an already existing dataset that is being edited 
					   by the program





3. &commentname.&suffix. CONTAINS:

any important comments of the form 
[slash]* !!!!! [comment text] *[slash] 
in the text of the program being examined, so that 
they can be output separately into a text file to get a get a 
description of the program on the fly.

VARIABLES IN DATASET: 

LOG_LINE, LINE_ORDER, MACRO_NAME defined as above

TEXT - the text of the comments

MACRO_NUMBER - the number of times a macro has been defined in the 
code so far

MEND_NUMBER - the number of times a macro has been closed with an MEND statement
(can be used to decide how to display comments defined within nested macros)


NOTE: This dataset is only created if a name for the dataset 
is specified using the &commentname. variable 
when calling the macro, AND if the code actually 
contains any important comments marked in this way



The datasets contain every mention of the datasets and the location (data/sql/procedure)
where they were mentioned, so THERE WILL BE REPEATED MENTIONS OF DATASETS 
if the datasets are edited or used more than once.	
The idea is to create at least a vague timeline for when these datasets were
created/used in a data step. The variable LINE_ORDER in the datasets 
is there to indicate what order the datasets were created or used.

(logpath=,logfilename=,indsname=indata,outdsname=outdata,commentname=,
suffix=,exclpdsinfo=1);


PARAMETERS:

LOGPATH - path and name for the log you want to check through (no default; required to be defined)

LOGFILENAME - if the macro is run from within the program you are interested in
checking, this is the filename defined in the program for the log (default = blank)

INDSNAME - main part of the name for the input dataset (default: indata) 
OUTDSNAME - main part of the name for the output dataset (default: outdata)
COMMENTNAME - main part of the name for the dataset with the comments (blank by default)
SUFFIX - suffix 
NEEDREADIN - 1 if you need to run the %readin_log macro to get the temporary datasets you need
			 0 if you've already run the %readin_log macro and don't need to rerun it inside this macro
EXCLPDSINFO - 	1 if you want to exclude any datasets defined by running %PDSINFO within the program
				0 otherwise (default: 1)


KNOWN ISSUES: 

- Macro variables used outside of macro code do not get resolved in the log,
so when getting dataset and libname names from program code, 
datasets and libnames using macro variables outside of macros get deleted 
so they don't mess up the list of datasets. Information about such datasets 
should still picked up from the notes, but we do lose some information about what 
step they were created in.

- (FIXED: This macro sometimes has trouble parsing PROC SQL code, and sometimes finds the 
wrong input datasets - especially where temporary datasets, or variables 
defined in the form [dataset].[variable name] are concerned. It is usually 
pretty clear which datasets are like this, so you can just delete them.)

- Also, very long PROC SQL clauses might get truncated 
which also interferes with finding the input datasets for PROC SQL.

 
*--------------------------------------------------------------------------*
| Instructions:                                                            |
|--------------------------------------------------------------------------|


A typical call for this macro looks as follows:

%let lpath = [log path];
%getdsnames(logpath=&lpath,indsname=indata,outdsname=outdata,suffix=_log);


To use this macro inside a program running in unix batch mode that 
you want to get information on in real time, 
you can include the following code at the end of the program:

%macro setexecpath;
%global FullName FNameStart;


%let FullName=%sysfunc(GetOption(SYSIN));
%if %length(&FullName)=0
   %then %let FullName=%sysget(SAS_EXECFILEPATH);
%let FullLen=%length(&FullName);
%let FNameStart=%scan(&FullName,-1,".");
%mend;

%setexecpath;


%let lpath = &FNameStart..log;
%put lpath=&lpath;

filename lfile pipe "cat &lpath.";
%getdsnames(logpath=&lpath,indsname=indata,outdsname=outdata,suffix=_log);




(in interactive SAS, you will also need to use proc printto or 
the %pdsprintto macro to output the log first.)


*--------------------------------------------------------------------------*;*/


*--------------------------------------------------------------------------*
| Macro Code Begins Here.                                                  |
*--------------------------------------------------------------------------*;



%macro getdsnames(logpath,logfilename=,indsname=indata,outdsname=outdata,commentname=,
suffix=,needreadin=1,exclpdsinfo=1);

/* !!!!!! STEP 1: read in log */

%if &needreadin > 0 %then %do;

%readin_log(logpath=&logpath.,logfilename=&logfilename.);

%end;


/* !!!!!! STEP 2: Read through program code to get source of definitions 

create two datasets &indsname.&suffix. and &outdsname.&suffix.

&indsname.&suffix. contains:
names, libnames, source and order of creation of permanent input datasets used in the following places in the program:

the set or merge statements of the data step
the data= option of procedures
the from clause of proc sql

&outdsname.&suffix. contains:
names, libnames, source, and order of creation of permanent and temporary output datasets created in the following places:

the data statement of the data step
the create table clause of proc sql
the out= option of procedures
ods output
*/


data &indsname.&suffix. &outdsname.&suffix. ;
length log_line 8 origin_macro 3. macro_name $35 source $15 ds_fullname $80 ds_libname $20  ds_name $50 text_orig $500 text_from_code text $2000 line_order 8;
set code;

text_from_code = text;
code = 1;

/* defined regular expressions patterns need to be retained */

retain dsnpat 
opattern dpattern soutpattern sinstartpat sinendpat 
sjoinpat
setpattern proc_pat 
setpoint_pattern mvar_pattern parenpat 
quot1_pat quot2_pat
index_pattern
;

if _n_ = 1 then do;


opattern = prxparse("/(\bout|\boutpost)\s*\=/I");
/* regex pattern for out = */

dpattern = prxparse("/(\s|^)(\bdata\b)(\s*\=)?/I");
/* pattern for data or data =  */

soutpattern = prxparse("/(\bcreate\s+table)/I");
/* pattern for sql create table */


sinstartpat = prxparse("/(\s+from\s+)/I");
/*pattern for the start of the part of sql code that lists the input datasets */
/* starting with FROM */

sinendpat = prxparse("/where|having|order by|group by|;|$/I");

/*pattern for the end of the part of sql code that lists the input datasets */
/* eg, WHERE or HAVING or ORDER BY etc */


sjoinpat = prxparse("s/(\s+on\s+)([=\w\.\s,]+)+(join|\)|where|order\s+by|;)/$1 $3/I");

/* delete join conditions in SQL (like JOIN ON [variables]) */
/* so the variables don't get grabbed as input datasets */
/* NOTE: this might delete the end of the SQL statement unless there is a where  
statement but we don't really care, because all we care about here are the permanent 
datasets after the FROM step */



setpattern = prxparse("/(\s|^)(\bset\b|\bmerge\b)\s/I"); 

setpoint_pattern = prxparse("s/\bpoint\s*=\s*\S+/ /");

/* 
if using a "point = [x]" in the set statement 
then delete it, so it doesn't get grabbed as a 
temporary dataset 

pattern matches [start of word]point 0+ spaces = 0+ spaces, 1+ non-whitespace character
replaces with blank
*/



dsnpat = prxparse("/(\b\w+\.)?(\w+\b)/i");
/* 
pattern for dataset names
matches either one word separately, 
or two words separated by ., with no spaces in between 

" |^" matches a space or the beginning of the line 
(\w+\.)? matches one or more word characters followed by a ., happening either 0 or 1 time 
(\w+) matches one or more word character after the .
*/



mvar_pattern = prxparse("s/\s+([a-zA-Z\d_&\.]*&+[a-zA-Z\d_&\.]*)(?=\s|;)/ /");

/* pattern for datasets and libnames with unresolved macro variables in them (ie, defined in code outside of macros 
using macro variables that don't get resolved) - we will get them from the notes anyway, so might as well
delete them from here (will lose information about which step the dataset was defined in)

pattern matches groupings of word characters plus & and ., with at least one & in them, with at least one space in front, 
and with a space or a ; at the end (the space or ; at the end is not included in the pattern) 
*/


parenpat = prxparse("s/\([^\(\)]*\)/ /");

/* 
pattern to delete any options listed in parentheses 
(I don't think there is any code that defines datasets 
in parentheses)
pattern matches any characters (except another set of parentheses) 
in parentheses and replaces with a space 
*/


proc_pat = prxparse('/(\bproc\s+\w*\b)/I');

/* pattern for procedure names, to use that as the source for datasets obtained using 
data = and out = 

pattern matches [start of word]proc 1+ spaces word[end of word]
*/


quot1_pat = prxparse('s/"[^"]*"/ /');
quot2_pat = prxparse("s/'[^']*'/ /");

/* 
delete anything in quotation marks because it might mess up this code 
and it won't contain any datasets anyway
*/


index_pattern = prxparse("s/\bindex\(\w+,.+\)|\bprx\w+\(.*\)/ /");

/* delete index or prxchange functions, because there will be no datasets inside 
them and they mess up the code */


end;


/* looking through code for datasets */

/* delete index or prxchange functions, because there will be no datasets inside 
them and they mess up the code */

call prxchange(index_pattern,-1,text);


/*delete any options in parentheses to avoid extraneous dataset names */
call prxchange(parenpat,-1,text);

/* 
delete anything in quotation marks because it might mess up this code 
and it won't contain any datasets anyway
*/

call prxchange(quot1_pat,-1,text);
call prxchange(quot2_pat,-1,text);





/* delete any dataset names with unresolved macro variables */

call prxchange(mvar_pattern,-1,text);


/* look for datasets defined by "data" or "data =" */

dcheck =  prxmatch(dpattern,text);
if dcheck > 0  then do;

/*check to see if it's data step or "Data =" option */
call prxposn(dpattern,3,eqstart,eqlength);

/* if there is no "=" after "data", then it's a data statement 
and there are one or more output datasets */

	if eqlength = 0 then do;
		call prxposn(dpattern,2,dstart,dlength);
		start = dstart+dlength;
		stop=length(text);
		call prxnext(dsnpat,start,stop,text,position,length);
		do while (position gt 0);
             ds_fullname = substr(text,position,length);
             ds_name = scan(ds_fullname,-1,'.');
			 if scan(ds_fullname,2,'.') = "" then ds_libname = "WORK";
			 else if scan(ds_fullname,2,'.') ne "" then ds_libname = scan(ds_fullname,1,'.');
             source = "DATA";
			 output &outdsname.&suffix.;
			 call prxnext(dsnpat,start,stop,text,position,length);
        end; 

	end;
/* if there is an "=" after "data", then it's a data option in a procedure 
and there is one input dataset after it */

	else if eqlength > 0 then do;
	    /* get the text after the " =" sign*/
	    tstart = eqstart + eqlength;
	    tlength = (length(text) - tstart)+1;
		text=substr(text,tstart,tlength);
		call prxsubstr(dsnpat,text,fnpos,fnlength);
	    ds_fullname = substr(text,fnpos,fnlength);
        call prxposn(dsnpat,1,libpos,liblength);
		call prxposn(dsnpat,2,dsnpos,dsnlength);

		ds_name = substr(text,dsnpos,dsnlength);

		/* 
		decided to look as temporary input datasets as well as permanent
		for the purposes of keeping track of the program's flow 
		*/

		if liblength = 0 then do;
			ds_libname = "WORK";
			ds_fullname = catx(".",ds_libname,ds_name);
		end;
		else if liblength > 0 then do;
        	ds_libname = substr(text,libpos,liblength-1);
		end;
		if prxmatch(proc_pat,text_from_code) > 0 then do;
		source = upcase(prxposn(proc_pat,1,text_from_code));
		end;
		else source = "PROCEDURE";
		output &indsname.&suffix.;

		/* if the dataset is used in proc sort and there is no out = set 
		 then the input set is also an output set */

		if source="PROC SORT" and prxmatch(opattern,text_from_code) <= 0 then output &outdsname.&suffix.;;
	end;

end;


/* get input datasets used in the set or merge statements */

setcheck = prxmatch(setpattern,text);

if setcheck > 0 then do;

/* delete any uses of the "point=" option in the set statement 
so it can't be used as a temporary dataset
*/
call prxchange(setpoint_pattern,-1,text);

	if prxmatch(dsnpat,text) > 0 then do;
		call prxsubstr(setpattern,text,spos,slength);
		start = spos + slength;
		stop = length(text);
		call prxnext(dsnpat,start,stop,text,position,length);
		do while (position gt 0);
        	ds_fullname = substr(text,position,length);
			if scan(ds_fullname,2,'.') = "" then do;
				ds_libname = "WORK";
				ds_name =  scan(ds_fullname,-1,'.');
				ds_fullname = catx(".",ds_libname,ds_name);
			end;
			if scan(ds_fullname,2,'.') ne "" then do; 
				ds_name = scan(ds_fullname,2,'.');
        		ds_libname = scan(ds_fullname,1,'.');
			end;
		source = upcase(prxposn(setpattern,2,text));
		output &indsname.&suffix.;
		call prxnext(dsnpat,start,stop,text,position,length);
 	    end; 

	end;
end;



/* get output datasets defined using sql */

soutcheck = prxmatch(soutpattern,text);

if soutcheck > 0 then do;
	call prxsubstr(soutpattern,text,spos,slength);
	tstart = spos + slength;
	tlength = (length(text) - tstart)+1;
	text=substr(text,tstart,tlength);
	call prxsubstr(dsnpat,text,fnpos,fnlength);
	ds_fullname = substr(text,fnpos,fnlength);
    call prxposn(dsnpat,1,libpos,liblength);
	call prxposn(dsnpat,2,dsnpos,dsnlength);

	ds_name = substr(text,dsnpos,dsnlength);

	if liblength = 0 then ds_libname = "WORK";
	else if liblength > 0 then ds_libname = substr(text,libpos,liblength-1);
    source = "SQL";
	output &outdsname.&suffix.;
end;


/* 
get input permanent datasets used in the sql step 
getting temporary datasets is too difficult, and we 
don't really need them for anything and they aren't
even mentioned in the log
*/



sincheck = prxmatch(sinstartpat,text);

if sincheck > 0 then do;
	if prxmatch("/ join /I",text) > 0 then do;
		call prxchange(sjoinpat,-1,text);
	end;
	start = prxmatch(sinstartpat,text);
    stop=prxmatch(sinendpat,text)-1;
	call prxnext(dsnpat,start,stop,text,position,length);
	do while (position gt 0);
        ds_fullname = substr(text,position,length);
		/* No need to keep names of temporary input files */
		/* if scan(ds_fullname,2,'.') = "" then ds_libname = "WORK"; */
		if scan(ds_fullname,2,'.') ne "" then do; 
			ds_name = scan(ds_fullname,2,'.');
        	ds_libname = scan(ds_fullname,1,'.');
        	source = "SQL";
			output &indsname.&suffix.;
		end;
		call prxnext(dsnpat,start,stop,text,position,length);
     end; 
end; 


/* get output datasets defined using the out= option */

ocheck =  prxmatch(opattern,text);
if ocheck > 0  then do;
	call prxsubstr(opattern,text,opos,olength);
	tstart = opos + olength;
	tlength = (length(text) - tstart)+1;
	text=substr(text,tstart,tlength);
	call prxsubstr(dsnpat,text,fnpos,fnlength);
	ds_fullname = substr(text,fnpos,fnlength);
    call prxposn(dsnpat,1,libpos,liblength);
	call prxposn(dsnpat,2,dsnpos,dsnlength);

	ds_name = substr(text,dsnpos,dsnlength);

	if liblength = 0 then ds_libname = "WORK";
	else if liblength > 0 then ds_libname = substr(text,libpos,liblength-1);
    if prxmatch(proc_pat,text_from_code) > 0 then do;
		source = upcase(prxposn(proc_pat,1,text_from_code));
	end;
	else source = "PROCEDURE";
	output &outdsname.&suffix.;

end;


/* get output datasets defined using ods output */

odscheck = prxmatch("/(ods\s+output)/I",text);
if odscheck > 0 then do;
	/* take every dataset after "=" sign*/
    eqindex = prxmatch("/=/",text);
	do while (prxmatch("/=/",text) > 0);
		tstart = prxmatch("/=/",text)+1;
		tlength = (length(text) - tstart)+1;
		totlength = length(text);
    	text = substr(text,tstart,tlength);
		eqindex = prxmatch("/=/",text);
		call prxsubstr(dsnpat,text,fnpos,fnlength);
		ds_fullname = substr(text,fnpos,fnlength);
    	call prxposn(dsnpat,1,libpos,liblength);
		call prxposn(dsnpat,2,dsnpos,dsnlength);

		ds_name = substr(text,dsnpos,dsnlength);

		if liblength = 0 then ds_libname = "WORK";
		else if liblength > 0 then ds_libname = substr(text,libpos,liblength-1);
	    source = "ODS";
		output &outdsname.&suffix.;
        
	end;
end;

 keep text_from_code log_line origin_macro macro_name source ds_fullname ds_name ds_libname line_order code; 

/*output;*/
run;



/* !!!!!! STEP 3: get datasets with information about the sets from the notes */
/* 
For now, if the input dataset had a WHERE condition 
associated with it, that WHERE condition is included on a separate line.
Will combine in later step
*/

data notesoutput notesinput;
set notes;
length log_line 8. origin_macro 3. macro_name $35 source $15 ds_fullname $80 ds_libname $20  ds_name $50 nobs_log 8. nvars_log 8. text_orig $500 text_from_notes text $2000 
ds_libname_input $20  ds_name_input $50 ds_fullname_input $80 input_condition $200 source_input $10  nobs_log_input 8;

retain input_pattern output_pattern where_pattern nonnative_pattern;

code = 0;
text_from_notes = text;


if _n_ = 1 then do;


/* patterns for Notes that warn about a dataset being in a non-native format different 
from the system it's being run on.
Leaving these in might make the macro grab datasets that are not being used in the program,
so they need to be deleted 
example: 
NOTE: Data file TMP1.AHRF2012.DATA is in a format that is native to 
      another host, or the file encoding does not match the session 
      encoding. Cross Environment Data Access will be used, which might 
      require additional CPU resources and might reduce performance.

pattern:
NOTE:+0+spaces
Data file+0+spaces
word.word.word
*/ 

nonnative_pattern = prxparse('/NOTE:\s*Data file\s*(\b\w*[a-z]\w*)\.(\b\w*[a-z]\w*)\.(\w+\b)/I');




/* input pattern for SAS log */
/* 
example: 
NOTE: There were 1000000 observations read from the data set WKDIR.EXAMPLESET

pattern:
NOTE:+0+spaces
0+ non-digit characters, 
then 1+ digit which is the number of observations, surrounded on both sides by at least one space  - grouping 1, 
then 1+ non-digit characters, 
then word with at least one letter.word - grouping 2 and 3
*/


input_pattern = prxparse('/NOTE:\s*\D*\s+(\d+)\s+\D+(\b\w*[a-z]\w*)\.(\w+\b)/I');


/* WHERE pattern */
/*
Example:
WHERE ABS((FROM_DT-date_diag1))<=182;

pattern:
WHERE+1+spaces
1+non-space character then 0+ any characters until the end of line - grouping 1 - where condition
*/

where_pattern = prxparse('/WHERE\s+(\S+.*)$/');


/* output pattern for SAS log */
/* 
Example:
NOTE: Table WKDIR.EXAMPLE2 created, with 250000 rows and 10 columns
or 
NOTE: The data set WKDIR.OP2012ALLCANCERDIAGS has 1101409 observations and 197 variables

pattern:
NOTE:+0+spaces
0+ non-digit characters - grouping 1 - "Table" for data created with SQL
word with at least one letter.word - grouping 2 and 3
1+ non-digit characters
1+ digits - grouping 4 - observations
1 + non-digits
1+ digits - grouping 5 - variables
*/

output_pattern = prxparse('/NOTE:\s*(\b\D*)(\b\w*[a-z]\w*)\.(\w+\b)\D+(\d+)\D+(\d+)\D*/I');


end;


/* delete notes with irrelevant information about datasets that doesn't have to do with creating or editing them */

if prxmatch(nonnative_pattern,text) > 0 then delete;


/* if there is a WHERE condition associated with creating a dataset, then get that where condition 
and associate it with the correct input dataset */


retain ds_libname_input ds_name_input ds_fullname_input source_input "" nobs_log_input .;

input_check = prxmatch(input_pattern,text);

if input_check > 0 then do;
	ds_libname = prxposn(input_pattern,2,text);
	ds_name = prxposn(input_pattern,3,text);
	ds_fullname = catx(".",prxposn(input_pattern,2,text),prxposn(input_pattern,3,text));
	nobs_log = input(prxposn(input_pattern,1,text),12.);
	source = "LOG IN";
	purpose_output = 0;
	/* to add definition for the condition, which is in the next record */
	ds_libname_input = prxposn(input_pattern,2,text);
	ds_name_input = prxposn(input_pattern,3,text);
	ds_fullname_input = catx(".",prxposn(input_pattern,2,text),prxposn(input_pattern,3,text));
	nobs_log_input = input(prxposn(input_pattern,1,text),12.);
	source_input = "LOG IN";
end;

where_check = prxmatch(where_pattern,text);

if where_check > 0 and ds_name_input ne "" then do;
	input_condition = prxposn(where_pattern,1,text);
	ds_libname = ds_libname_input;
	ds_name = ds_name_input;
	ds_fullname = ds_fullname_input;
	source = source_input;
	nobs_log = nobs_log_input;
	purpose_output = 0;
end;

if where_check <= 0 and  input_check <= 0 and ds_libname_input ne "" then do;
	ds_libname_input = "";
	ds_name_input = "";
	ds_fullname_input = "";
	source_input = "";
	nobs_log_input = .;
end;

output_check = prxmatch(output_pattern,text);

if output_check > 0 then do;
	ds_libname = prxposn(output_pattern,2,text);
	ds_name = prxposn(output_pattern,3,text);
	ds_fullname = catx(".",prxposn(output_pattern,2,text),prxposn(output_pattern,3,text));
	nobs_log = input(prxposn(output_pattern,4,text),12.);
	nvars_log = input(prxposn(output_pattern,5,text),12.);
	purpose_output = 1;
	if lowcase(compress(prxposn(output_pattern,1,text)," "))="table" then source = "LOG SQL";
	else source = "LOG OUT";

end;

if ds_fullname ne "" or input_condition ne "";

keep text_from_notes source ds_libname ds_name ds_fullname nobs_log nvars_log input_condition log_line line_order origin_macro macro_name code;

if purpose_output = 1 then output notesoutput;
else if purpose_output = 0 then output notesinput;

run;



/* 
if an input dataset has a WHERE condition, it is currently mentioned on two consecutive lines 
 with the second line actually including the WHERE condition on the record 
 want to keep only that second record in those cases 
*/


proc sort data = notesinput;
by ds_fullname descending line_order;
run;


data notesinput;
set notesinput;
by ds_fullname descending line_order;

/* 
if next line (going by the order of notes from the log) has input_condition, 
and it's for the same dataset and using the same number of observations 
then delete current line
*/

next_line = lag(line_order);
next_inputcond = lag(input_condition);
next_nobs = lag(nobs_log);

if first.ds_fullname then do;
	next_line = .;
	next_inputcond = "";
	next_nobs = .;
end;

else if not first.ds_fullname then do;

	if input_condition = "" and next_inputcond ne "" and next_line = (line_order + 1) and next_nobs = nobs_log 
	then delete;

end;

drop next_line next_inputcond next_nobs;
run;



/* !!!!!! STEP 4: combine information from code and log notes 
(datasets from the pdsinfo macros if run within program excluded here 
if exclpdsinfo = 1)
*/


/* INPUT DATASETS */


data &indsname.&suffix.;
/* length text $2000; */
set &indsname.&suffix.
notesinput;
where lowcase(ds_name) ne "_null_" 
%if &exclpdsinfo. = 1 %then %do;
and lowcase(macro_name) not in ("pdsinfo","getdsnames","readin_log")
%end;
;

ds_fullname = upcase(ds_fullname); 
ds_name = upcase(ds_name); 
ds_libname = upcase(ds_libname);

if ds_libname = "WORK" and scan(ds_fullname,2,".") = "" then 
		ds_fullname = catx(".",ds_libname,ds_name);

/*
if code = 1 then text = text_from_code;
else if code = 0 then text = text_from_notes;
*/

logpath = "&logpath.";

drop text_from_code text_from_notes nvars_log;
run;



proc sort data = &indsname.&suffix.;
by ds_fullname descending line_order;
run;


data &indsname.&suffix.;
set &indsname.&suffix.;
by ds_fullname descending line_order;

/* 
if next line (going by the order of notes from the log) after a dataset is defined in the code 
there is a log note with nobs and nvars, then add those to the code record with the source of 
dataset
*/

next_line = lag(line_order);
next_code = lag(code);
next_nobs = lag(nobs_log);
next_inputcond = lag(input_condition);

if first.ds_fullname then do;
	next_line = .;
	lag_code = .;
	next_nobs = .;
	next_inputcond = "";
end;

else if not first.ds_fullname then do;

	if code = 1 and next_code = 0 and nobs_log = . and next_nobs ne . then do;
		nobs_log = next_nobs;
		input_condition = next_inputcond;
	end;

end;

drop next_line next_code next_nobs  next_inputcond;

run;


proc sort data = &indsname.&suffix.;
by ds_fullname line_order;
run;


/* 
delete the record from the log that was only there for the nobs and the nvars that we've already gotten 
but keep log lines that define data we didn't find in the code 
*/

data &indsname.&suffix.;
set &indsname.&suffix.;
by ds_fullname line_order;

lag_line = lag(line_order);
lag_code = lag(code);
lag_nobs = lag(nobs_log);
lag_inputcond = lag(input_condition);


if first.ds_fullname then do;
	lag_line = .;
	lag_code = .;
	lag_nobs = .;
	lag_inputcond = "";
end;

else if not first.ds_fullname then do;

	if code = 0 and lag_code = 1 and nobs_log = lag_nobs and input_condition = lag_inputcond then delete;

end;

drop lag_line lag_code lag_nobs lag_inputcond;

run;



/* OUTPUT DATASETS */


data &outdsname.&suffix.;
/* length text $2000; */
set &outdsname.&suffix. 
notesoutput;
where lowcase(ds_name) ne "_null_"
%if &exclpdsinfo. = 1 %then %do;
and lowcase(macro_name) not in ("pdsinfo","getdsnames","readin_log")
%end;
;

ds_fullname = upcase(ds_fullname); 
ds_name = upcase(ds_name); 
ds_libname = upcase(ds_libname);

if ds_libname = "WORK" and scan(ds_fullname,2,".") = "" then 
		ds_fullname = catx(".",ds_libname,ds_name);

/*
if code = 1 then text = text_from_code;
else if code = 0 then text = text_from_notes;
*/

logpath = "&logpath.";

drop input_condition text_from_code text_from_notes;

run;




proc sort data = &outdsname.&suffix.;
by ds_fullname descending line_order;
run;


data &outdsname.&suffix.;
set &outdsname.&suffix.;
by ds_fullname descending line_order;

/* 
if next line (going by the order of notes from the log) after a dataset is defined in the code 
there is a log note with nobs and nvars, then add those to the code record with the source of 
dataset
*/

next_line = lag(line_order);
next_code = lag(code);
next_nobs = lag(nobs_log);
next_nvars = lag(nvars_log);


if first.ds_fullname then do;
	next_line = .;
	lag_code = .;
	next_nobs = .;
	next_nvars = .;
end;

else if not first.ds_fullname then do;

	if code = 1 and next_code = 0 and nobs_log = . and (next_nobs ne . or next_nvars ne .) then do;
		nobs_log = next_nobs;
		nvars_log = next_nvars;
	end;

end;

drop next_line next_code next_nobs next_nvars;

run;


proc sort data = &outdsname.&suffix.;
by ds_fullname line_order;
run;


/* 
delete the record from the log that was only there for the nobs and the nvars that we've already gotten 
but keep log lines that define data we didn't find in the code 
*/

data &outdsname.&suffix.;
set &outdsname.&suffix.;
by ds_fullname line_order;

lag_line = lag(line_order);
lag_code = lag(code);
lag_nobs = lag(nobs_log);
lag_nvars = lag(nvars_log);


if first.ds_fullname then do;
	lag_line = .;
	lag_code = .;
	lag_nobs = .;
	lag_nvars = .;
end;

else if not first.ds_fullname then do;

	if code = 0 and lag_code = 1 and nobs_log = lag_nobs and nvars_log = lag_nvars then delete;

end;

drop lag_line lag_code lag_nobs lag_nvars;

run;



/* 
 create variable for whether a dataset was created in this program 
(ie, it was output before it was used as input)

*/


data cinprogram;
set &indsname.&suffix.(in=insets)
	&outdsname.&suffix.(in=outsets);

if outsets then inout = "OUTPUT";
else if insets then inout = "INPUT ";

run;


/* 
for datasets that were counted as both input and output 
(eg, datasets used in the proc sort statement without an out= dataset)
the input line would be first since INPUT comes before OUTPUT
in the sort
*/

proc sort data = cinprogram;
by ds_fullname line_order inout;
run;


data cinprogram;
set cinprogram;
by ds_fullname line_order inout;
if first.ds_fullname;

if inout = "OUTPUT" then created_in_program = 1;
else if inout = "INPUT " then created_in_program = 0;

keep ds_fullname created_in_program;

run;

data &outdsname.&suffix.;
merge  &outdsname.&suffix.(in=setlist) cinprogram;
by ds_fullname;
if setlist;
run;
%mend;

