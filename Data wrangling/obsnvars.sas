%macro obsnvars(ds,allvars=Y);
%global dset exist;
%if &allvars=Y %then %do;
%global nvars nobs ;
%end;
%let exist=N; %let nobs=0;
%let dset=&ds;
%let dsid = %sysfunc(open(&dset));
%if &dsid %then
%do;
   %let exist=Y;
   %if &allvars=Y %then %do;
   %let nobs =%sysfunc(attrn(&dsid,NOBS));
   %let nvars=%sysfunc(attrn(&dsid,NVARS));
   %let rc = %sysfunc(close(&dsid));
   %end;
%end;
/*%else
   %put Open for data set &dset failed          - %sysfunc(sysmsg());*/
%put &exist  ;
%mend obsnvars;
                                                                                        
