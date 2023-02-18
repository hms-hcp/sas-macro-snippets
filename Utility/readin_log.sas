/*--------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA   |
|--------------------------------------------------------------------------|
| File Name      = readin_log.sas                                          |
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
   Macro to read in the log and output the code, notes and important 
comments in separate datasets

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
  Reads in the log and outputs the code, notes and important 
comments in separate (temporary) datasets named CODE, NOTES, and COMMENTS.

This macro is to be used in conjunction with future macros that will use these  
datasets to get important information from the log, such as the datasets 
and files defined and used in a program, and printing out important notes 
from the log.

Macros currently using this macro: %GETDSNAMES, %PDSINFO

PARAMETERS:

LOGPATH - the name and path of the log you want to read (default = blank)
LOGFILENAME - in run within a program, the filename of the log being run (default = blank)


NOTE: AT LEAST ONE OF THESE NEEDS TO BE DEFINED FOR THE MACRO TO RUN


*--------------------------------------------------------------------------*
| Instructions:                                                            |
|--------------------------------------------------------------------------|
 A typical call for the macro looks as follows: 

%readin_log(logpath=&logpath.,logfilename=&logfilename.);

(where &logpath and/or &logfilename were defined at some previous time)



*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Macro Code Begins Here.                                                  |
*--------------------------------------------------------------------------*; */




%macro readin_log(logpath=,logfilename=);


/* Reads in and formats SAS log */


data  code notes comments;
length log_line 8 text_orig $500  text text_unwrap $2000 text_wrapcom text_wrapcode $500 macro_name_orig macro_name $35 origin_macro 3 line_order 8;
%if %length(&logfilename)>0 %then %do;
  infile &logfilename lrecl=500 length=linelength truncover;
%end;
%else %do;
  infile "&logpath" lrecl=500 length=linelength truncover;
%end;  
  input text $varying500. linelength;


/* variable to keep track of changes and check that they work correctly */

text_orig = text;


/* STEP 1: define patterns for regular expressions */

retain macro_pattern mend_pattern 
kcomment_pattern 
pbr_pattern  
code_pattern mprint_pattern 
slcomment_pattern 
code_blank trim_linestart ;

if _n_ = 1 then do;


/* check for macros. Using regular expression because I want it case-insensitive */

macro_pattern = prxparse('/%macro\s/I');
mend_pattern = prxparse('/%mend/I');


/* pattern for the important comments that we want to keep
so we can use them for documentation later 

pattern matches: [slash]* 0+ spaces 5+ @ symbols

*/

kcomment_pattern = prxparse('#/\*\s*!{5,}#');


/* pattern for page breaks to fix the fact that Windows and unix 
SAS have different page break characters 

matches 1+ digits 1+ spaces The SAS System 1+ spaces dd:dd

*/

pbr_pattern = prxparse('/\d+\s+The\sSAS\sSystem\s+\d\d:\d\d/');



/* 
pattern for beginning of non-macro code vs mprint or warnings in log 
 matches a number plus spaces in the beginning of the line 
*/

code_pattern = prxparse('/^(\d+)\s*/');


/* 
pattern for the mprint start of line 
separate from the non-macro code start of line 
matches MPRINT([word]) plus spaces in the beginning 
of the line
*/

mprint_pattern = prxparse('/^MPRINT\((\w+)\):\s*/');


/* get pattern for comments of the type [slash]* on the 
same line so we can delete them 

regex pattern matches these kinds of comments and anything inside */

slcomment_pattern=prxparse('s#/\*.*\*/# #');


/* identify blank lines in code (with code line number) because they can mess up code */

code_blank = prxparse('/(^\d+)\s*$/I');


/* for clauses that span several lines, replace log line start */
/* (ie, code line number or MPRINT[MACRO]) for the wrapped lines with blanks */
/* before setting them together into one clause*/
/* regex pattern with line number or MPRINT[MACRO] defined here*/ 

trim_linestart = prxparse('s/^(\d+(\s*!)?|MPRINT\(\w+\):)\s+/ /');

end;



/* !!!!!! STEP 2: delete page breaks and other lines that break the code */

if prxmatch(pbr_pattern,text) > 0 then delete;


/* 
delete invalid data printed to the log, because the start of the line looks like code but isn't, 
and it's messing things up 

keep the note in, so you know the data is invalid and can look at it later
*/

retain delete_invalid_data 0; 

if index(text,"NOTE: Invalid data") > 0 or index(text,"WARNING: Limit set by ERRORS") > 0 
	then delete_invalid_data = 1;
if delete_invalid_data = 1 and index(text,"NOTE: Invalid data") <= 0 and index(text,"WARNING: Limit set by ERRORS") <= 0 
	then delete_invalid_data = 2;
if delete_invalid_data > 0 and index(text,"NOTE: Invalid data") <= 0 and index(text,"WARNING: Limit set by ERRORS") <= 0  
and index(text,"NOTE:") > 0 
	then delete_invalid_data = 0;

if delete_invalid_data = 2 then delete;


/* !!!!!! STEP 3: Put important comments marked with !!!!! in a separate file */


retain keep_impcomments 0;

if prxmatch(kcomment_pattern,text) > 0 then keep_impcomments = 1;
if keep_impcomments = 1 and (index(text,"*/") > 0) then keep_impcomments = 2;
if keep_impcomments = 2 and prxmatch(kcomment_pattern,text) <= 0 and index(text,"*/") <= 0 
		then  keep_impcomments = 0;

if keep_impcomments > 0 then output comments;

/* 
output the line with macro definitions to the comments file as well, so we can keep track 
of where the comments came from
*/



if index(text,"put") <= 0 and index(text,"prxparse") <= 0 and index(text,"prxmatch") <= 0 
	and index(text,"prxchange") <= 0 and index(text,'%nrstr') <= 0 
	and index(text,"index") <= 0 
and (prxmatch(macro_pattern,text) > 0 or prxmatch(mend_pattern,text) > 0) then output comments;


/* !!!!!! STEP 4: delete the rest of the comments of the form [slash]* for now  
(might try to do something else with them in a future version) */


/* replaces comments on one line with a space so any code they are mixed with would be safe */

call prxchange(slcomment_pattern,-1,text);


/*  this means that if we later decide to do something more with comments 
	any comments on one line would be 



/* if there is a comment at the beginning or end of the line
with other code on the same line  
then wrap it to the next line so we can delete the comment but not the rest */

call prxsubstr(trim_linestart,text,codestart,codestlength);
*call prxsubstr(mprint_pattern,text,mprintstart,mprintlength);

retain text_wrapcom;

if codestart > 0  then do;
codestend = (codestart+codestlength);

	/* exclude statements with put statements and regex definitions 
        and index functions from the potential lines to wrap 
		because they might have comment symbols inside quotes  */


	if index(text,"put") <= 0 and index(text,"prxparse") <= 0 and index(text,"prxmatch") <= 0 
	and index(text,"prxchange") <= 0 and index(text,'%nrstr') <= 0 
	and index(text,"index") <= 0 
	and index(text,"/*") > max(1,codestend) then do;

		end_length = (length(text) - index(text,"/*"))+1;
		text_wrapcom = cat(substr(text,codestart,codestlength),substr(text,(index(text,"/*")),end_length));
		text = substr(text,1,(index(text,"/*")-1));
		output code;
		text = text_wrapcom;

	end;
	else text_wrapcom = "";



	if index(text,"put") <= 0 and index(text,"prxparse") <= 0 and index(text,"prxmatch") <= 0  
	and index(text,"prxchange") <= 0 and index(text,'%nrstr') <= 0 
	and index(text,"index") <= 0 
    and prxmatch('#\*/\s*\S#',text) > 0 then do;

	/* regex pattern matches end of comment, with at least one non-whitespace character */

		end_length = length(text) - index(text,"*/");
		text_wrapcom = cat(substr(text,codestart,codestlength),substr(text,(index(text,"*/")+2),end_length));
		text = substr(text,1,(index(text,"*/")+2));
		output code;
		text = text_wrapcom;

	end;
	else text_wrapcom = "";

end;




/* now that there are no lines with code and comments on one line, delete [slash]* comments on many lines */

retain  delete_comment1 0;


if  index(text,"put") <= 0 and index(text,"prxparse") <= 0 and index(text,"prxmatch") <= 0 
and index(text,"prxchange") <= 0 and index(text,'%nrstr') <= 0 
and index(text,"index") <= 0 
and index(text,"/*") > 0 then delete_comment1 = 1;

if delete_comment1 = 1 and index(text,"*/") > 0 then delete_comment1 = 2;
if delete_comment1 = 2 and index(text,"/*") <= 0 and index(text,"*/") <= 0 then delete_comment1 = 0;

 if delete_comment1 then delete; 




/* !!!!!! STEP 5: make certain code is properly read in with each statement ending with ; on one line */


/* define codestart each time we need it, in case there are changes in the text from all the wrapping */

call prxsubstr(trim_linestart,text,codestart,codestlength);

  /* if there is more than one statement on one line, put them into different lines */

retain text_wrapcode "";


if (codestart > 0) then do;
	do while (countc(text,";") > 1);
		length_remain = (length(text) - index(text,";"))+1;
		text_wrapcode = cat(substr(text,codestart,codestlength),substr(text,index(text,";")+1,length_remain));
		text = substr(text,1,index(text,";")+1);
		output code;
		text = text_wrapcode;
	end;
	if countc(text,";") <= 1 then text_wrapcode = "";
end;



/* if statement was so long that it was wrapped in log or program CODE, combine it back together into one clause */


/* define codestart each time we need it, in case there are changes in the text from all the wrapping */

call prxsubstr(trim_linestart,text,codestart,codestlength);

retain text_unwrap "";
retain delete_wrap 0;


if (codestart > 0) and prxmatch(code_blank,text) = 0 then do;
	if index(text,";") = 0 and text_unwrap = "" then do;
		wrap_1st = 1;
		text_unwrap = text;
		delete_wrap = 1;
	end;
end;


if text_unwrap ne "" and wrap_1st ne 1 and index(text_unwrap ,";") = 0 then do;

	/* 	 remove log line start characters before setting the lines back together 	*/

    call prxchange(trim_linestart,-1,text);
	text_unwrap = trim(catx(" ",text_unwrap ,text));
 
	delete_wrap = 1;
end;

if index(text_unwrap ,";") > 0 or length(text_unwrap) > 1850 then do;
	text = text_unwrap ;
	text_unwrap = "";
	delete_wrap = 0;
end;

  if delete_wrap = 1 then delete; 



  /* !!!!!! STEP 6: Specify to which line of log/macro the program notes and code refer */


retain macro_name "";
retain log_line  0;


codecheck = prxmatch(code_pattern,text);
if code_pattern > 0 then log_line_orig = input(prxposn(code_pattern,1,text),12.);

if log_line_orig ne . then log_line = log_line_orig;


mprintcheck = prxmatch(mprint_pattern,text);
if mprintcheck > 0 then do;
	macro_name_orig = prxposn(mprint_pattern,1,text);
end;
else if code_pattern > 0 and mprintcheck <= 0 then do;
	macro_name_orig = prxposn(code_pattern,1,text);
end;

if macro_name_orig ne "" then macro_name = macro_name_orig;





retain line_order 0;

line_order = line_order + 1;


/* define whether the code comes from a macro or a non-macro step */
/* done at the end, to take into account wrapping and unwrapping lines */

origin_macro = (macro_name ne "" and macro_name ne input(log_line,$30.));


/* define codestart each time we need it, in case there are changes in the text from all the wrapping */

call prxsubstr(trim_linestart,text,codestart,codestlength);


drop trim_linestart kcomment_pattern;
keep  log_line text text_orig macro_name origin_macro line_order; 


if (codestart > 0) then output code;
else output notes;

run;


/* !!!!!! STEP 7: Now that we've made sure that all the lines are assigned to 
code and notes  correctly, it's easier to work with these datasets 
separately. First, the code. */


data code;
set code;


/* get back patterns that are still needed */

retain trim_linestart 
astcomment_pattern 
macro_pattern mend_pattern 
let_pattern mvar_pattern;

if _n_ = 1 then do;

/* for clauses that span several lines, replace log line start */
/* (ie, code line number or MPRINT[MACRO]) for the wrapped lines with blanks */
/* before setting them together into one clause*/
/* 
regex pattern with line number (possibly with ! added on wrapping lines) 
or MPRINT[MACRO] defined here
*/ 

trim_linestart = prxparse('s/^(\d+(\s*!)?|MPRINT\(\w+\):)\s+/ /');


/* 
get pattern for comments of the type *; on the 
same line so we can delete them 

regex pattern matches these kinds of comments and anything inside 
*/

astcomment_pattern=prxparse('s/^\s*(\*.*;)/ /');


/*
No longer need such a complicated pattern after trimming out the log 
line starting characters from the code but I'm keeping the original
pattern in case I need it for something later

regex pattern matches these kinds of comments and anything inside 
but only if they start in the beginning of the line 
(ie, right after the start of code characters)

The replace option (indicated by the first s before the pattern) 
replaces the comment with just the start of code characters

astcomment_pattern=prxparse('s/(^\d+\s*|^MPRINT\(\w+\):\s+|^\s*)(\*.*;)/$1/');
*/


/* check for macros. Using regular expression because I want it case-insensitive */

macro_pattern = prxparse('/(^\s*)(%macro)/I');
mend_pattern = prxparse('/(^\s*)(%mend)/I');


/* check for macro variable definition using the %let statement*/

let_pattern = prxparse('/%let\s+(\w+)\s*=\s*(.*);/I');


/* check for macro variable being used */

mvar_pattern = prxparse('/(&+\w+\.*)/');

end;


/* 
trim out line starting characters from code 
(we've taken out all the information we need from that 
already)
*/

call prxchange(trim_linestart,-1,text); 

/* !!!!!! STEP 8: now that the code is regularized, can delete the other type of comments from code*/

/* deletes comments of the form *; that start right after the start of line */

call prxchange(astcomment_pattern,-1,text);



/* !!!!!! STEP 9: delete code defining macros */


retain delete_macro macro_number mend_number 0;

/* define macros to delete */

macrostart = prxmatch(macro_pattern,text);
mendstart = prxmatch(mend_pattern,text);


if macrostart > 0 and index(text,'%nrstr') <= 0 then do;
	macro_number = macro_number + 1;
	delete_macro = 1;
end;

if macro_number >= 1  and  mendstart > 0 and index(text,'%nrstr') <= 0  then mend_number = mend_number + 1;

if macro_number = mend_number and macrostart <= 0 and mendstart <= 0 then delete_macro = 0;


  if delete_macro then delete; 


/* !!!!!! STEP 10: replace macro variables in code with their assigned values 
 from the %let statement  - SKIP THIS STEP FOR NOW*/

 /* Can't get this to work yet - will try later 

 letcheck = prxmatch(let_pattern,text);

 if letcheck > 0 then do;
	mname = prxposn(let_pattern,1,text);
	mval = prxposn(let_pattern,2,text);
	call symput(mname,mval);
 end;

mvarcheck = prxmatch(mvar_pattern,text);

if mvarcheck > 0 then do;
mvar_used = prxposn(mvar_pattern,1,text);
end;
*/


 keep log_line text_orig text macro_name origin_macro line_order; 

run;


/* 
!!!!!! STEP 11: If there are important comments, format them and make certain they are matched with the correct 
macros

NOTE: NESTED MACRO DEFINITIONS WILL LEAD TO COMMENTS BEING ASSOCIATED WITH THE WRONG MACRO

*/

/*
proc sql noprint;

select count(*) into :numcomments 
from comments 
where index(lowcase(text),'macro') <= 0 and index(lowcase(text),'mend') <= 0;

quit;
*/

/*
data comments;
set comments;
retain numcomments 0;
numcomments = 0;
if index(lowcase(text),'macro') <= 0 and index(lowcase(text),'mend') <= 0 then numcomments = numcomments + 1;
call symput('numcomments',left(compress(numcomments)));
run;
*/



data comments(keep=text macro_number mend_number line_order log_line) 
mnames(keep=macro_name macro_number);
length macro_name $35;
set comments(drop=macro_name origin_macro);

retain kcomment_pattern trim_linestart mtitle_pattern mend_pattern;

if _n_ = 1 then do;


/* delete the comment symbols so we are left with just text

pattern matches: [slash]* 0+ spaces 5+ @ symbols or *[slash]
*/

kcomment_pattern = prxparse('s#/\*\s*!{5,}|\*/##');


/* for clauses that span several lines, replace log line start */
/* (ie, code line number or MPRINT[MACRO]) for the wrapped lines with blanks */
/* before setting them together into one clause*/
/* regex pattern with line number or MPRINT[MACRO] defined here*/ 

trim_linestart = prxparse('s/^(\d+(\s*!)?|MPRINT\(\w+\):)\s+/ /');


/* get the macro definition 

pattern matches: macro 1+ spaces word[end word]
*/

mtitle_pattern = prxparse('/%macro\s+(\w*\b)/i');
mend_pattern = prxparse('/%mend/');

end;


/* delete code start of line from the log */

call prxchange(trim_linestart,-1,text);


/* delete comment symbols */

call prxchange(kcomment_pattern,-1,text);


retain macro_number mend_number 0; 


macrostart = prxmatch(mtitle_pattern,text);
mendstart =  prxmatch(mend_pattern,text);

if macrostart > 0 then do;
	macro_number = macro_number + 1;
	macro_name = upcase(prxposn(mtitle_pattern,1,text));
	output mnames;
	delete;
end;


if macro_number >= 1  and  index(text,'index') <= 0 and index(text,'%nrstr') <= 0 
and mendstart > 0 then do;
	mend_number = mend_number + 1;
	delete;
end;


output comments;

run;


data comments;
merge comments(in=com) mnames(in=mn);
by macro_number;
if com;
run;


%mend;

