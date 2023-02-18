/*********************************************************************************************************
Macro:      stat_table
Category:   Statistics
---------------------------------------------------------------------------------------------------------
Purpose:    This macro prints a summary measures for discrete and continuous variables                                 
            by subgroups and overall along with p-values for differences in subgroups.                                 
                                                                                                                       
            Formatted variables will be printed using their formats.                                                   
                                                                                                                       
            The parameters in this macro are all keyword parameters.  They must be specified by entering each          
            parameter name with an equal sign and the value of the parameter                                           

Use:          %stat_TABLE(DSN=_last_, 
                          ID=, 
                          BY=, 
                          VAR=, 
                          TYPE=, 
                          OUTDOC=, 
                          OUTDAT=, 
                          LIST=N, 
                          PRINT=Y, 
                          NUMBER=N, 
                          CSTATS=n mean sd median quartiles range, 
                          DSTATS=n percent,
                          pfoot=n,
                          SURV=, 
                          SCENSOR=0, 
                          TOTAL=Y, 
                          PVALUES=Y, 
                          PTYPE=, 
                          CI=, 
                          POP=, 
                          INCMISS=N, 
                          INCMISS1=, 
                          COMMENTS=, 
                          DVAR=, 
                          DLINE=, 
                          DECPCT=1, 
                          TTITLE1=, 
                          TTITLE2=, 
                          TTITLE3=, 
                          TTITLE4=,
                          FOOT=, 
                          FOOT2=, 
                          FOOT3=, 
                          FOOT4=, 
                          FOOT5=, 
                          DATE=Y, 
                          PAGE=portrait, 
                          RULES=groups, 
                          FRAME=hsides,
                          TITLESZ=10, 
                          BODYSZ=10, 
                          FOOTSZ=10, 
                          TITLEBLD=Y, 
                          TITLEFNT=Times New Roman, 
                          HEADFNT=Times New Roman,
                          BODYFNT=Times New Roman, 
                          CIWD=, 
                          PVALWD=100, 
                          LEVELWD=, 
                          DATAWD=, 
                          SPACE=, 
                          DEBUG=N, 
                          PDEC=4, 
                          pcttype=col);

Input(s):     Specified by user.
Parameter(s): 
              REQUIRED:
                 DSN:     dataset name, dataset must have only one line per patient (required; default=_last_)              

                 VAR:     list of discrete and continuous variables in the order in which they will be printed (required)   
                          (discrete variables can be character or numeric, but continuous variables must be numeric)        
                          (for survival variable, enter fu_time in this list and the follow up statistic under SURV=        
                          and the censoring value under SCENSOR=)                                                          
                          (variables can be formatted)  
 
                TYPE:      list of indicators for type of analysis for each variable in the var parameter (required)        
                              i.e. var=score1 score2 scorepct, type=1 1 2.                                                   
                           If a list of variables are of the same type, you only have to enter the type once                
                              i.e. var=gender race stage, type=2.  var=gender age race stage ps, type= 2 1 2.                
                           1=continuous data: prints n, mean, median, std, quartiles, range - these default stats can be    
                                               changed in the CSTATS variable                                                
                           2=discrete data: prints freqs (n, %) - these default stats can be changed in the DSTATS variable 
                           3=ordinal data: print freqs (n, %)                                                               
                           4=survival data: print number of patients, number of events, median time to survival             
                           5=discrete data: prints freqs (n only)                                                           
                           6=discrete data: prints freqs (% only)                                                           
                           7=continuous data: prints n, median, quartiles                                                   
                           8=continuous data: prints n, mean, sd, range                                                     
                           p1=discrete data: only prints the first category (i.e. if categories are No and Yes and you only 
                                  want the No displayed, use this option)                                                    
                           p2=discrete data: does not print the first category (i.e. if the first category is 'missing'     
                                  and you do not want this displayed, use this option to deletes this first category)        
                           p3=discrete data: does not print the first two categoris (i.e. if the first category is          
                                  'missing' and the second is 'No' and you want to only print 'Yes' use this option)         
              
             OPTIONAL:
             JUSTIFY:      l for left-justifed plot(the default), c for centered

                  BY:      by variable.  Frequencies or summary measures will be produced for each value (optional)           
                           if no by variable is entered, all the data will be summarized together.                            
                           (can be formatted, character or numeric; only one is allowed with as many levels as desired)
 
              OUTDOC:      name of WORD file created (.doc will be appended to all documents if no appendage is typed in) 
                           this can contain the directory as well, i.e. ~parkj2/consult/tables/demogtable, if no          
                           directory is defined, document will be stored in directory from where the program is run       
                           If left blank, no document will be created. (optional) 
 
              OUTDAT:      name of SAS dataset created which can then be used with tablemerge.macro (optional)            
                           If left blank, no dataset will be created.
   
              CSTATS:      list of statistics desired for continuous data - n, nmiss, mean, sd, median, quartiles, range  
                           (default=n mean sd median quartiles range)  Note: This will only affect variables with TYPE=1  

              DSTATS:      list of statistics desired for discrete data - n , percent (default=n percent) Note: this will 
                           only affect variables with TYPE=2, p1, p2, or p3                                               
                                                                                                                   
                LIST:      Make a listing document (outdoc name with _lst appended), (optional; default=N) 
 
                  ID:      ID variable to sort on for listing (required if LIST=Y, default=none)    
 
               PRINT:      Print out the dataset used to make table in SAS listing output, (optional; default=N)           
                                                                                                                   
                SURV:      follow up status variable for survival analysis (required if there's a survival variable in VAR) 
                           SURV can be a list if you have multiple survival variables, but if SURV will be the same for     
                           all of survival variables in VAR, you only need to list it once  
 
             SCENSOR:      scoring of censor - event is censor+1 (required if there is a survival variable; default=1)   
                           SCENSOR can be a list of censor values for each of the survival variables in VAR, but if      
                           the the censor value will be the same for each of the survival variables, only one needs to   
                           be listed. 
 
               TOTAL:      y:print a total column, n: do not print a total column (optional; default=y)  
 
             PVALUES:      y:print p-values, n:do not print p-values (optional; default=y)                               
                           Default p-values: continuous-type=1 then default=kruskal-wallis                                
                                            discrete-type=2 then default=chi-square                                      
                                            ordinal-type=3 then default=wilcoxon                                         
                                            survival-type=4 then default=log-rank                                        
                           if PVALUES=y then all pvalues will be run for each variable and can be seen in the            
                           SAS listing output.  Only one p-value (either the default or the p-value specified in PTYPE)  
                           will print in the ODS table created.        
 
               PTYPE:      p-value desired by user.  If specified, must be specified for each variable (optional)          
                           0=no p-value for this variable                                                                  
                           1=Chi-Square p-value                                                                            
                           2=Fisher's Exact p-value                                                                        
                           3=Kruskal-Wallis p-value                                                                        
                           4=Exact Kruskal-Wallis p-value                                                                  
                           5=Wilcoxon p-value                                                                              
                           6=Exact Wilcoxon p-value                                                                        
                           7=ANOVA F-test p-value                                                                          
                           8=log-rank p-value (for survival data)
 
               PFOOT:      Put a footnote of p-values used in the table (a superscript number will be placed after each    
                           p-value in the table) note: this only works if running SAS 8.2; ods escapechar='~'   
 
                  CI:      print 95% confidence intervals (optional; default=none, only done for the first two by categories) 
                           1=print CI for differences between continuous variables                                            
                           2=print CI for difference in proportions                                                           
                           (if it is specified, it must be specified for all variables in the var parameter)
 
                 POP:      Type in the expression to determine population (optional; default=all records)                    
                           this will be put into an if statement. i.e. if in the macro call you put POP=excluded<7 then in   
                           the dataset where it sets your data it will say: if excluded<7;                 
 
             INCMISS:      including missing values as a separate category during analysis for categorical variables     
                           Y=yes (default=N) (you can also specify one variable which can include missing values)        
                           (This refers to your BY group)    
   
            INCMISS1:      list of variable numbers which can include missing values in analysis (default=none)
 
            COMMENTS:      SAS dataset name of comments to add into the printout (optional; default=none)  
 
                DVAR:      list of variable numbers for which you want a line deleted (optional; default=none) 
 
               DLINE:      list of lines to delete for corresponding variable number in DVAR (optional; default=none)      
                           i.e. dvar=2 5, dline=2 3 : for variable #2 delete line 2 and for variable #5 delete line 3 
 
              DECPCT:      number of decimals to print on percentages - up to 4 (optional; default=0)      
 
                PDEC:      number of decimals to print for p-values - 1-4 (optional; default=4)                             
                                                                                                                   
             TTITLE1:      1st table title (optional; default=none) 
 
             TTITLE2:      2nd table title (optional; default=none) 
 
             TTITLE3:      3rd table title (optional; default=none) 
 
             TTITLE4:      4th table title (optional; default=none) 
 
                FOOT:      footnote (optional; default=none)             
 
         FOOT2-FOOT5:      More footnotes (optional; default=none) 
 
                DATE:      Prints the date in the footnote of each table, Y or N (optional; default=Y).   
 
              NUMBER:      prints the page numbers, Y or N (optional; default=N);                                         
                                                                                                                   
                PAGE:      Page orientation for ODS RTF output: portrait or landscape (optional; default=portrait)  
 
               FRAME:      frame for the table, standard options below (optional; default=hsides)                          
                           above = at top                                                                                  
                           below = at bottom                                                                               
                           box = top bottom and both sides                                                                             
                           hsides = borders at top and bottom                                                                      
                           lhs = border on left side                                                                       
                           rhs = border on right side                                                                      
                           void = no borders                                                                               
                           vsides = borders at left and right sides          
 
               RULES:      rules (lines/borders) within the table (optional; default=groups)                               
                           all = between all rows and columns                                                              
                           cols = between all columns                                                                      
                           group = between header and table, and between table and footer                                            
                           none = no rules anywhere                                                                        
                           rows = between all rows                   
 
             TITLESZ:      font size for title (optional; default=10)   
 
              BODYSZ:      font size for body text (optional; default=10) 
 
              FOOTSZ:      font size for footer (optional; default=10)     
 
            TITLEBLD:      font-weight for table title: Y=bold, N=normal. (default=Y) 
 
            TITLEFNT:      font-face for table titles (optional; default=Times New Roman)                                
                           (fonts available: Times New Roman, Helvetica, Arial, SwissB)   
 
             HEADFNT:      font-face for column headings, levels, footnotes (optional; default=Times New Roman) 
 
             BODYFNT:      font-face for all data.  (optional; default=Times New Roman)    
 
                CIWD:      cellwidth for confidence interval column (optional; default=computer default  
 
              PVALWD:      cellwidth for pvalue column (optional; default=computer default)      
 
             LEVELWD:      cellwidth for level/variable heading column (optional; default=computer default) 
 
              DATAWD:      cellwidth for data columns  (optional; default=computer default)     
 
               SPACE:      cell spacing (optional; default sets cellpadding=2)                                             
                           1=pack; sets cellpadding=1                                                                      
                           2=expand; sets cellpadding=4                                                                    
                                                                                                                   
               DEBUG:      Y to print notes and macro values for debugging (optional; default=N)     
 
             PCTTYPE:      ROW for row percentages in table, COL for column percentages (default=COL)                                                                                                                            
             

Format(s):    N/A
Macro(s):     N/A
Output(s):    N/A.
Format(s):    N/A

---------------------------------------------------------------------------------------------------------
Example of use: 
      %table(dsn=master, by=arm, var=factor_a factor_b gender race, type=1 2, outdoc=facttable);                 
      %table(dsn=master, by=arm, var=ps, type=3, pvalues=n, outdoc=~parkj2/consult/pstable);                     
      %table(dsn=master, by=curr_arm, var=sex race age weeks, type=2 2 1 1, outdat=demog);                       
      %table(dsn=master, id=id, list=y, var=sex race age ps, type=2 2 1 3, outdoc=demographics, outdat=demdat);
*********************************************************************************************************/
rsubmit;
%MACRO stat_TABLE(DSN=_last_, ID=, BY=, VAR=, TYPE=, OUTDOC=, OUTDAT=, LIST=N, PRINT=Y, NUMBER=N, 
             CSTATS=n mean sd median quartiles range, DSTATS=n percent, pfoot=n,
             SURV=, SCENSOR=0, TOTAL=Y, PVALUES=Y, PTYPE=, CI=, POP=, INCMISS=N, INCMISS1=, 
             COMMENTS=, DVAR=, DLINE=, DECPCT=1, TTITLE1=, TTITLE2=, TTITLE3=, TTITLE4=, 
             FOOT=, FOOT2=, FOOT3=, FOOT4=, FOOT5=, DATE=Y, PAGE=portrait, RULES=groups, FRAME=hsides, 
             TITLESZ=10, BODYSZ=10, FOOTSZ=10, TITLEBLD=Y, TITLEFNT=Times New Roman, HEADFNT=Times New Roman,
             BODYFNT=Times New Roman, CIWD=, PVALWD=100, LEVELWD=, DATAWD=, SPACE=, DEBUG=N, PDEC=4, pcttype=col
             );

%let validvn=%sysfunc(getoption(validvarname));
%let sdate=%sysfunc(getoption(nodate));
%let snotes=%sysfunc(getoption(nonotes));
%let snumb=%sysfunc(getoption(nonumber));
%let number=%upcase(&number);

%let debug=%upcase(&debug);
%if (&debug=Y) %then %do;  options mprint mtrace macrogen notes linesize=132 ps=58; %end;
               %else %do;  options nonotes nomprint nomacrogen nomtrace nosymbolgen nomlogic linesize=132 ps=58; %end;

options nodate %if &number=Y %then %do; number %end; %else %do; nonumber %end; validvarname=v7 ;


/************************************/
/* creates defaults and conversions */
/************************************/
%if (&space=) %then %let space=2;
%else %if (&space=1)  %then %let space=0;
%else %if (&space=2)  %then %let space=4;

%let dsn=%upcase(&dsn);
%let by=%upcase(&by);
%let pvalues=%upcase(&pvalues);
%let total=%upcase(&total);
%let incmiss=%upcase(&incmiss);
%let list=%upcase(&list);
%let print=%upcase(&print);
%let titlebld=%upcase(&titlebld);
%let date=%upcase(&date);
%let pfoot=%upcase(&pfoot);
%let pcttype=%upcase(&pcttype);
  %if "&pcttype"="PCT_ROW" | "&pcttype"="ROW" | "&pcttype"="ROW_PCT" %then %let pct_type=PCT_COL;
  %if "&pcttype"="PCT_COL" | "&pcttype"="COL" | "&pcttype"="COLUMN" | "&pcttype"="COL_PCT" %then %let pct_type=PCT_ROW;
%if &pvalues=N %then %let pfoot=N;
%if &pfoot=Y %then %do;
  %let pfnum=0; %let pt1=0; %let pt2=0; %let pt3=0; %let pt4=0; %let pt5=0; %let pt6=0; %let pt7=0; %let pt8=0;
  %let pnm1=Chi-Square; %let pnm2=Fisher Exact; %let pnm3=Kruskal Wallis; %let pnm4=Exact Kruskal Wallis;
  %let pnm5=Wilcoxon; %let pnm6=Exact Wilcoxon; %let pnm7=ANOVA F-Test; %let pnm8=Log-Rank; %let pft= ;
%end;

%if (&by=) %then %do; 
  %let pvalues=N;
  %let total=N;
  %let by=_MYBY_;
  %let noby=1;
  %let ci=;
%end;
%else %do; %let noby=0; %end;

%if (&decpct=4) %then %let decpct=0.0001;
%if (&decpct=3) %then %let decpct=0.001;
%if (&decpct=2) %then %let decpct=0.01;
%if (&decpct=1) %then %let decpct=0.1;
%if (&decpct=)  %then %let decpct=1;

%if (&pdec=4) %then %let ppct=0.0001;
%else %if (&pdec=3) %then %let ppct=0.001;
%else %if (&pdec=2) %then %let ppct=0.01;
%else %if (&pdec=1) %then %let ppct=0.1;
%else %let ppct=0.0001;

%let errors=0;
%let bytype=char;
%let byf=$char5.;
%if %scan(&surv,2)^= %then %let snum=1;
%else %let snum=0;
%if %scan(&scensor,2)^= %then %let scen=1;
%else %let scen=0;

%let cn=0; %let cmn=0; %let csd=0; %let cmd=0; %let cq=0; %let cr=0; %let cnmiss=0;
%do i=1 %to 7;
  %let myscan=%upcase(%scan(&cstats,&i));
  %if (&myscan^=) %then %do;
    %if &myscan=N %then %do; %let cn=1; %end; 
    %if &myscan=MEAN %then %let cmn=1; 
    %if &myscan=SD %then %let csd=1; 
    %if &myscan=MEDIAN %then %let cmd=1;
    %if &myscan=QUARTILES %then %let cq=1;
    %if &myscan=RANGE %then %let cr=1;
    %if &myscan=NMISS %then %let cnmiss=1;
  %end;
  %else %let i=7;
%end;

%if &cmn=1 & &csd=1 %then %let cms=1; 
%else %if &cmn=1 %then %let cms=2; 
%else %if &csd=1 %then %let cms=3; 
%else %let cms=0;

%let dn=0; %let dp=0;
%do i=1 %to 2;
  %if (%scan(&dstats,&i)^=) %then %do;
  %if %upcase(%scan(&dstats,&i))=N %then %let dn=1;
  %if %upcase(%scan(&dstats,&i))=PERCENT %then %let dp=1;
  %end;
%end;

%if &dn=1 & &dp=1 %then %let dnp=1; 
%else %if &dn=1 %then %let dnp=2; 
%else %if &dp=1 %then %let dnp=3; 
%else %do; %put ERROR: incorrect statistics chosen in DSTATS, defaults will be used; %let dnp=1; %end;


proc format;
  picture fpvalue low-high='9.9999';

/***********************************/
/* creates an analysis master file */
/***********************************/

%if ^(%sysfunc(exist(&dsn))) %then %do; %let errors=1;  %let errorwhy=Dataset &dsn does not exist; %end;
%else %do;

data _master (keep=&id &var &surv &by _by_ );
  set &dsn;

  /* creates a character variable to replace the by variable */
  length _by_ $ 40;
  %if &noby=1 %then %do; &by='Total'; %end; 
  _by_ = trim(&by); 

  /* selects the correct analysis population */
  %if ("&pop"^="")   %then %do; if &pop;  %end;
run;

%if (&type=) %then %do; %let errors=1;  %let errorwhy=Variable TYPE was not defined; %end; %let opn=%sysfunc(open(_master));  
%if &opn %then %do;
  %if (%sysfunc(attrn(&opn,NOBS))=0) %then %do; %let errors=1;  %let errorwhy=Error creating master dataset from dataset &dsn; %end;
  %let rc=%sysfunc(close(&opn));
%end;
    
%end; 
  
%if &errors^=1 %then %do;
  
/******************************************/
/* creates a listing of the analysis file */
/******************************************/

/*****************************************/
/* creates the template for the listings */
/*****************************************/
proc template;
  define style lsttable;
  style table /
     frame=&frame
     cellpadding=4
     cellspacing=2
     rules=&rules
     asis=on
     borderwidth=2;
  style data /
     font_face="&bodyfnt"
     asis=on
     font_size=&bodysz.pt;
  style Body /
     font_face="&bodyfnt"
     asis=on
     font_size=&bodysz.pt;
  style SystemTitle /
     font_face="&bodyfnt"
     font_weight=bold
     asis=on
     font_size=&bodysz.pt;
  style Header /
     font_face="&bodyfnt"
     asis=on
     font_size=&bodysz.pt;
  style BodyDate /
     font_face="&bodyfnt"
     asis=on
     font_size=&bodysz.pt;
  style Byline /
     font_face="&bodyfnt"
     asis=on
     font_size=&bodysz.pt;
  style SystemFooter /
     font_face="&bodyfnt"
     asis=on
     font_size=&bodysz.pt;
  style SysTitleAndFooterContainer /
     font_face="&bodyfnt"
     asis=on
     font_size=&bodysz.pt;
  style Obs /
     font_face="&bodyfnt"
     asis=on
     font_size=&bodysz.pt;
  style IndexItem /
     font_face="&bodyfnt"
     asis=on
     font_size=&bodysz.pt;
  style Rowheader /
     font_face="&bodyfnt"
     asis=on
     font_size=&bodysz.pt;
  end;
  run;

options linesize=120 pagesize=54;

%if %length(%scan(&outdoc,-1,%str(.)))=3 %then %let doctype=%scan(&outdoc,-1,%str(.)); %else %let doctype=0;

%if &list=Y %then %do;
  %if "&doctype"="0" %then %do; %let docnm=&outdoc._lst.doc; %end;
  %else %do; %let docnm=%scan(&outdoc,1,.)_lst.&doctype; %end;

  ods listing close;
  ods rtf file="&docnm"  style=lsttable;

  data _tmp_;
    set _master;
  
  proc sort data=_tmp_;
    by &by &id;

  %let docname=%scan(&outdoc,-1,/);

  proc print data=_tmp_ label uniform split='#';
    %if &noby=0 %then %do; by &by; %end;
    var &id &var;
    title "Listing of Data for &docname created on &sysdate9";
  run;
  
  ods trace off;

  ods rtf close;
  ods listing;
  %put Created File: &docnm;
%end;

options linesize=72 pagesize=60;

/**********************************************/
/* creates tables of variable characteristics */
/* as macro variables                         */
/**********************************************/

proc sql;
  create table _c_ as
    select *
     from sashelp.vcolumn
     where libname="WORK"
      and memname="_MASTER";

  create table _c2_ as
    select *
     from sashelp.vtable
     where libname="WORK"
      and memname="_MASTER";
  quit;

/**************************************************************/
/* determines the number of observations in the analysis file */
/**************************************************************/
     /* nobs = number of observations in the analysis file */
data _null_;
  set _c2_;
  call symput('nobs',trim(left(put(nobs,5.))));

/*************************************************************/
/* gets variable type, format, and label for the by variable */
/*************************************************************/

     /* bytype = char or num = by variable type */
     /* byf = format for the by variable */
     /* bylbl = label for the by variable */
     
 data _null_;
  set _c_;
  if (label=' ') then label=name;
  if (upcase(name)="&by") then do;
        call symput('bytype',trim(left(type)));
        call symput('byf',trim(left(format)));
        call symput('bylbl',trim(left(label)));
        call symput('bylength',trim(left(put(length,3.))));
  end;
  run;
   
/*******************************************************/
/* distribution of by variable (including missing)     */
/* and creates macro variables of the different levels */
/*******************************************************/

  proc freq data=_master noprint;
    table &by / out=_d01 missing ;

  proc sort data=_d01; by &by; run;

      /* by1, by2, etc are identifiers of the by levels */
      /* byn1, ... are the totals in each by group */
      /* nby is the number of levels of the by variable */

  data _null_;
    set _d01;
    %if (&byf^=) %then %do;
      call symput("fby" || trim(left(_n_)),trim(put(&by,&byf.)));
    %end;
    %else %do; call symput("fby" || trim(left(_n_)),trim(&by)); %end;
    call symput("by" || trim(left(_n_)),trim(&by));
    call symput("byn" || trim(left(_n_)),trim(left(count)));
    call symput("nby",trim(left(_n_)));
  run;
  data _null_;
    set _d01;
    %if &bytype=num %then %do; where &by^=.; %end;
    %if &bytype=char %then %do; where &by^=""; %end;
    call symput("nby_miss",trim(left(_n_)));
  run;

/*****************************************/
/*****************************************/
/** does the analyses for each variable **/
/*****************************************/
/*****************************************/
%let num=1;                                    /* num = the number of the variable being processed */
%let v1=%upcase(%scan(&var,&num));             /* v1 = the variable name for the current discrete variable */
%let ind=%scan(&type,&num);                    /* ind=1 for cont, 2 for discrete, 3 for both */

%if ("&ptype"^="") %then %let pval=%scan(&ptype,&num);                  /* ptype=type of pvalue desired */
%if ("&ptype"="") %then %if &ind=1 | &ind=7 | &ind=8 %then %let pval=3;
  %else %if &ind=3 %then %let pval=5;
  %else %if &ind=4 %then %let pval=8; 
  %else %let pval=1;
  
%if &pfoot=Y %then %do;
%if &pval>0 %then %do;
%if &&pt&pval=0 %then %do;
  %let pt&pval=1;
  %let pfnum=%eval(&pfnum+1);
  %let pnum&pval=&pfnum;
  %let pft=~{super &pfnum} &&pnm&pval;
%end; %end;
%end; 

data _mst; run;
   
%do %while (&v1^=);

  /*********************************************/
  /* gets the variable type, format, and label */
  /*********************************************/
  %let v1type=;
  %let v1f=;
  %let v1lbl=;
  %let hasit=0;
  
  data _null_;
    set _c_;
    if (label=' ') then label=name;
    if (upcase(name)="&v1") then do;
          call symput('v1type',trim(left(type)));        /* v1type = current variable type   */
          call symput('v1f',trim(left(format)));         /* v1f    = current variable format */
          call symput('v1lbl',trim(left(%str(label))));  /* v1lbl  = current variable label  */
          call symput('hasit',1); 
    end;
    run;
  
   %if &hasit=0 %then %do; %let errorvar=1; %put WARNING: Variable &v1 not found in dataset &dsn; %end;
   %else %let errorvar=0; 

   %do i=1 %to 100;
     %if (%scan(&incmiss1,&i)^=) %then %do;
       %if %scan(&incmiss1,&i)=&num
       %then %do; %let mis=1; %let i=100; %end;
       %else %do; %let mis=0; %end;
     %end;
     %else %do; %let mis=0; %let i=100; %end;
   %end;
   
   %if &nby>=2 %then %do;
   %do i=1 %to 100;
     %if (%scan(&ci,&i)^=) %then %do;
       %if %scan(&ci,&i)=&num
       %then %do;
         %if &type=1 %then %do; %let cip=1; %end;
         %else %do; %let cip=2; %end;
         %let i=100;
       %end;
       %else %do; %let cip=0; %end;
     %end;
     %else %do; %let cip=0; %let i=100; %end;
   %end;
   %end; %else %do; %let ci=; %let cip=0; %end;

  %if &errorvar=0 %then %do;

  /************************************/
  /************************************/
  /** analyses for discrete variables */
  /************************************/
  /************************************/
  %if &ind=2 or &ind=3 or &ind=5 or &ind=6 or "&ind"="p1" or "&ind"="p2" or "&ind"="p3"  %then %do;

    /*********************************************/
    /* overall distribution of analysis variable */
    /*********************************************/

    data _master;
      set _master;
      format &by;

    proc freq data=_master noprint;
      table &v1 / out=_d02
                  %if (&incmiss=Y) | (&mis=1)
                  %then %do;  missing  %end; ;
    run;

    /**********************************************************************************************/
    /* creates a matrix of all possible combinations of the analysis variable and the by variable */
    /* including missing values                                                                   */
    /**********************************************************************************************/
           /* l1-l8 are the levels of the by variable */
           /* n1-n8 are the total counts at each by level */
           /* nall is the total number of observations */

    data _level (keep=l1-l&nby. n1-n&nby. nall _merge);
      set _d01 end=eof;
      %if (&bytype=char) %then %do; length l1-l&nby. $ &bylength.; %end;
      %if (&byf^=)       %then %do; format &by l1-l&nby. &byf; %end;
     
        retain l1-l&nby. n1-n&nby. ;
        _merge=1;
        %do i=1 %to &nby;
          if _n_=&i then do;
            l&i. = &by;
            n&i. = count;
          end;
      %end;

      if eof then do;
         nall=sum(of n1-n&nby.);
         output;
      end;

    /* puts the overall by level values on each record */
    data _dall;
      set _d02;
      if (_n_=1) then set _level;

    data _dall (keep=&by &v1);
      set _dall end=eof;
      %if (&bytype=char) %then %do; length &by. $ &bylength.; %end;
      %if (&byf^=) %then %do; format &by &byf; %end;
      %if (&bytype=num) %then %do;
         %do i = 1 %to &nby.;
           if l&i.^=. then do; &by=l&i.; output; end;
         %end;
      %end;
      %if (&bytype=char) %then %do; %do i=1 %to &nby.;
        if l&i.^=' ' then do; &by=l&i.; output; end;
      %end; %end;
      if eof then call symput ('ny',trim(left(_n_)));
    run;

    %let nx=&nby;

    /**************************************/
    /* sets p-values initially to missing */
    /**************************************/
    data _d2;
      p_pchi=.; p_exact2=.; output;

    /*********************************************/
    /* subgroups distributions excluding missing */
    /*********************************************/

    proc freq data=_master noprint;
      table &by * &v1 / out=_d1 outpct
                        %if (&incmiss=Y) | (&mis=1)
                        %then %do;  missing %end;

      /* the following criteria are for whether or not
         to do an exact test */
                      %if &nby_miss>1 & "&pvalues"="Y" %then %do;  
                        %if (%eval(&ny<=8) & %eval(&nx<=5) & %eval(&nobs<100)) |
                            (%eval(&ny<=5) & %eval(&nx<=3)) & %eval(&nobs<=50)
                        %then %do; exact %end;
                        %else %do; chisq %end; 
                      %end;  
                        ;
       %if &nby_miss>1 & "&pvalues"="Y"  %then %do;                   
          output out=_d2 n nmiss pchi 
              %if (%eval(&ny<=8) & %eval(&nx<=5) & %eval(&nobs<100)) |
                  (%eval(&ny<=5) & %eval(&nx<=3)) & %eval(&nobs<=50)
              %then %do; exact %end;
              %else %do; chisq %end; ;
       %end;
    run;

    data _d1;
      set _d1;
      %if (&byf^=) %then %do; format &by &byf; %end;
    run;      
      
    data _d2;  *create a by variable to merge on later on;
      set _d2; _merge=1; run;

    /*************************************************************************/
    /* determines if there are enough levels to run the Kruskal-Wallis tests */
    /*************************************************************************/
  
   data _check;
      set _d1;
      if (count=0) then delete;
      %if (&bytype=num) %then %do;
         if (&by=.) then delete;
      %end;
      %else %do;
         if (&by=' ') then delete;
      %end;

    proc sort data=_check;
      by &by;

    data _check;
      set _check;
      by &by;
      if (first.&by);

    %let varby=1;

    data _check;
      set _check;
      if (_n_>1) then call symput('varby','2');
      run;

    /********************************************/
    /* Kruskal-Wallis p-value excluding missing */
    /********************************************/
    %if (&v1type=num) & (&varby^=1)  & "&pvalues"="Y" %then %do;
        proc npar1way data=_master wilcoxon noprint;
          var &v1;
          class &by;

          * the following criteria are for whether;
          * or not to do an exact test;
          %if (%eval(&ny<=8) & %eval(&nx<=5) & %eval(&nobs<50)) |
              (%eval(&ny<=5) & %eval(&nx<=3)) | %eval(&nobs<=20)
          %then %do; exact wilcoxon; %end;
          output out=_f1 wilcoxon anova;
    %end;
    %else %do;
         data _f1;
           p_kw=.;
           xp_kw=.;
           p_f=.;
           p2_wil=.;
           xp2_wil=.;
           output;
    %end;
  
    data _f1; set _f1; _merge=1; run;
   
    proc sort data=_dall;
      by &v1 &by;

    proc sort data=_d1;
      by &v1 &by;

    data _final;
      merge _dall (in=a) _d1 (in=b);
      by &v1 &by;

    data _tmp;
      set _master;
      if (_by_^=' ');

    proc freq data=_tmp noprint;
      table &v1 / out=_d02  %if (&incmiss=Y) |
                                (&mis=&num)
                            %then %do;  missing  %end; ;

    data _d02;
      set _d02;
      %if (&bytype=num) %then %do; &by=99999999; %end;
                        %else %do; &by="zzzzzzz"; %end;
      total='y';

    data _final;
      set _final _d02;

    proc sort data=_final;
      by &v1 &by;

    data _d2;
      merge _d2 _level  _f1;
      by _merge;
/*      %if &pfoot=Y %then %do; length pvalue $ 17; %end; %else %do; length pvalue $ 7; %end; */
      format p1 p2 p3 p4 p5 p6 p7 fpvalue.;
      label p1='Chi-Square p-value'
            p2="Fisher's Exact p-value"
            p3='Kruskal-Wallis p-value'
            p4="Exact Kruskal-Wallis p-value"
            p5='Wilcoxon p-value'
            p6='Exact Wilcoxon p-value'
            p7='ANOVA F-test p-value';
      p1=round(p_pchi,&ppct.); p2=round(xp2_fish,&ppct.);
      p3=round(p_kw,&ppct.); p4=round(xp_kw,&ppct.);
      p5=round(p2_wil,&ppct.); p6=round(xp2_wil,&ppct.);
      p7=round(p_f,&ppct.);
      %if &pval>0 /*(1<=&pval<=7)*/ %then %do;
        if (p&pval.<&ppct. & p&pval.^=.) then do;
           %if &pfoot=Y %then %do; pvalue="<&ppct.~{super &&pnum&pval}"; %end;
           %else %do; pvalue="<&ppct."; %end;
        end;
        else do;
           %if &pfoot=Y %then %do; pvalue=trim(left(put(round(p&pval.,&ppct.),6.&pdec.))) || "~{super &&pnum&pval}"; %end;
           %else %do; pvalue=put(round(p&pval.,&ppct.),6.&pdec); %end;
        end;
      %end;
      %else %do; pvalue=' '; %end;
      keep l1-l&nby. n1-n&nby. nall pvalue p1-p7;
    run;

    data _final;
      set _d2 _final;
      if (count=.) then count=0;
      %if (&bytype=num) & (&v1type=num) %then %do;
          if (percent=.) & (&v1^=.) & (&by^=.) then percent=0;
          if (pct_col=.) & (&v1^=.) & (&by^=.) then pct_col=0;
          if (pct_row=.) & (&v1^=.) & (&by^=.) then pct_row=0;
      %end;
      %if (&bytype=char) & (&v1type=num) %then %do;
          if (percent=.) & (&v1^=.) & (&by^=' ') then percent=0;
          if (pct_col=.) & (&v1^=.) & (&by^=' ') then pct_col=0;
      if (pct_row=.) & (&v1^=.) & (&by^=' ') then pct_row=0;
      %end;
      %if (&bytype=num) & (&v1type=char) %then %do;
          if (percent=.) & (&v1^=' ') & (&by^=.) then percent=0;
          if (pct_col=.) & (&v1^=' ') & (&by^=.) then pct_col=0;
          if (pct_row=.) & (&v1^=' ') & (&by^=.) then pct_row=0;
      %end;
      %if (&bytype=char) & (&v1type=char) %then %do;
          if (percent=.) & (&v1^=' ') & (&by^=' ') then percent=0;
          if (pct_col=.) & (&v1^=' ') & (&by^=' ') then pct_col=0;
          if (pct_row=.) & (&v1^=' ') & (&by^=' ') then pct_row=0;
     %end;

      length value vlbl vtype var $ 300;
      nvar=.; ny=.;
      nvar=&num;
      %if (&v1f=)  & (("&v1type"="num") | ("&v1type"="char"))
        %then %do; value=trim(&v1); %end;
      %if (&v1f^=) & (("&v1type"="num") | ("&v1type"="char"))
        %then %do; value=trim(put(&v1,&v1f)); %end;
      vlbl="&v1lbl";
      vtype="&v1type";
      ny=&ny;
      var="&v1";
      %if (&byf^=) %then %do; format &by &byf; %end;

    /*************************************************************/
    /* creates a file that can be easily printed with proc print */
    /*************************************************************/

    data _tmp (keep=nvar _line level ci c1-c&nby. p1-p7
                    ctotal pvalue);
      length level $ 300;
      length ci c1-c&nby. ctotal $ 40;
 /*     %if &pfoot=Y %then %do; length pvalue $ 17; %end; %else %do; length pvalue $7; %end; */
      set _final end=last;
      %if (&by1=) %then %do; label c1='Missing'; %end;
                  %else %do; label c1="&fby1";    %end;
      label level='#'
            ci='     '
            ctotal="Total";
      %if (&nby>1) %then %do; 
        %do i = 2 %to &nby;
          label c&i.="&&fby&i.";
        %end;
      %end;

      /* creates the first line as the label and p-values */
      if (_n_=1) then do;
         level=vlbl; ci='      '; cctotal=' ';
         %if (&nby>1) %then %do; %do i = 2 %to &nby.;  c&i.=' '; %end; %end;
         _line=1;
         pci1=.; pci2=.; nci1=0; nci2=0;
         output;
      end;
      else do;
         pvalue=' '; p1=.; p2=.; p3=.; p4=.; p5=.; p6=.; p7=.;
         if (&v1=' ') then level='    Missing';
                      else level="    " || trim(left(value));
         %if ((&by=' ') | (&v1=' ')) & ("&incmiss"^="Y")
         %then %do i = 1 %to &nby.;
            if (&by="&&by&i.") then c&i.=trim(left(count));
         %end;
         %else %do i = 1 %to &nby;
           %if &ind=5 | &dnp=2 %then %do;
             if (&by="&&by&i.") then c&i.=trim(left(count));
           %end;
           %else %if &ind=6 | &dnp=3 %then %do;
             if (&by="&&by&i.") then c&i.=trim(left(round(&pct_type,&decpct))) || "%";
           %end;
           %else %do;
             if (&by="&&by&i.") then c&i.=trim(left(count)) || " (" || trim(left(round(&pct_type,&decpct))) || "%)";
          %end;
           %if (&nby>1) %then %do; 
             if (&by="&by1") then do; pci1=&pct_type; nci1=nci1+count; end;
             if (&by="&by2") then do; pci2=&pct_type; nci2=nci2+count; end;
           %end;
         %end;
      end;
      if (total='y') then do;
        %do i = 1 %to &nby;
          if (c&i.=' ') then c&i.='0 (0%)';
          /* different formats if the values are missing */
          if (&v1=' ') & ("&incmiss"^='Y') then ctotal=trim(left(count)); else do;
            %if &ind=5 | &dnp=2 %then %do; ctotal=trim(left(count)); %end;
            %else %if &ind=6 | &dnp=3 %then %do; ctotal=trim(left(round(percent,&decpct))) || "%"; %end;
            %else %if "&pct_type"="PCT_COL" %then %do; ctotal=trim(left(count)); %end;
            %else %do; ctotal=trim(left(count)) || " (" || trim(left(round(percent,&decpct))) || "%)"; %end;
         end;
        %end;
        _line=_line+1;
        output;
      end;

      /* inserts a 95% confidence interval if requested */
      if (last) & ("&cip"="2") then do;
         mdiff=pci1-pci2; sd=sqrt(pci1*(100-pci1)/nci1 + pci2*(100-pci2)/nci2);
         lowerci=round(mdiff-1.96*sd,0.1);
         upperci=round(mdiff+1.96*sd,0.1);
         mdiff=round(mdiff,0.1);
         _line=_line+1;
         level=' ';
         %do i = 1 %to &nby; c&i.=' '; %end;
         ctotal=' ';
         _line=_line+1;
         output;
         level='Difference (95% CI)';
         ci=trim(left(mdiff)) || ' (' || trim(left(lowerci)) || ', ' || trim(left(upperci)) || ')';
         output;
      end;

      /* inserts a blank line after each variable */
      if (last) then do;
         level=' ';
         %do i = 1 %to &nby.; c&i.=' '; %end;
         ctotal=' '; pvalue=' '; ci=' ';
         _line=_line+1;
         output;
      end;
      retain ci c1-c&nby. ctotal _line pci1 pci2 nci1 nci2 p1-p4;
    run;

    /********************************************************/
    /* removes lines if only parts of variables are printed */
    /********************************************************/
    data _tmp;
      set _tmp end=last;
       if ("&ind"="p1") | ("&ind"="n1") then do;
          if (_line>2) & not last then delete;
       end;
       if ("&ind"="p2") | ("&ind"="n2") then do;
          if (_line=2) then delete;
       end;
       if ("&ind"="p3") then do;
          if (_line=2) | (_line=3) then delete;
       end;

    /***************************************************/
    /* appends this variable to the main analysis file */
    /***************************************************/
    %if (&num=1) %then %do;
        data _mst;
          set _tmp;
    %end;
    %else %do;
        data _mst;
          set _mst _tmp;
    %end;
  %end;  ** end of discrete/ordinal analysis **;

  /************************************************************************************/
  /************************************************************************************/

  %if (&ind=1) | (&ind=7) | (&ind=8) | (&ind=9) %then %do;
    /***************************************/
    /***************************************/
    /** analyses for continuous variables **/
    /***************************************/
    /***************************************/

    /************************************************/
    /* overall distributions without missing values */
    /************************************************/
    proc univariate data=_master noprint;
      var &v1;
      where (_by_ ^= ' ');
      output out=_e0 mean=mean median=median std=std min=min max=max n=n nmiss=nmiss q1=q1 q3=q3;

    data _e0;
      set _e0;
      total='y';

    /*********************************************************/
    /* distributions by group (including missing as a group) */
    /*********************************************************/
    proc sort data=_master;
      by &by;

    proc univariate data=_master noprint;
      var &v1;
      by &by;
      output out=_e mean=mean median=median std=std min=min max=max n=n nmiss=nmiss var=var q1=q1 q3=q3;

    data _all;
      set _e _e0;
      std=round(std,0.01);
      mean=round(mean,0.1);
      median=round(median,0.1);
      format mean median 10.1;
      
    /***********************************/
    /* p-values without missing values */
    /***********************************/
    data _f;
/*      %if &pfoot=Y %then %do; length pvalue $ 17; %end; %else %do; length pvalue $ 7; %end; */
      _merge=1; &by=.;
      pvalue=' '; p1=.; p2=.; p3=.; p4=.; p5=.; p6=.; p7=.;
    run;

    %if &nby_miss>1 & "&pvalues"="Y" %then %do;
      proc npar1way data=_master wilcoxon anova noprint;
        var &v1;
        class &by;
        where _by_ ^= ' ';
        %if %eval(&nobs<=20) %then %do; exact wilcoxon; %end;
        output out=_f wilcoxon anova;

      data _f;
        set _f;
  /*      %if &pfoot=Y %then %do; length pvalue $ 17; %end; %else %do; length pvalue $ 7; %end; */
        _merge=1;
        p1=.; p2=.;
        p3=round(p_kw,&ppct.);
        p4=round(xp_kw,&ppct.);
        p5=round(p2_wil,&ppct.);
        p6=round(xp2_wil,&ppct.);
        p7=round(p_f,&ppct.);
        %if (&pval>0) %then %do;
          if (p&pval.<&ppct. & p&pval.^=.) then do;
            %if &pfoot=Y %then %do; pvalue="<&ppct.~{super &&pnum&pval}"; %end; %else %do; pvalue="<&ppct."; %end; end;
          else do; %if &pfoot=Y %then %do; pvalue=trim(left(put(round(p&pval.,&ppct.),6.&pdec.))) || "~{super &&pnum&pval}"; %end;
                   %else %do; pvalue=put(round(p&pval.,&ppct.),6.&pdec.); %end; end;
        %end;
        %else pvalue=' ';
      run;
    %end;

    /*************************************************************/
    /* creates a file that can be easily printed with proc print */
    /*************************************************************/

     data _t;
      length level $ 300;
      length ci c1-c&nby. ctotal $ 40;
      _merge=1;
      level="&v1lbl"; _line=1;
      ci='      '; ctotal=' ';
      %if &nby>1 %then %do; %do i = 2 %to &nby.;  c&i.=' '; %end;  %end;
      output;

    data _p (keep=_line level ci c1-c&nby. ctotal pvalue p1-p7);
      merge _t _f; by _merge;

    %let ln=2;
  
    data _n (keep=_line level c1-c&nby. ctotal);
      set _all end=last;
      length level $ 300;
      length c1-c&nby. ctotal $ 40;
      retain c1-c&nby. ctotal;
      level='    N';  _line=&ln;
      %if (&cn=1 & &ind=1) | &ind=7 | &ind=8 %then %do; %let ln=%eval(&ln+1); %end;
      %if &cip=1 %then %do;
        if (&by="&by1") then do; call symput("cin1",trim(left(N))); end;
        if (&by="&by2") then do; call symput("cin2",trim(left(N))); end;
      %end;
      %do i = 1 %to &nby.;
        if (&by="&&by&i.") & total^='y' then c&i.=trim(left(N));
      %end;
      if (last) then ctotal=trim(left(N));
      if (last) then output;
      
    data _nmiss (keep=_line level c1-c&nby. ctotal);
      set _all end=last;
      length level $ 300;
      length c1-c&nby. ctotal $ 40;
      retain c1-c&nby. ctotal;
      level='    Missing';  _line=&ln;
      %if (&cnmiss=1 & &ind=1) %then %do; %let ln=%eval(&ln+1); %end;
      %do i = 1 %to &nby.;
        if (&by="&&by&i.")  & total^='y' then c&i.=trim(left(Nmiss));
      %end;
      if (last) then ctotal=trim(left(N));
      if (last) then output;

    data _mean (keep=_line level c1-c&nby. ctotal);
      set _all end=last;
      length level $ 300;
      length c1-c&nby. ctotal $ 40;
      retain c1-c&nby. ctotal;
      if (&cms=2 & &ind=1) then level='    Mean';
      else if (&cms=3 & &ind=1) then level='    SD';
      else level='    Mean (SD)'; _line=&ln; 
      %if (&cms>0 & &ind=1) | &ind=8 %then %do; %let ln=%eval(&ln+1); %end;
      %if &cip=1 %then %do;
        if (&by="&by1") then do; 
          call symput("cimean1",trim(left(MEAN))); 
          call symput("cisd1",trim(left(STD))); 
        end;
        if(&by="&by2") then do;  
          call symput("cimean2",trim(left(MEAN))); 
          call symput("cisd2",trim(left(STD))); 
        end;
      %end;
      %do i = 1 %to &nby.;
        if (&by="&&by&i.")  & total^='y' then do;
           %if &cms=2 & &ind=1  %then %do; c&i.=trim(left(put(MEAN,10.1))); %end; 
           %else %if &cms=3 & &ind=1 %then %do; c&i.=trim(left(put(STD,10.2))); %end; 
           %else %do; c&i.=trim(left(put(MEAN,10.1))) || ' (' || trim(left(put(STD,10.2))) || ')'; %end;
          
        end;
      %end;
      if (last) then do;
           %if &cms=2 & &ind=1 %then %do; ctotal=trim(left(put(MEAN,10.1))); %end; 
           %else %if &cms=3 & &ind=1 %then %do; ctotal=trim(left(put(STD,10.2))); %end;  
           %else %do; ctotal=trim(left(put(MEAN,10.1))) || ' (' || trim(left(put(STD,10.2))) || ')'; %end;
          
      end;
      if (last) then output;

    data _med (keep=_line level c1-c&nby. ctotal);
      set _all end=last;
      length level $ 300;
      length c1-c&nby. ctotal $ 40;
      retain c1-c&nby. ctotal;
      level='    Median';  _line=&ln;  
      %if (&cmd=1 & &ind=1) | &ind=7 %then %do; %let ln=%eval(&ln+1); %end;
      %do i = 1 %to &nby.;
        if (&by="&&by&i.") & total^='y'  then c&i.=trim(left(put(MEDIAN,10.1)));
      %end;
      if (last) then ctotal=trim(left(put(MEDIAN,10.1)));
      if (last) then output;

    data _quart (keep=_line level c1-c&nby. ctotal);
      set _all end=last;
      length level $ 300;
      length c1-c&nby. ctotal $ 40;
      retain c1-c&nby. ctotal;
      level='    Q1, Q3'; _line=&ln;
      %if (&cq=1 & &ind=1) | &ind=7 %then %do; %let ln=%eval(&ln+1); %end;
      %do i = 1 %to &nby.;
        if (&by="&&by&i.")  & total^='y' then c&i.=trim(left(put(Q1,10.1))) || ', ' || trim(left(put(Q3,10.1)));
      %end;
      if (last) then ctotal=trim(left(put(Q1,10.1))) || ', ' || trim(left(put(Q3,10.1)));
      if (last) then output;

    data _range (keep=_line level c1-c&nby. ctotal);
      set _all end=last;
      length level $ 300;
      length c1-c&nby. ctotal $ 40;
      retain c1-c&nby. ctotal;
      level='    Range'; _line=&ln; 
      %if (&cr=1 & &ind=1) | &ind=8 %then %do; %let ln=%eval(&ln+1); %end;
      %do i = 1 %to &nby.;
        if (&by="&&by&i.")  & total^='y' then c&i.='(' || trim(left(put(MIN,10.1))) || '-' || trim(left(put(MAX,10.1))) || ')';
      %end;
      if (last) then ctotal='(' || trim(left(put(MIN,10.1))) || '-' || trim(left(put(MAX,10.1))) || ')';
      if (last) then output;

    data _blank (keep=_line level ci c1-c&nby. ctotal pvalue p1-p7);
      length level $ 300;
      length ci c1-c&nby. ctotal $ 40;
      %do i = 1 %to &nby.;  c&i.=' '; %end;
      level=' '; ci='      '; ctotal=' ';
      pvalue=' '; p1=.; p2=.;  p3=.; p4=.;  p5=.; p6=.; p7=.;
      _line=&ln;

    data _final;
      set                                                  _p 
        %if (&cn=1 & &ind=1) | &ind=7 | &ind=8 %then %do;  _n     %end;
        %if (&cnmiss=1) %then %do;                         _nmiss %end;
        %if (&cmn=1 & &ind=1) | &ind=8 %then %do;          _mean  %end;
        %if (&cmd=1 & &ind=1) | &ind=7 %then %do;          _med   %end;
        %if (&cq=1 & &ind=1) | &ind=7 %then %do;           _quart %end;
        %if (&cr=1 & &ind=1) | &ind=8 %then %do;           _range %end; 
                                                           _blank ;
      nvar=&num;
    run;

   %if &cip=1 %then %do;
     data _ci (keep=_line nvar level c1-c&nby. ci ctotal p1-p7 );
       length level $ 300;
       length c1 ci c2 c3 c4 c5 c6 c7 c8 ctotal $ 40;
       nvar=&num;
       _line=7;
       mdiff=&cimean2-&cimean1;
       se=sqrt(&cisd1*&cisd1/&cin1 + &cisd2*&cisd2/&cin2);
       lowerci=mdiff-1.96*se;
       upperci=mdiff+1.96*se;
       mdiff=round(mdiff,0.1);
       lowerci=round(lowerci,0.1);
       upperci=round(upperci,0.1);
       level="Difference (95% CI)"; 
       ci=trim(left(mdiff)) || ' (' || trim(left(lowerci)) || ', ' || trim(left(upperci)) || ')'; 
       output;
       %do i = 1 %to &nby.;  c&i.=' '; %end;
       level=' '; ci='      '; ctotal=' ';
       pvalue=' '; p1=.; p2=.;  p3=.; p4=.;  p5=.; p6=.; p7=.;
       _line=8; output;

     data _final;
       set _final _ci;
     run;
   %end;
      
    %if (&num=1) %then %do;
        data _mst;
        set _final;
    %end;
    %else %do;
       data _mst;
       set _mst _final;
    %end;
  %end;  ** end of continuous analysis **;

    /***************************************/
    /***************************************/
    /** analyses for survival variables **/
    /***************************************/
    /***************************************/

  %if (&ind=4) %then %do;
     %if &snum=0 %then %let event=&surv; 
     %else %do; %if (%scan(&surv,&snum)^=) %then %do; %let event=%scan(&surv,&snum); %let snum=%eval(&snum+1); %end; %end;
     %if &scen=0 %then %let cen_vl=&scensor;
     %else %do; %if (%scan(&scensor, %scen)^=) %then %do; %let cen_vl=%scan(&scensor,&scen); %let scen=%eval(&scen+1);
     %end; %end;

     %let time=&v1;
     %let errorflg = 0;

     %if &time=  %then %do;
       %put  ERROR - Variable <time> not defined;
       %let  errorflg = 1;
       %end;

     %if &event=  %then %do;
       %put  ERROR - Variable <event> not defined;
       %let  errorflg = 1;
       %end;

     data _tmp_;  set _master;
       keep &by &time &event;
       where &by is  not missing;
       if &time=. or &time < 0 then do;
          error "ERROR - &time= " &time ' - not used.';
          &time = .;
          &event = .;
          end;
       if &event > &cen_vl+1 or &event < &cen_vl then do;
          error "ERROR - &event= " &event ' - not used.';
          &time = .;
          &event = .;
          end;

     proc sort; by &by &time;
     proc means noprint data=_tmp_;
       var &time;
       by &by;
       output out=_counts_ n=nrisk max=maxtime nmiss=tl_miss;

     data _sumry_ (keep=&by total cum_ev cum_cen median tl_miss);
       set _tmp_ nobs=nobs; by &by &time;
       retain pt nevent _kt_ ncensor nrisk cum_ev cum_cen
              total median firstmed;
       label cum_ev = "Cumulative events including (t)"
             cum_cen = "Cumulative censors including (t)"
             median = "Median Survival"
             tl_miss = "Total Missing";

       _ft_=first.&time;
       _lt_=last.&time;

              *do if the first observation per by group;
       if first.&by=0 then go to notfirst;

       set _counts_;
       &time=0; nevent=0;
       _kt_=0; ncensor=0; cum_ev=0; cum_cen=0; pt=1;
       years=0; total=nrisk; median=.; firstmed=.;

               *do for each observation in the dataset;
       NOTFIRST:

       if _ft_ then do;  *do for the first obs. per time;
         nevent=0;
         _kt_=0;
         ncensor=0;
       end;

                         *do for each observation;
       if &time ^= . then do;
         if &event = &cen_vl+1
         then do;
           nevent=nevent+1;
         end;
         else do;
           ncensor=ncensor+1;
         end;
         _kt_=_kt_+1;
       end;

       if _lt_ then do;  *do for the last observation per time;
         if _kt_=0 then go to next3;
         if nrisk>0 then pt=pt*(1-nevent/nrisk); else pt=.;
         cum_ev = cum_ev + nevent;
         cum_cen = cum_cen + ncensor;
         nrisk=nrisk-_kt_;
         if _kt_ = 0 then go to next3;
         if ABS(pt-0.5)<=0.00001 then do;
           if firstmed = . then firstmed = &time;
         end;
         if median=. and round(pt,0.00001) < 0.5  then do;
           if firstmed ^=.
           then median = (&time + firstmed)/2.0;
           else median = &time;
         end;
                             *output summary data;
         next3:

         if last.&by=1 then output _sumry_;
       end;
     run;

     ******* outputs totals for median, etc. **********;

     proc sort data=_tmp_; by &time;
     proc means noprint data=_tmp_;
       var &time;
       output out=_counts_ n=nrisk max=maxtime nmiss=tl_miss;

     data _tot_  (keep=tottot totcumev totcen totmed tl_miss);
       set _tmp_ nobs=nobs end=end; by &time;
       retain pt nevent _kt_ ncensor nrisk totcumev totcen
              tottot totmed firstmed;
       label totcumev = "Cumulative events including (t)"
             totcen = "Cumulative censors including (t)"
             totmed = "Median Survival"
             tl_miss = "Total Missing";

       _ft_=first.&time; _lt_=last.&time;

       if _n_^=1 then go to notfirst;
       set _counts_;
       &time=0;
       nevent=0; _kt_=0; ncensor=0; totcumev=0; totcen=0;
       pt=1; years=0; tottot=nrisk; totmed=.; firstmed=.;

       NOTFIRST:
       if _ft_ then do;  *do for the first obs. per time;
         nevent=0;
         _kt_=0;
         ncensor=0;
       end;
       if &time ^= . then do;
         if &event = &cen_vl+1
         then do;
           nevent=nevent+1;
         end;
         else do;
           ncensor=ncensor+1;
         end;
         _kt_=_kt_+1;
       end;
       if _lt_ then do;  *do for the last observation per time;
         if _kt_=0 then go to next3;
         if nrisk>0 then pt=pt*(1-nevent/nrisk); else pt=.;
         totcumev = totcumev + nevent;
         totcen = totcen + ncensor;
         nrisk=nrisk-_kt_;
         if _kt_ = 0 then go to next3;
         if ABS(pt-0.5)<=0.00001 then do;
           if firstmed = . then firstmed = &time;
         end;
         if totmed=. and round(pt,0.00001) < 0.5  then do;
           if firstmed ^=.
           then totmed = (&time + firstmed)/2.0;
           else totmed = &time;
         end;
         next3:
         if end then output _tot_;
       end;
     run;

     proc sort data=_tmp_; by &by; run;

     data _sumry_;
       set _sumry_ end=last; by &by;
       line_num=put(_n_,3.);

     data _tmp_;
       merge _sumry_ (in=in1) _tmp_(in=in2);  by &by;
       keep &by &time &event line_num;
       if in1 and in2;

     %survlrk(data=_tmp_,time=&time,death=&event,
                censor=&cen_vl,strata=line_num,out=_x1);

     data _sumry_;
       merge _x1 (in=in1) _sumry_(in=in2);  by line_num;
       format observed expected o_e 8.1 rr 5.3
              chisq 8.2 pvalue 8.4;
       drop line_num;
       if in1 and in2;
       if chisq = 0 then pvalue=.N;
     run;

    proc transpose data=_sumry_ out=_tmp_;
      var total cum_ev median;
    run;

    proc transpose data=_tot_ out=_tmp1_ prefix=val;
      var tottot totcumev totmed;
    run;

    data _t;
     length level $ 300;
     length ci c1-c&nby. ctotal $ 40;
     _merge=1;
     level="&v1lbl"; _line=1;
     ci='      '; ctotal=' ';
     %do i = 1 %to &nby.;  c&i.=' '; %end;
     output;


    data _p (keep=pval _merge);
      set _sumry_;
      _merge=1;
      if pvalue^=. then do;
        if pvalue<&ppct. then do;
            %if &pfoot=Y %then %do; pval="<&ppct.~{super &pnum8}"; %end; %else %do; pval="<&ppct."; %end;
        end; else do; %if &pfoot=Y %then %do; pval=put(round(pvalue,&ppct.),6.&pdec.) || "~{super &pnum8}"; %end;
                   %else %do; pval=put(round(pvalue,&ppct.),6.&pdec.); %end; 
        end;
        output;
      end;
   
    data _tot (keep=_line level ci c1-c&nby. ctotal pvalue _merge);
      merge _t _p; by _merge;
      pvalue=pval;

    data _tmp_; set _tmp_; _merge=1; run;
    data _tmp1_; set _tmp1_; _merge=1; run;
    
    data _all (keep=_line level c1-c&nby. ctotal _merge);
      merge _tmp_ _tmp1_; by _merge;
      length level $ 300;
      length c1-c&nby. ctotal $ 40;
      retain c1-c&nby. ctotal;
      if _n_=1 then do;
        level='    Number of Patients'; _line=2;
        tot=0;
        %do i = 1 %to &nby.;
          %let ii=%eval(&i+1);
          %if (&by1=) %then %do; c&ii.=trim(left(col&i)); %end;
          %else %do; c&i.=trim(left(col&i)); %end;
        %end;
        ctotal=trim(left(val1));
        output;
      end;
      if _n_=2 then do;
        level='    Number of Events'; _line=3;
        tot=0;
        %do i= 1 %to &nby.;
          %let ii=%eval(&i+1);
          %if (&by1=) %then %do; c&ii.=trim(left(col&i)); %end;
          %else %do; c&i.=trim(left(col&i)); %end;
        %end;
        ctotal=trim(left(val1));
        output;
      end;
      if _n_=3 then do;
        level='    Median Survival Time'; _line=4;
        %do i= 1 %to &nby.;
          %let ii=%eval(&i+1);
          %if (&by1=) %then %do; c&ii.=trim(left(col&i)); %end;
          %else %do; c&i.=trim(left(col&i)); %end;
        %end;
        ctotal=trim(left(val1));
        output;
      end;

    data _blank (keep=_line level ci c1-c&nby.
                      ctotal pvalue p1-p7 _merge);
      length level $ 300;
      length ci c1-c&nby. ctotal $ 40;
      _merge=1;
      %do i = 1 %to &nby.;  c&i.=' '; %end;
      level=' '; ci='      '; ctotal=' ';
      pvalue=' '; p1=.; p2=.;  p3=.; p4=.;  p5=.; p6=.; p7=.;
      _line=6;

    data _final;
      set _tot _all _blank;
      by _merge;
      nvar=&num;

    %if (&num=1) %then %do;
        data _mst;
        set _final;
    %end;
    %else %do;
       data _mst;
       set _mst _final;
    %end;

  %end; ** end of survival analysis **;


  %if (&debug=Y) %then %do;
    %put _all_;

    proc print data=_final;
      title '_final';

    proc print data=_mst;
      title '_mst';
  %end;

  %end; *end of errorvar - skips analysis if the variable does not exist;

  /******************************/
  /* reads in the next variable */
  /******************************/
  %let num=%eval(&num+1);
  %let v1=%upcase(%scan(&var,&num));
  %let indold=&ind;
  %let ind=%scan(&type,&num);
  %if (&ind=) %then %do; %let ind=&indold; %end;
  %if "&ptype"^="" %then %let pval=%scan(&ptype,&num);                  /* ptype=type of pvalue desired */
  %if "&ptype"="" %then %if &ind=1 | &ind=7 | &ind=8 %then %let pval=3;
  %else %if &ind=3 %then %let pval=5;
  %else %let pval=1;
  

  %if (&v1^=) & ( &pval>0 & &pfoot=Y) %then %do;
  %if &&pt&pval=0 %then %do;
    %let pt&pval=1;
    %let pfnum=%eval(&pfnum+1);
    %let pnum&pval=&pfnum;
    %let pft=&pft ~{super &pfnum}&&pnm&pval;
  %end; %end;
     
  
%end;

%let num=%eval(&num-1);


/********************************/
/* removes the final blank line */
/********************************/
data _mst;
  set _mst end=last;
  if (last) then delete;


/**************************************/
/* adds in any comments for the table */
/* and deletes specified lines        */
/**************************************/

data _mst;
  set _mst %if (&comments^=) %then %do; &comments %end; ;
  %do i = 1 %to 50;
    %let vr=%scan(&dvar,&i);
    %let dl=%scan(&dline,&i);
    %if (&vr^=) %then %do;
      if (&vr=nvar) & (&dl=_line) then delete;
    %end;
    %else %do; %let i = 50; %end;
  %end;

proc sort data=_mst;
  by nvar _line;

/*
proc print data=_mst noobs;
  var nvar _line level c1-c&nby. ctotal p1 p2 p3 p4 p5 p6 p7;
  title 'list of final dataset';
  run;
*/

/******************************/
/* creates the table template */
/******************************/
proc template;
  define style newtable;
  style cellcontents /
     nobreakspace=on
     font_face="&bodyfnt."
     font_weight=medium
     font_style=roman
     font_size=&bodysz. pt
     just=center
     vjust=center
     asis=on
     font_size=1;
  style lhead /
     nobreakspace=on
     font_face="&headfnt."
     font_weight=bold
     font_size=&bodysz. pt
     font_style=roman
     just=center
     vjust=center
     asis=on
     font_size=1;
  style table /
     frame=&frame
     asis=on
     cellpadding=&space.
     cellspacing=&space.
     just=center
     rules=&rules
     borderwidth=2;
  style Body /
     font_face="&headfnt."
     asis=on
     font_size=&bodysz. pt;
  style BodyDate /
     font_face="&headfnt."
     asis=on
     font_size=&bodysz. pt;
  style SysTitleAndFooterContainer /
     font_face="&headfnt."
     asis=on
     font_size=&bodysz. pt;
  style SystemFooter /
     font_face="&headfnt."
     asis=on
     font_size=&bodysz. pt;
  style data /
     font_face="&headfnt."
     font_size=&bodysz. pt;
  style SystemTitle /
     font_face="&headfnt."
     font_size=&bodysz. pt;
  style ByLine /
     font_face="&headfnt."
     asis=on
     font_size=&bodysz. pt;
  style Header /
     font_face="&headfnt."
     asis=on
     font_size=&bodysz. pt;
  end;
  run;


%if ("&outdoc"^="") %then %do;

ods listing close;

options orientation=&page.;

%if "&doctype"="0" %then %do; ods rtf file="&outdoc..doc" style=newtable; %end;
%else %do; ods rtf file="&outdoc." style=newtable; %end;


%if &pfoot=Y %then %do; ods escapechar='~'; %end;

title ' ';

%let titles=&ttitle1;
%if "&ttitle2"^="" %then %do; %let titles=&titles.#&ttitle2.; %end;
%if "&ttitle3"^="" %then %do; %let titles=&titles.#&ttitle3.; %end;
%if "&ttitle4"^="" %then %do; %let titles=&titles.#&ttitle4.; %end;
%if &date=Y %then %do; %let fdate=(report generated on " sysdate9 "); %end; %else %do; %let fdate=; %end;


proc template;
  define table summ;
  mvar sysdate9;
  column level c1 c2-c&nby. ci ctotal pvalue;
  header table_header_1;
  footer table_footer_1 table_footer_2;
  define table_header_1;
     text "&titles.# ";
     style=header{font_size=&titlesz. pt font_face="&titlefnt." %if &titlebld=Y %then %do; font_weight=bold %end; };
     split='#';
  end;
  define table_footer_1;
     %if (&date=Y) | ("&foot"^="") | &pfoot=Y %then %do; 
       %if &pfoot=Y %then %do; text " &fdate#&pft#&foot"; %end;
       %else %do; text " &fdate#&foot"; %end;
     %end; %else %do; text ""; %end;
     split='#';
     just=left;
     style=header{font_size=&footsz. pt font_face="&headfnt."};
  end;
  
  define table_footer_2;
     %if ("&foot2"^="") | ("&foot3"^="") | ("&foot4"^="") | ("&foot5"^="") %then %do; text " &foot2#&foot3#&foot4#&foot5"; %end; 
       %else %do; text ""; %end;
     split='#';
     just=left;
     style=header{font_size=&footsz. pt font_face="&headfnt."};
  end;

  define header header;
     split='#';
  end;
  define column level;
         generic=on;
         vjust=top;
         just=left;
         header=" ";
         cellstyle substr(_val_,1,1)^=' ' as
           cellcontents{font_weight=bold   font_size=&bodysz. pt font_face="&headfnt." 
           %if (&levelwd^=) %then %do; cellwidth=&levelwd. %end; },
         substr(_val_,1,1)=' ' as
           cellcontents{font_weight=medium font_size=&bodysz. pt font_face="&headfnt."
           %if (&levelwd^=) %then %do; cellwidth=&levelwd. %end; };
  end;

  %do i = 1 %to &nby.;
    define column c&i.;
         generic=on;
         style=cellcontents{font_size=&bodysz. pt font_face="&bodyfnt."
                            %if (&datawd^=) %then %do; cellwidth=&datawd. %end; };
         vjust=top;
         just=center;
         %if (&&by&i.=) %then %do;
           header="Missing                                     (N=&&byn&i.)";
         %end;
         %else %do;
           header="&&fby&i.                                        (N=&&byn&i.)";
         %end;
         end;
  %end;

  define column ci;
         generic=on;
         style=cellcontents{font_size=&bodysz. pt font_face="&bodyfnt."
                            %if (&ciwd^=) %then %do; cellwidth=&ciwd. %end; };
         vjust=top;
         just=center;
         header=" ";
         end;

  define column ctotal;
         generic=on;
         style=cellcontents{font_size=&bodysz. pt font_face="&bodyfnt."
                            %if (&datawd^=) %then %do; cellwidth=&datawd. %end; };
         vjust=top;
         just=center;
         header="Total                                       (N=&nobs.)";
         end;
  define column pvalue;
         generic=on;
         style=cellcontents{font_size=&bodysz. pt font_face="&bodyfnt."
                            %if (&pvalwd^=) %then %do; cellwidth=&pvalwd. %end; };
         vjust=top;
         just=center;
         header="p value";
         end;
  end;
  run;

  data _null_;
    set _mst;

    file print ods=(template='summ'
         columns=(level=level(generic=on)
                 %do i = 1 %to &nby.;
                    c&i.=c&i.(generic=on)
                 %end;
                 %if (&ci^=) %then %do;  ci=ci(generic=on) %end;
                 %if (&total=Y)   %then %do;  ctotal=ctotal(generic=on)  %end;
                 %if (&pvalues=Y) %then %do;  pvalue=pvalue(generic=on)  %end;
                 ));
    put _ods_;
    run;

  ods rtf close;
  ods listing;
  
  %if "&doctype"="0" %then %do; %put Created File: &outdoc..doc; %end;
  %else %do; %put Created File: &outdoc.; %end;

%end;

/**************************/
/* prints the final table */
/**************************/
options linesize=128 pagesize=56;
%if &print=Y %then %do;
  ods trace on;
  proc print data=_mst label noobs split='*';
    var %if (&debug=Y) %then %do;  nvar _line  %end;
        level c1-c&nby 
                 %if (&ci^=) %then %do;  ci %end;
                 %if (&total=Y)   %then %do;  ctotal  %end;
                 %if (&pvalues=Y) %then %do;  pvalue  %end;;
    title "&ttitle1";
    %if "&ttitle2"^="" %then %do; title2 "&ttitle2"; %end;
  run;
  ods trace off;

%end;

%if (&outdat^=) %then %do;
  data &outdat;
    length tit1-tit4 ft1-ft5 $100. ;
    set _mst;
    tit1=''; tit2=''; tit3=''; tit4=''; ft1=''; ft2=''; ft3=''; ft4=''; ft5='';
    if _n_=1 then do;
      oldline=_line;
      _line=0; 
      nby=&nby;
      %do i = 1 %to &nby.; byn&i.=&&byn&i; 
      %if &bytype=num %then %do; %if (&&by&i.^=) %then %do; by&i=&&by&i; %end; %end;
      %else %if &bytype=char %then %do; by&i="&&by&i"; %end; fby&i="&&fby&i"; %end;
      nobs=&nobs.; pfoot="&pfoot"; %if &pfoot=Y %then %do; pft="&pft"; %end;
      tit1="&ttitle1"; tit2="&ttitle2"; tit3="&ttitle3"; tit4="&ttitle4";
      ft1="&foot"; ft2="&foot2"; ft3="&foot3"; ft4="&foot4"; ft5="&foot5";
      %if (&date=Y) %then %do; fdate="Y"; %end; %else %do;  fdate="N"; %end;
      %if (&ci=) %then %do; haveci=0; %end;  %else %do; haveci=1; %end;  
      %if (&total=N)   %then %do; havetot=0; %end; %else %do; havetot=1; %end; 
      %if (&pvalues=N) %then %do; havep=0; %end; %else %do;havep=1; %end; 
      output;
      _line=oldline;
    end;
    output;
  run;
%end;

/*************************************/
/* cleans up the temporary data sets */
/*************************************/
 proc datasets nolist;
    delete _c2_ _check _c_ _d01 _d02 _d1 _d2 _dall _f1 _n _f _e _e0
          _final _level _master _mst _tmp _tmp_ _sumry_ _x1
          _t _all _tot _p _mean _med _range _blank _tot_
          _counts_ _lr1 _lr2 _lrmstr _tmp1_ _nmiss _quart;
    run;
    quit;

run;


%end;
%else %do; %put ERROR: &errorwhy; %end;

options validvarname=&validvn &sdate &snotes &snumb;

%mend stat_table;
endrsubmit;
