/*The macro check if a SAS file exists in a directory
 Replace c:\test below with your own directory 
%fileexist(work,data)
*/
%macro fileexist(dir,file);
%global fexist;
%let fexist=N;
%local fname i memcnt rc;

 /** creates a fileref **/
 %let filerf=mydir;

 /** creates a libref **/
 %let librf=temp;

 /** Assigns the libref of temp to the directory you passed
     in **/
 %let lib=%sysfunc(libname(&librf,&dir));

 /** Assigns the fileref of mydir to the directory you
     passed in **/
 %let rc=%sysfunc(filename(filrf,&dir));

 /** Opens the directory to be read **/
 %let did=%sysfunc(dopen(&filrf));

 /** Opens the directory to be read **/
/* %let did=%sysfunc(dopen(&lib));*/
%put &did lib=&lib filrf=&filrf librf=&librf;
 /** Returns the number of members in the directory you
     passed in **/
 %let memcnt=%sysfunc(dnum(&did));
%if &memcnt>0 %then %do;
 %do i = 1 %to &memcnt;
  /** Return the extension of the dataset found **/
  %let lname=%upcase(%scan(%qsysfunc(dread(&did,&i)),2));
  /** Return the first name of the dataset found **/
  %let fname=%scan(%qsysfunc(dread(&did,&i)),1);
  /** Check to see if file has a dataset extension **/
  /** SAS7BDAT will need to be changed based on the **/
  /**  release you are running. **/
  %if &lname = SAS7BDAT %then %do;
  %if &file=&fname %then %let fexist=Y;
  %end;
 %end;
%end;
 /** Close the directory **/
 %let rc=%sysfunc(dclose(&did));

%mend fileexist;

