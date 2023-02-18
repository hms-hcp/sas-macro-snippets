%macro NSOURCE;

/*-----------------------------------------*/
/*                                         */
/* NAME:  NSOURCE                          */
/*                                         */
/* TYPE:  SAS MACRO                        */
/*                                         */
/* DESC:  Create global parm NSOURCE that  */
/*        contains the full path and name  */
/*        of the SAS program that created  */
/*        a job.  The logic is stolen      */
/*        from Ed Rosens AUTOID macro      */
/*                                         */
/* MODS: 05/01/01  - New (mr)              */
/*                                         */
/*-----------------------------------------*/

%global NSOURCE;    
proc sql;

      reset noprint;

        /* ------------------------------------
               * Establish file reference which
               * contains SAS source file.  This is
               * the highest-numbered '_TMP' file
               * that contains the string '.sas'.
               * ------------------------------------ */
            select max( fileref ) into :REF
              from dictionary.extfiles
              where index( xpath, '.sas' ) > 0;

          /* ------------------------------------
                 * The full file specification of the
                 * SAS source file is found in the
                 * column called XPATH in the table
                 * called DICTIONARY.EXTFILES.  The
                 * contents of this column is loaded
                 * into the local MACRO symbol SOURCE.
                 * ------------------------------------ */
                    select xpath into :SOURCE
                from dictionary.extfiles
                where fileref = "&REF.";

            /* ------------------------------------
                   * Build FOOTNOTE statement.
                   * ------------------------------------ */
                    %let NSOURCE=%trim(&source);   /* mod erosen 6/14/00 */ 
%mend;
