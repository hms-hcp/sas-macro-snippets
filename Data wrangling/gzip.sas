%macro gzip(lib,dsn,test=no);
%let obsn=%sysfunc(getoption(obs));
%if &obsn=0 %then %do;
  options obs=10000;
%end;
proc sql noprint;
    select 
      path into : fpath
    from 
      dictionary.members
     where
        libname="%upcase(&lib)";

 %let fpath=%qtrim(&fpath);

 %let exist=%sysfunc(exist(&lib..&dsn));

 filename gfile "&fpath/&dsn..sas7bdat.gz";

 %let fexist=%sysfunc(fexist(&gfile));

 %if &exist=1 & &fexist=0 %then %do;
   %if &test=no and &obsn^=0 %then %do;
    filename com pipe "gzip  &fpath./&dsn..sas7bdat";
    %let command=;
    data _null_;
    infile com firstobs=1 length=linelen;
    input var $1. @;
    input @1 errstat $varying200. linelen;
    errstat="ERROR: "!!errstat;
    put errstat= ;
    if errstat> " " then call symput("command","endsas;");
    run;
    &command
  %end;
  %else %put "No action was done: TESTING";
%end;
 %else %if &exist=0 & &fexist=1 %then %do;
  %put "The file &dsn..sas7bdat.gz is already in the library &lib. No action is done.";
 %end;
 %else %do;
 %if &exist=0 %then
 %put "The data &dsn..sas7bdat or the library &lib do not exist.";
 %else
 %put "The file &dsn..sas7bdat.gz is already in the library &lib.";
 endsas;
 %end;

%if &obsn=0 %then %do;
   options obs=0;
%end;

%mend gzip;
