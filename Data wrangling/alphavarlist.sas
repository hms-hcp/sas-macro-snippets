/*macro ALPHAVARLIST creates global macro variables with the names of the 
  variables in an input data as their values, their lengths, types and labels.
  The names of variables are stored in macro variable VARNAMES 
   If &attrib=yes it also creates three
   corresponding global macro variables which have the length and 
 type attributes and labels of the variables from the list: &lengths, &types, 
  &labels;
   where the first variable has the lenghts of the
   corresponding variables in the data set as it's value; the second variable
    has the type of the variable as it's value. The list of the
   variables comes from a dataset. There is a parameter dropvars  taht you can
   use to drop some of the variables from the list
Macro parameters:
  datain- input data;
  varnames- to keep dataset variables
  types- to keep variables types
  lengths- to keep variables lengths
   labels- to keep variables labels
  attribute=yes will ensure that types and lengths are created
  droplist- list that variables from the data that you would like to be droped
  libin-name of data library

Example of the macro call:
  %let droped=age sex .........;
  %alphavarlist(mydata,vars,lng,type,label,droped,attrib=yes)
*/

%macro alphavarlist(datain,varnames,lengths,labels,droplist,drop=yes,attrib=no,libin=);

%local i;

proc contents data=&libin.&datain(%if &drop=yes %then %str(drop=&&&droplist);
                                    %else %str(keep=&&&droplist);)
    out=cont position noprint;
run;
data cont;
set cont;
keep name length label;
if label="" then label="NOLABEL";
if type="2";
run;
proc print data=cont(keep=name length label);
run;

%count_n(cont)

%let vnum=&n_obs;
%global &varnames &labels &lengths;
%if &attrib=yes %then %do;
proc sql;
select name,  length, label
    into  :&varnames separated by " "
         ,:&lengths  separated by " "
         ,:&labels separated by "^"
from cont;
%put "names:" &&&varnames;
%put "lengths: " &&&lngs;
%put "labels: " &&&labels;
%end;
%else %do;
proc sql;
select name,  length, label
    into  :&varnames separated by " "
from cont;
%put "names:" &&&varnames;
%end;
%mend alphavarlist;


