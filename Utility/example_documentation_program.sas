/********************************************************************

EXAMPLE CODE TO AUTOMATICALLY CREATE DOCUMENTATION
FROM PROGRAM LIST

Author: Katya Zelevinsky

**********************************************************************/
*------------------ SET NAMES OF PATHS AND FILES ---------------------;


/* path to documentation macros - don't forget the final / */

%let docpath = /disk/agedisk2/medicare.work/chernew-DUA26659/zelevins/documentation/bevacizumab/;

/* path to the folder with the programs */

%let ppath = /disk/agedisk2/medicare.work/chernew-DUA26659/zelevins/;

%let txtproglist = &docpath.example_program_list.txt;
%let docfile = &docpath.example_documentation.doc;


*--------------------- START CODE -------------------------------------;


/* Include the documentation macros (or could use SAS autocall if it's set up properly) */

%include 
"/disk/agedisk2/medicare.work/chernew-DUA26659/zelevins/documentation_macros.sas"; 

options mprint nocenter ls = 180;


/* Regular expression to replace numeric year reference to [year]
in the dataset names */

%macro regex_repyear;
retain yrpat;
if _n_ = 1 then do;
yrpat = prxparse('s/(\w+)(20\d\d)(w+)?/$1[YEAR]$3 /');
end;
call prxchange(yrpat,-1,ds_fullname);
%mend;


/* From a program path and name, get dataset names, 
process them, and print them to documentation file */ 

%macro printsumm(path,pname);

/* Run macro to get lists of datasets */

%let lpath = &path.&pname..log;
%getdsnames(&lpath,logfilename=,
			indsname=indata,
			outdsname=outdata,
			commentname=,
			suffix=,exclpdsinfo=1);


/* Merge lists together to make sure we 
don't repeat datasets in lists */


proc sort data = indata 
		out = indata_dlist(keep = ds_fullname) 
		nodupkey;
by ds_fullname;
where upcase(DS_libname) ne "WORK" and 
	  upcase(ds_fullname) ne "MEDICARE.WORK";
run;

proc sort data = outdata 
		out = outdata_dlist(keep = ds_fullname 
                           created_in_program) 
		nodupkey;
by ds_fullname;
where upcase(DS_libname) ne "WORK";
run;

data dlist dsets_used dsets_edited dsets_created;
merge indata_dlist (in=inlist) outdata_dlist(in=outlist);
by ds_fullname;

output dlist;
if inlist and not outlist then 
		output dsets_used;
else if outlist and  created_in_program = 0 then 
		output dsets_edited;
else if outlist and  created_in_program = 1 then 
		output dsets_created;

run;

/* Use regular expression to replace 
numeric year references with [year] */

data dsets_used;
set dsets_used;
%regex_repyear;
run;

data dsets_edited;
set dsets_edited;
%regex_repyear;
run;

data dsets_created;
set dsets_created;
%regex_repyear;
run;

/* write the name of the program into
the rtf output file */

ods rtf text=" ";
ods rtf text = "^S={fontweight=bold fontsize=10pt}&pname..sas";

/* write the processed datasets into
the rtf output file */

proc sql;

select distinct ds_fullname 
	label = "Datasets used but not edited:" 
	from dsets_used;

select distinct ds_fullname 
	label = "Datasets edited:" 
	from dsets_edited;

select distinct ds_fullname label = "Datasets created in program:" 
from dsets_created;

quit;

%mend;

ods listing close;
title " ";

ods rtf style = journal 
file = "&docfile" 
startpage = no;

ODS ESCAPECHAR='^'; 

data _null_;
infile "&txtproglist" lrecl=500 length=linelength truncover;
input text $varying500. linelength;  
if compress(text)="" then delete;

/* define step number variable */

retain step 1;
if lowcase(scan(lag(text),2,'.')) in ("sas","r") and 
	lowcase(scan(text,2,'.')) not in ("sas","r") then do;
		step = step + 1;
end;

/* with each new step, include a break in the text */

if lag(step) ne . and lag(step) < step then do;
	call execute('ods rtf text = " ";');
	call execute('ods rtf text = " ";');
	call execute('ods rtf text = " ";');
end;


/* if the read in line is the name of a SAS program, 
run the macro to print the datasets */

if lowcase(scan(text,2,'.')) = "sas" then do;
	call execute(cats('%printsumm(%str(&ppath.),%str(',
					    scan(text,1,'.'),
						'));'));
end;

else if lowcase(scan(text,2,'.')) not in ("sas") then do;
	call execute(cats('ods rtf text = "^S={fontweight=bold fontsize=12pt}',
					   text,
					   '";'));
	call execute('ods rtf text = " ";');
end;

run;

ods rtf close;
ods listing;  
