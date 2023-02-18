*--------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA   |
|--------------------------------------------------------------------------|
| File Name      = bdt.sas                                          |
| Path or URL    = /usr/apps/sas/maclib/                                   |
| Version        = 1                                                       |
| Creation Date  = 06 11 2008                                              |
| Author         = Rita Volya using the code from Marcelo Coca             |
| Affiliation    = HCP                                                     |
| Category       = Statistics                                                 |
| Keys           =                                                         |
|                                                                          |
|--------------------------------------------------------------------------|
| Brief Description: Bootstrapped decision tree is an itterative process   |
| for selection of a smaller set of most influencial variables from a list |
| of all candidate variables                                               |
|--------------------------------------------------------------------------|
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
|--------------------------------------------------------------------------|;
/*The Bootstrapped Decision Tree process selects candidates for subsequent 
modeling by identifying variables consistently appearing at the top of 
decision trees. As only numeric variables are supported by the FASTCLUS 
procedure used in this macro, character variables must be converted to a 
numeric format before running the process. This process identifies only 
identifies candidates for subsequent modeling and should not be used to as a 
final step in variable selection. The technique is most effective when used to 
reduce a large number of possible fields hundreds or more to a few dozen 
candidate variables. 
 

This non-parametric unsupervised learning process supports identification of 
preferred candidate variables for many different types of models. This decision
tree process addresses highly correlated variables by testing them directly 
against other. 

A TYPICAL IMPLEMENTATION OF THE BOOTSTRAP DECISION TREE PROCESS 

Here is a typical implementation of the process, with operational 
recommendations: 

* Run a sample with just a few repetitions as a test (in this example, 10); 

%bdt(projlib,customers,12,10); 
 

* Write the log to a file to avoid filling the log buffer during bootstrapping; 

PROC PRINTTO LOG='V:\Whirlpool\Models\Segmentation\bootstrap_log.log' NEW; 

RUN; 

* Final run using a large number of repetitions (in this example, 10,000); 

%bdt(projlib,customers,12,10000); 

proc printo; Turn off PROC PRINTTO, restoring the log to the usual location ; 

run; 
Parameters:

lib- SAS library
file - name of the data with all the candidate variables
varnum- number of variables randomly selected from the full list at each step
rep- number of iterations for bootstrap
Output: temporary data var_votes that has one variable variable_name. The values
of this variable are the names of the variable selected by proc fasclust during
a single bootsrap step. The freqency with which a variable is included in the 
var_votes data is indicative of how influencial the variable is.
Please reffer to a presentation for programmers at the meeting on January 7 2013
for more information 
*/

%macro BDT(lib,file,varnum,rep); 

proc contents data=&lib..&file. 

 out=work.vars(keep=name type) noprint; 

run; 
 

data work.vars; 

 set work.vars; 

 rename name = variable_name; 

 if type = 1; /* Numeric variables only */; 

 vote_count = 0; 

run; 

 

data work.var_votes; 

 set work.vars; 

 if _n_ < 1; 

 keep variable_name; 

run; 

 

%do i = 1 %to &rep.; 

 data work.var_list; 

 set work.vars; 

 random = ranuni(0); 

 run; 

 proc sort data=work.var_list; 

 by random; 

 run; 

 

 data work.test_list; 

 set work.var_list (obs=&varnum. keep=variable_name); 

 run; 

 

 data _null_; 

 length allvars $1000; 

 retain allvars ' '; 

 set work.test_list end=eof; 

 allvars = trim(left(allvars))||' '||left(variable_name); 

 if eof then call symput('varlist', allvars); 

 run; 

 %put &varlist; 

 

 proc fastclus data=&lib..&file. maxclusters=2 

 outstat=work.cluster_stat noprint; 

 var &varlist; 

 run; 

proc print data=cluster_stat; 

 data work.rsq; 

 set work.cluster_stat; 

 if _type_ = 'RSQ'; 
 drop _type_ cluster over_all; 
 run; 

 
 proc transpose data=work.rsq out=work.rsq2; 
 run; 

proc print;
run;


 data work.rsq2; 
 set work.rsq2; 
 length variable_name $32.; 
 variable_name = _name_; 
 run; 


 proc sort data=work.rsq2; 
 by descending col1; 
 run; 

 data work.var_votes; 
 set work.var_votes work.rsq2(obs=1); 
 run; 

proc freq order=freq;
tables variable_name;
run;

%end; 
 

%mend BDT; 




 
