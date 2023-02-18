%macro swell(nam);
    data _null_;
    call symput('dir',pathname(scan("&nam",1,'.')));
    call symput('dset',scan("&nam",2,'.'));
    run;
    filename unc pipe "gunzip &dir./&dset..sas7bdat.gz";
    data _null_;
    infile unc firstobs=2 length=linelen;
    input var $1. @ ;
    input @1 errstat $varying200. linelen;
    errstat='ERROR: '||errstat;
    put errstat;
    run;
%mend swell;
    
