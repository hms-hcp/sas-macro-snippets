%macro contprint(dsn=,obs=5);
 /*-----------------------------------------------*/
 /*                                               */
 /* NAME:  contprint                              */
 /*                                               */
 /* TYPE:  SAS MACRO                              */
 /*                                               */
 /* DESC:  Proc contents and print of x obs       */
 /*        of named dataset                       */
 /*                                               */
 /*                                               */
 /* USAGE: Between SAS steps (or w/in Data|Proc)  */    
 /*                                               */
 /* PARMS:                                        */
 /* --------    --------------------------------- */    
 /*  dsn        One or two level SAS Dataset      */
 /*                                               */    
 /*============================================== */
 /* MODS: mm/dd/yy - New (initials)               */
 /*                                               */
 /*-----------------------------------------------*/
 proc contents data=&dsn ;  run;
 title1 "&obs of &dsn";
 proc print data=&dsn (obs=&obs) label; run;
%mend contprint;
