/*macro VARLIST creates global macro variable with the names of the variables
   in an input data as their values. The names of macro variables created
   have a common part which is supplied by a macro call through the parameter
   VAR and each name ends with a number. If &attrib=yes it also creates two
   corresponding sets of global macro variables which have the length and 
 type
   attributes of the variables from the list: &lng1-...-&lngn;
   &type1-...-&typen, where the first set of variables has the lenght of the
   corresponding variable in the data set as it's value; the second set of
   variables has the type of the variable as it's value. The list of the
   variables has to be supplied to the macro through the parameters LISTNUM
   and LISTNAME
Macro parameters:
  datain- input data;
  listnum- number of lists with variable names;
  listname- the common part of the name of macro variables
            with the lists of variable names. Ex.:if you supply keep
   there should be &keep1 , %keep2,..., &&keep&listnum macro variables 
defined
  var - the name that will be used to define macro variables that
      contain the names of the variables from the supplyed list
  vnum-the macro variable name that will contain the number of created
       macro variables &var1,....&&var&vnum.
  libin-name of data library
attrib=yes or no. No by default. If Yes there is a request for the length
and type attributes of the variables.

Example of the macro call:
  %let list=age sex .........;
  %varlist(mydata,1,keep,vname,v_num,attrib=yes)
*/

%macro varlist(datain,listnum,lstname,var,vnum,libin=,attrib=no);

%local i;

proc contents data=&libin.&datain(keep=
                             %if &listnum=1 %then %str(&&&lstname);
                             %else %do;
                                %do i=1 %to &listnum;
                                %str(&&&lstname&i )
                                %end;
                             %end;)
    out=cont position noprint;
run;

%global &vnum;

%count_n(cont)

%let &vnum=&n_obs;

%do i=1 %to &&&vnum;
    %global &var&i;
    %if &attrib=yes %then %do;
        %global type&i;
        %global lng&i;
    %end;
%end;

data _null_;
set cont end=eof;
retain v_num 0;
v_num=v_num+1;
call symput("&var"||put(left(v_num),3.),name);
%if &attrib=yes %then %do;
     call symput("lng"||put(left(v_num),3.),length);
     call symput("type"||put(left(v_num),3.),type);
%end;
run;

%do i=1 %to &&&vnum;
%let var&i=&&var&i;
%put &&&var&i;
%end;

%mend varlist;


