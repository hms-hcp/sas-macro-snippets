*--------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA   |
|--------------------------------------------------------------------------|
| File Name      = progname.sas                                            |
| Path or URL    = /usr/apps/sas/maclib/                                   |
| Version        =                                                         |
| Creation Date  = 08 Mar 2006                                             |
| Author         = Matthew J Cioffi                                        |
| Affiliation    = HCP                                                     |
| Category       = Utility                                                 |
| Keys           =                                                         |
|                                                                          |
|--------------------------------------------------------------------------|
| Brief Description: (1-2 sentences)                                       |
|--------------------------------------------------------------------------|
   Get the file name for the most current SAS program from the SQL 
   dictionary files.
*--------------------------------------------------------------------------*;
*--------------------------------------------------------------------------*
| Modified Date  = DD MMM YYYY                                             |
| By Whom        =                                                         |
| Reason:
   
*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------|
| Full Description: (1-2 sentences)                                        |
|--------------------------------------------------------------------------|
   Utilizing the SQL SAS dictionary file SAS jobs, creates 2 FOOTNOTE 
   statements identifing program name, user and system start date as well 
   as a standard TITLE for the department.  It will Make available the 
   following macro libraries:
       - /usr/apps/sas/maclib
       - maclib directory in your home directory. H: or /home/username
       - any directory with the name maclib within 3 levels from 
         current program working directory

   It also maps the shared SAS data library and HCP options.
 *--------------------------------------------------------------------------*;

%macro progname() ; 
	%put HCP NOTE:  Start Macro progname ;
	%global
		_pathfile
		_pathname
		_filename
	;
	%local
		refnum
		filespec
		revtext
		slash
    ;
%if &sysscp = WIN %then %do ;
    %let slash  = \ ;
%end ;
%else %do ;
    %let slash  = / ;
%end ;

	proc sql noprint;
	%*------------------------------------------------------------------
     Get the last file reference that contains a SAS source file.
     The highest-numbered _TMP file should contain the string .sas
     *------------------------------------------------------------------- ;
		select max( fileref ) into :refnum
		from dictionary.extfiles
		where index( xpath, ".sas" ) > 0;

	%*------------------------------------------------------------------
     Get the path and file name of the sas file from XPATH in the SQL
     table dictionary.extfiles and save as filespec.
     *------------------------------------------------------------------- ;
	%if &refnum ^= %then %do ;
		select xpath into :filespec
		from dictionary.extfiles
		where fileref = "&refnum";
		%let _pathfile = %trim(&filespec);
	%end ;
	%else %do ;
		%let _pathfile = _NOFILENAME_ ;
  	%end ;
	quit ;
	%*------------------------------------------------------------------
     Now exract path and file name and print to log file the values of
     the global variables storing the info.
     *------------------------------------------------------------------- ;
	%if "&_pathfile" = _NOFILENAME_ %then %do ;
		%let _pathname = _NOFILENAME_ ;
		%let _filename = _NOFILENAME_ ;
	%end ;
	%else %do ;
		data _null_ ;
			length _filename _pathname revtext $ 132;
			revtext = trim(reverse( trim("&_pathfile") ));
			i = indexc( revtext, "&slash." );
			if i > 0 then do ;
				_filename = reverse( substr( revtext, 1, i-1 )) ;
				_pathname = reverse( substr( revtext, i )) ;
			end ;
			call symput ( '_filename', left( trim(_filename)) );
			call symput ( '_pathname', left( trim(_pathname)) );
		run ;
	%end ;

	%put The following GLOBAL Variables have been assigned by the macro: ;
	%put   _pathfile = &_pathfile ;
	%put   _pathname = &_pathname ;
	%put   _filename = &_filename ;
%mend progname;
