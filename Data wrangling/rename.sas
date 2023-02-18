/*macro parameters:
  vars- the name of macro variable that has the common part of macro 
        variables names from macro variables list;
  num- the number of macro variables in the list*/
%macro rename(vars,num,extname=1);
%local i;
 %if &num^=none %then %do;
 %do i=1 %to &num;
       %str( &&&vars&i=&&&vars&i..&extname )
 %end;
 %end;
 %else %do;
 %let i=1;
 %do %while(%length(%scan("&&&vars",&i," "))>0);
%let nextvar=%trim(%scan("&&&vars",&i," "));
    %str(&nextvar=&nextvar.1 )
%let i=%eval(&i+1);
  %end;
 %end;
%mend rename;