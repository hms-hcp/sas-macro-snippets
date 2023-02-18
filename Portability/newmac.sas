%macro NEWMAC(parm1=xyz,parm2=);

%put ************ BEGIN macro NEWMAC *************;  
 /*-----------------------------------------------*/
 /*                                               */
 /* NAME:  NEWMAC                                 */
 /*                                               */
 /* TYPE:  SAS MACRO                              */
 /*                                               */
 /* DESC:                                         */
 /*                                               */
 /*                                               */
 /* USAGE: Between SAS steps (or w/in Data|Proc)  */    
 /*                                               */
 /* PARMS:                                        */
 /* --------    --------------------------------- */    
 /*  parm1  ...                                   */
 /*  parm2  ...                                   */
 /*                                               */    
 /*============================================== */
 /* MODS: mm/dd/yy - New (initials)               */
 /*                                               */
 /*-----------------------------------------------*/

 /* TERM MACRO IF INPUTS NOT MET */    
  %if %length(&parm1) = 0 %then %do;
    %put ************* Macro Error Report **************;
    %put ---> Input parm requirements not meet.     <---;
    %put ***********************************************;
    %goto endmac;
  %end;

 /* SETUP OR MODIFY DEFAULTS */    
  %let parm1  = %upcase(&parm1);

 
 /* .. */
 
%endmac:
%put ******** END macro NEWMAC *********;     
%mend;













































