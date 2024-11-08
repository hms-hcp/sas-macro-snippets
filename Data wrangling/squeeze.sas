*--------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA   |
|--------------------------------------------------------------------------|
| File Name      =squeeze.sas                                              |
| Path or URL    = /usr/apps/sas/maclib/                                   |
| Version        =  1                                                      |
| Creation Date  = 02 08 2012                                              |
| Author         = Ross Bettinger,                                         |
|               Sample 267: %SQUEEZE-ing before Compressing Data, Redux.7  |
|       Jul. 2006 <http://support.sas.com/ctx/samples/index.jsp?sid=267>   |
|                                                                          |
| Affiliation    = NESUG                                                   |
| Category       = Working with SAS Data                                   |
| Keys           =                                                         |
|                                                                          |
|--------------------------------------------------------------------------|
| Brief Description: Reduces the length of character and numeric variables |
|--------------------------------------------------------------------------|
*--------------------------------------------------------------------------*;
*--------------------------------------------------------------------------*
| Update Information: Repeat below fields for each update                  |
|--------------------------------------------------------------------------|
| Modified Date  = DD MMM YYYY                                             |
| By Whom        =                                                         |
| Reason:
*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| DISCLAIMER:                                                              |
|--------------------------------------------------------------------------|
   The information contained within this file is provided "AS IS" by the
Department of Health Care Policy (HCP), Harvard Medical School, as a 
service to the HCP Programmers Group and the Department's other users of
SAS.  There are no warranties, expressed or implied, as to the
merchantability or fitness for a particular purpose regarding the accuracy
of the materials or programming code contained herein. This macro may be
distributed freely as long as all comments, headers and related files are
included.
   Copyright (C) 2005 by The Department of Health Care Policy, Harvard 
Medical School, Boston, MA, USA. All rights reserved.
*--------------------------------------------------------------------------*;
*--------------------------------------------------------------------------*
| Full Description: 
| The Macro redefines the lengths of character and numeric variables to the 
|  smallest length that holds the values without loosing precision (in case
| of numeric variables) and non blanck characters.
| For numeric variable the macro uses the following algorithm:
|        Repeatedly remove 1 byte from each numeric
|        variable until value stored in (n-1) bytes ���� value
|         stored in (n) bytes.                                                  
| For the full explanation of how the numeric values are stored
| refer to a presenation at for the programmers meetinfg on Feb 8 2012
| SquizeMacro.pdf
|--------------------------------------------------------------------------|
   
*--------------------------------------------------------------------------*
| Instructions: The description of parameters are below included in the
|   macro call. Please be careful of using the same variables in further 
|   computations, or converting several files that need to be put together
|                                                           |
|--------------------------------------------------------------------------|
*--------------------------------------------------------------------------*;
*--------------------------------------------------------------------------*
| Macro Code Begins Here.                                                  |
*--------------------------------------------------------------------------*;

%macro SQUEEZE( DSNIN       /* name of input SAS dataset  */
              , DSNOUT      /* name of output SAS dataset  */
              , NOCOMPRESS= /* [optional] variables to be omitted from the 
                               minimum-length computation process */
              ) ;

/* PURPOSE: create LENGTH statement for vars that minimizes the variable length to
*     numeric vars: the fewest # of bytes needed to exactly represent the 
                      values contained in the variable
*
*    character vars: the fewest # of bytes needed to contain the longest 
                      character string
*
*          macro variable SQZLENTH is created which is then invoked in a
*          subsequent data step
*
* NOTE:    if no char vars in dataset, produce no char var processing code
*
* NOTE:    length of format for char vars is changed to match computed length of char var
*          e.g., if length( CHAR_VAR ) = 10 after %SQUEEZE-ing, then FORMAT CHAR_VAR $10. ; is generate
*
* NOTE:    variables in &DSNOUT are maintained in same order as in &DSNIN
*
* NOTE:    variables named in &NOCOMPRESS are not included in the minimum-length computation process
*          and keep their original lengths as specified in &DSNIN
 *
* EXAMPLE OF USE:
*          %SQUEEZE( DSNIN, DSNOUT )
*          %SQUEEZE( DSNIN, DSNOUT, NOCOMPRESS=A B C D--H X1-X100 )
*          %SQUEEZE( DSNIN, DSNOUT, NOCOMPRESS=_numeric_          )
*          %SQUEEZE( DSNIN, DSNOUT, NOCOMPRESS=_character_        )
*/
   %global SQUEEZE ;
   %local I ;

   %if "&DSNIN" = "&DSNOUT"
   %then %do ;
      %put /------------------------------------------------\ ;
      %put | ERROR from SQUEEZE:                            | ;
      %put | Input Dataset has same name as Output Dataset. | ;
      %put | Execution terminating forthwith.               | ;
      %put \------------------------------------------------/ ;

      %goto L9999 ;
   %end ;

   /*############################################################################*/
   /* begin executable code
   /*############################################################################*/

   /*============================================================================*/
   /* create dataset of variable names whose lengths are to be minimized
   /* exclude from the computation all names in &NOCOMPRESS
   /*============================================================================*/

   proc contents data=&DSNIN( drop=&NOCOMPRESS ) memtype=data noprint out=_cntnts_( keep= name type ) ; run ;

   %let N_CHAR = 0 ;
   %let N_NUM  = 0 ;

   data _null_ ;
      set _cntnts_ end=lastobs nobs=nobs ;

      if nobs = 0 then stop ;

      n_char + ( type = 2 ) ;
      n_num  + ( type = 1 ) ;

      /* create macro vars containing final # of char, numeric variables */

      if lastobs
      then do ;
         call symput( 'N_CHAR', left( put( n_char, 5. ))) ;
         call symput( 'N_NUM' , left( put( n_num , 5. ))) ;
      end ;
   run ;

   /*============================================================================*/
   /* if there are NO numeric or character vars in dataset, stop further processing
   /*============================================================================*/

   %if %eval( &N_NUM + &N_CHAR ) = 0
   %then %do ;
      %put /----------------------------------\ ;
      %put | ERROR from SQUEEZE:              | ;
      %put | No variables in dataset.         | ;
      %put | Execution terminating forthwith. | ;
      %put \----------------------------------/ ;

      %goto L9999 ;
   %end ;

   /*============================================================================*/
   /* put global macro names into global symbol table for later retrieval
   /*============================================================================*/

   %do I = 1 %to &N_NUM ;
      %global NUM&I NUMLEN&I ;
   %end ;

   %do I = 1 %to &N_CHAR ;
      %global CHAR&I CHARLEN&I ;
   %end ;

   /*============================================================================*/
   /* create macro vars containing variable names
   /* efficiency note: could compute n_char, n_num here, but must declare macro names to be global b4 stuffing them
   /*
   /* note: if no char vars in data, do not create macro vars
   /*============================================================================*/

   proc sql noprint ;
      %if &N_CHAR > 0 %then %str( select name into :CHAR1 - :CHAR&N_CHAR from _cntnts_ where type = 2 ; ) ;

      %if &N_NUM  > 0 %then %str( select name into :NUM1  - :NUM&N_NUM   from _cntnts_ where type = 1 ; ) ;
   quit ;

   /*============================================================================*/
   /* compute min # bytes (3 = min length, for portability over platforms) for numeric vars
   /* compute min # bytes to keep rightmost character for char vars
   /*============================================================================*/

   data _null_ ;
      set &DSNIN end=lastobs ;

      %if &N_NUM  > 0 %then %str ( array _num_len_  ( &N_NUM  ) 3 _temporary_ ; ) ;

      %if &N_CHAR > 0 %then %str( array _char_len_ ( &N_CHAR ) _temporary_ ; ) ;

      if _n_ = 1
      then do ;
         %if &N_CHAR > 0 %then %str( do i = 1 to &N_CHAR ; _char_len_( i ) = 0 ; end ; ) ;

         %if &N_NUM  > 0 %then %str( do i = 1 to &N_NUM  ; _num_len_ ( i ) = 3 ; end ; ) ;
      end ;

      %if &N_CHAR > 0
      %then %do ;
         %do I = 1 %to &N_CHAR ;
            _char_len_( &I ) = max( _char_len_( &I ), length( &&CHAR&I )) ;
         %end ;
      %end ;

      %if &N_NUM > 0
      %then %do I = 1 %to &N_NUM ;
         if &&NUM&I ne .
         then do ;
            if &&NUM&I ne trunc( &&NUM&I, 7 ) then _num_len_( &I ) = max( _num_len_( &I ), 8 ) ; else
            if &&NUM&I ne trunc( &&NUM&I, 6 ) then _num_len_( &I ) = max( _num_len_( &I ), 7 ) ; else
            if &&NUM&I ne trunc( &&NUM&I, 5 ) then _num_len_( &I ) = max( _num_len_( &I ), 6 ) ; else
            if &&NUM&I ne trunc( &&NUM&I, 4 ) then _num_len_( &I ) = max( _num_len_( &I ), 5 ) ; else
            if &&NUM&I ne trunc( &&NUM&I, 3 ) then _num_len_( &I ) = max( _num_len_( &I ), 4 ) ;
         end ;
      %end ;

      if lastobs
      then do ;
         %if &N_CHAR > 0
         %then %do ;
            %do I = 1 %to &N_CHAR ;
               call symput( "CHARLEN&I", put( _char_len_( &I ), 5. )) ;
            %end ;
         %end ;

         %if &N_NUM > 0
         %then %do I = 1 %to &N_NUM ;
            call symput( "NUMLEN&I", put( _num_len_( &I ), 1. )) ;
         %end ;
      end ;
   run ;

   proc datasets nolist ; delete _cntnts_ ; run ;

   /*============================================================================*/
   /* initialize SQZ_NUM, SQZ_CHAR global macro vars
   /*============================================================================*/

   %let SQZ_NUM      = LENGTH ;
   %let SQZ_CHAR     = LENGTH ;
   %let SQZ_CHAR_FMT = FORMAT ;

   %if &N_CHAR > 0
   %then %do I = 1 %to &N_CHAR ;
         %let SQZ_CHAR     = &SQZ_CHAR %qtrim( &&CHAR&I ) $%left( &&CHARLEN&I ) ;
         %let SQZ_CHAR_FMT = &SQZ_CHAR_FMT %qtrim( &&CHAR&I ) $%left( &&CHARLEN&I ). ;
   %end ;

   %if &N_NUM > 0
   %then %do I = 1 %to &N_NUM ;
      %let SQZ_NUM = &SQZ_NUM %qtrim( &&NUM&I ) &&NUMLEN&I ;
   %end ;

   /*============================================================================*/
   /* build macro var containing order of all variables
   /*============================================================================*/

   data _null_ ;
      length retain $32767 ;
      retain retain 'retain ' ;

      dsid = open( "&DSNIN", 'I' ) ; /* open dataset for read access only */

      do _i_ = 1 to attrn( dsid, 'nvars' ) ;
         retain = trim( retain ) || ' ' || varname( dsid, _i_ ) ;
      end ;

      call symput( 'RETAIN', retain ) ;
   run ;

   /*============================================================================*/
   /* apply SQZ_* to incoming data, create output dataset
   /*============================================================================*/

   data &DSNOUT ;
      &RETAIN ;
      
      %if &N_CHAR > 0 %then %str( &SQZ_CHAR ;     ) ; /* optimize char var lengths      */

      %if &N_NUM  > 0 %then %str( &SQZ_NUM ;      ) ; /* optimize numeric var lengths   */

      %if &N_CHAR > 0 %then %str( &SQZ_CHAR_FMT ; ) ; /* adjust char var format lengths */

      set &DSNIN ;
   run ;

%L9999:

%mend SQUEEZE ;
