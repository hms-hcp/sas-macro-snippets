%macro MACRAN(macname,result=macran,libref=WORK,verbose=N);

%put ************ BEGIN macro MACRAN *************;  
 /*-----------------------------------------------*/
 /*                                               */
 /* NAME:  MACRAN                                 */
 /*                                               */
 /* TYPE:  SAS MACRO                              */
 /*                                               */
 /* DESC:  Verifies if a SAS macro has run        */
 /*        during current SAS session             */
 /*                                               */
 /*                                               */
 /* USAGE: Between SAS steps                      */    
 /*                                               */
 /* PARMS:        DESCRIPTION                     */
 /* --------      ------------------------------- */    
 /*  macname ...  name of macro to check          */
 /*  result  ...  name of macro parm to store     */
 /*               result (default=macran)         */
 /*               which is either null or the name*/
 /*               of the macro                    */    
 /*  libref  ...  name of libref associated with  */
 /*               catalogs to search for macros   */
 /*               (default=WORK)                  */
 /* verobse  ...  print extra information to log  */
 /*               (default=N)                     */     
 /*                                               */         
 /*============================================== */
 /* MODS: 04/24/02 - New (mbr)                    */
 /*                                               */
 /*-----------------------------------------------*/

 /* TERM MACRO IF INPUTS NOT MET */    
  %if %length(&macname) = 0 %then %do;
     %put ************* Macro Error Report **************;
     %put ---> Input parm requirements not meet.     <---;
     %put ***********************************************;
     data _null_;
        ERROR  'macro name parm ... macname ... is null';
        abort return;
      run;
  %end;

 /* SETUP OR MODIFY DEFAULTS */    
  %let macname  = %upcase(&macname);
  %let result = %upcase(&result);
  %let libref = %upcase(&libref);
  %let verbose = %upcase(&verbose);
 
 /* QUERY FOR MACNAME */
   %global &result;
   %local _tmp;
   proc sql noprint;
      select objname into :&&result
          from dictionary.catalogs
          where objname = "&macname" and objtype = 'MACRO' and libname in ("&libref")
      ;
   quit;
   %if &verbose ne N %then %do;     
     %put The value of parm &result, which tests whether macro &macname has run, is &&&result ;
   %end;

      
 
%endmac:
%put ******** END macro MACRAN *********;     
%mend;













































