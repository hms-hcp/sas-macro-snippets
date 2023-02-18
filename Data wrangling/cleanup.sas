%macro cleanup(library=work,dsn=);
 proc datasets library=&library nolist;
 delete &dsn;
run;
%mend cleanup;
