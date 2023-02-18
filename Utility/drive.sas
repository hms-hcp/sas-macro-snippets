/*The macro prints all the SAS files that are in the directory
 Replace c:\test below with your own directory 
%drive(c:\test)
*/
%macro drive(dir);

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

 /** Returns the number of members in the directory you
     passed in **/
 %let memcnt=%sysfunc(dnum(&did));

 %let cnt=0;
 %do i = 1 %to &memcnt;
  /** Return the extension of the dataset found **/
  %let lname=%upcase(%scan(%qsysfunc(dread(&did,&i)),2));
  /** Return the first name of the dataset found **/
  %let fname=%scan(%qsysfunc(dread(&did,&i)),1);
  /** Check to see if file has a dataset extension **/
  /** SAS7BDAT will need to be changed based on the **/
  /**  release you are running. **/
  %if &lname = SAS7BDAT %then %do;
    %let cnt=%eval(&cnt+1);
    /** create a different macro variable for each dataset
        found **/
    %let name&cnt=&fname;
  %end;
 %end;

 %do j = 1 %to &cnt;
   proc print data=&librf..&&name&j;
   run;
 %end;

 /** Close the directory **/
 %let rc=%sysfunc(dclose(&did));

%mend drive;







 Search | Contact Us | Terms of Use & Legal Information | Privacy Statement
Copyright © 2005 SAS Institute Inc. All Rights Reserved. 
 