***OPTIONS NOMPRINT NOMLOGIC NOMACROGEN NOSYMBOLGEN MISSING=' ';                  

 TITLE;                                                                         
                                                                                
 %MACRO flatfile(libname=,memname=,pathout=,memout=);
 * ASSIGN LITERALS TO MACRO VARIABLES;                                          
 %LET THEPUT=PUT;

 libname  sasds  "&libname";

 filename flatout "&pathout";
 
 * SAVE CONTENTS OUTPUT IN A FILE;
 %if %nrquote(&libname) eq work %then %do;
 PROC CONTENTS DATA=&MEMNAME  OUT=FILEDEF NOPRINT;
 %end; %else %do;
 PROC CONTENTS DATA=sasds.&MEMNAME  OUT=FILEDEF NOPRINT;
 %end;
                                                                                
 * SORT BY THE VARIABLE NUMBER;                                                 
 PROC SORT;                                                                     
   BY VARNUM;                                                                   
                                                                                
* Tech PUT MACRO VARIABLES IN SYMBOL TABLE;                                     
 DATA _NULL_;                                                                   
   SET FILEDEF;                                                                 
                                                                                
 * NUMBER OF VARIABLES;                                                         
 CALL SYMPUT('NVAR',PUT(VARNUM,3.));                                            
                                                                                
 * VARIABLE NAMES;                                                              
 CALL SYMPUT('VNAME'||LEFT(PUT(_N_,3.)),TRIM(PUT(NAME,$32.)));                        
                                                                                
 * TYPE = 1 IS NUMERIC;                                                         
 * TYPE = 2 IS CHARACTER;                                                       
 IF TYPE = 1 THEN                                                               
   DO;                                                                          
   IF FORMAT = 'MMDDYY' THEN                                                    
        CALL SYMPUT('TYPE'||LEFT(PUT(_N_,3.)),PUT("D",$1.));                    
     ELSE                                                                       
        CALL SYMPUT('TYPE'||LEFT(PUT(_N_,3.)),PUT("N",$1.));                    
   END;                                                                         
 ELSE                                                                           
 IF TYPE = 2 THEN                                                               
   DO;                                                                          
     CALL SYMPUT('TYPE'||LEFT(PUT(_N_,3.)),PUT("C",$1.));                       
   END;                                                                         
                                                                                
 RUN;                                                                           
                                                                                
 DATA _NULL_;                                                                   
                                                                                
 * READ THE SAS DATASET;
 %if %nrquote(&libname) eq work %then %do;
 SET &memname;
 %end; %else %do;
 SET sasds.&MEMNAME;                                                        
 %end;
 
 * CREATE A FLAT TSO DATASET;                                                   
 FILE FLATOUT(&memout) lrecl=1600;                                                                  
                                                                                
 * POINTER VARIABLE TO MOVE COMMA BACK 1 COLUMN IN OUTPUT RECORD;               
 P = -1;                                                                        
                                                                                
 * USE MACRO VARIABLES TO BUILD A PUT STATEMENT;                                

 
 IF _N_ = 1 THEN                                                                
   DO;
     %DO I = 1 %TO &NVAR;
        %if &i < &nvar %then %let theput = &theput '"' "&&vname&i" '",' ;
        %else                %let theput = &theput '"' "&&vname&i" '"' %nrstr(;);
     %end;
     
     /*%let theput = %substr(%nrquote(&theput),1,%length(%nrquote(&theput))-1);*/
     /*%let theput = &theput %nrstr(;); */
     %put **&theput**;
     &theput
     %let theput = PUT;
     %DO I = 1 %TO &NVAR;
        %if &i < &nvar %then %do;
        %IF "&&TYPE&I" = "D" OR                                                 
            "&&TYPE&I" = "C" %THEN                                              
            %LET THEPUT = &THEPUT '"' &&VNAME&I +P '"' ',';                     
        %ELSE                                                                   
            %LET THEPUT = &THEPUT &&VNAME&I +P ',';
        %end;
        %else %do;
        %IF "&&TYPE&I" = "D" OR                                                 
            "&&TYPE&I" = "C" %THEN                                              
            %LET THEPUT = &THEPUT '"' &&VNAME&I +P '"' ;
        %ELSE                                                                   
            %LET THEPUT = &THEPUT &&VNAME&I +P ;
        %end;     
     %END;                                                                  
   END;                                                                      
                                                                                
 * WRITE A COMMA DELIMITED RECORD;                                              
 &THEPUT;                                                                       
                                                                                
 RUN;                                                                           
                                                                                
 %MEND flatfile;
