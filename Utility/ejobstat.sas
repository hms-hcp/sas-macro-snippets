%macro ejobstat(to=&sysuserid@med.harvard.edu,subject=Status of &sysprocessname);

%put ************ BEGIN macro ejobstat *************;  
 /*-----------------------------------------------*/
 /*                                               */
 /* NAME:  ejobstat                               */
 /*                                               */
 /* TYPE:  SAS MACRO                              */
 /*                                               */
 /* DESC:  Sends email giving status of job.      */
 /*                                               */    
 /* USAGE: At the end of a long SAS job.          */
 /*                                               */
 /*                                               */
 /* PARMS:                                        */
 /* --------    --------------------------------- */    
 /*  to      .. e-mail address for receipient     */
 /*  subject .. subject of e-mail                 */
 /*                                               */    
 /*============================================== */
 /* MODS: 05/02/01 - New (mr)                     */
 /*                                               */
 /*-----------------------------------------------*/

 /* TERM MACRO IF INPUTS NOT MET */    

 /* SETUP OR MODIFY DEFAULTS */    

     %let PROCESSNAME = %upcase(&sysprocessname);

    /* Find full name of current program */
     %NSOURCE;

    /* Assign mailbox */
    filename outbox email "&TO";

    %let cur_datetime = %sysfunc(datetime(),datetime19);
    
    data _null_;
     file outbox    
         subject= "&SUBJECT"
         ;
      put //;
      put "&PROCESSNAME finished with an exit return code of &syscc";
      put //;
      put "JOB SUBMITTED BY: &sysuserid";
      put "JOB ID WAS: &sysjobid";
      put "JOB SOURCE CODE IS: &NSOURCE";
      put /;
      put "JOB STARTED AT: &sysdate9. &systime";
      put "JOB ENDED AT: &cur_datetime";
      put /;
      put "LAST DATASET PROCESSED: &sysdsn";
      
    run;

 
%endmac:
%put ******** END macro ejobstat *********;     
%mend;







