*--------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA   |
|--------------------------------------------------------------------------|
| File Name      = autoid.sas                                              |
| Path or URL    = /net/elektra/export/apps/sas/maclib/                    |
| Version        =                                                         |
| Creation Date  = 07 Jun 1999                                             |
| Author         =                                                         |
| Affiliation    = HCP                                                     |
| Category       = Utility                                                 |
| Keys           =                                                         |
|                                                                          |
|--------------------------------------------------------------------------|
| Brief Description: (1-2 sentences)                                       |
|--------------------------------------------------------------------------|
   Set-up macro for ALL Windows and Unix SAS jobs run on the internal HCP
   network. It includes standard FOOTNOTE/TITLE statements with program 
   name, user who ran code, and system start date for code run.
*--------------------------------------------------------------------------*;
*--------------------------------------------------------------------------*
* Edit history
 * 001 Original AutoID modified for DM
 * 002 Add parameter to set footnote number
 * 003 Concatonate current directory to macro search
 * 004 Place common SASAutos
*--------------------------------------------------------------------------*;
*--------------------------------------------------------------------------*
| Modified Date  = 08 Mar 2006                                             |
| By Whom        = Matthew J. Cioffi                                       |
| Reason:
   - Modifiy to work in Windows and Unix, using &sysscp.
   - Cleaned up code for setting sasautos search path for the /maclib
   directories in upto three higher levels.
   - Moved footnote 2 and title out of hcplib macro to here, so
   they will be sequential and also integrated the shared data library
   libname statment and format library search path in this macro.  This
   macro no longer needs to use hcplib.sas.
*--------------------------------------------------------------------------*
| Modified Date  = 19 Apr 2006                                             |
| By Whom        = Matthew J. Cioffi                                       |
| Reason:
   - Add win extension to format library for Windows SAS.
*--------------------------------------------------------------------------*
| Modified Date  = 27 Apr 2007                                             |
| By Whom        = Matthew J. Cioffi                                       |
| Reason:
   - Add in brfss folder to datalib libname.
*--------------------------------------------------------------------------*
| Modified Date  = 04 Nov 2007                                             |
| By Whom        = Matthew J. Cioffi                                       |
| Reason:
   - Add format catalog for SUN X64 version of SAS.
*--------------------------------------------------------------------------*;
*--------------------------------------------------------------------------*
| Modified Date  =   07 Nov 2007                                           |
| By Whom        = Rita Volya                                              |
| Reason:
   - allow footnotes with the program name continue on the 2nd line
*--------------------------------------------------------------------------*;
*--------------------------------------------------------------------------*
| Modified Date  = 12 Apr 2016                                             |
| By Whom        = Rita Volya                                              |
| Reason: macro library changed location                                   |
*--------------------------------------------------------------------------*;
*--------------------------------------------------------------------------|
| Full Description: (1-2 sentences)                                        |
|--------------------------------------------------------------------------|
   Set-up macro for ALL Windows and Unix SAS jobs, creates 2 FOOTNOTE
   statements identifing program name, user and system start date as well
   as a standard TITLE for the department.  It will Make available the
   following macro libraries:
       - /usr/apps/sas/maclib
       - maclib directory in your home directory.
         H:\maclib or /home/username/maclib
       - any directory with the name maclib within 3 levels from
         current program working directory

   It also maps the shared SAS data library and HCP options.
 *--------------------------------------------------------------------------*;

%macro autoid(N);
  %put HCP NOTE:  Start Macro autoid ;
  %local
    home
    N2
    pmaclib
    ref
    source
    saspgm
    cpath mpath ypath zpath
    ;
%if &sysscp = WIN %then %do ;
    %let home=H: ;
    %let pmaclib=W:\SASlib ;
    %let slash  = \ ;
%end ;
%else %do ;
    %let home=%sysget(HOME) ;
%let pmaclib=/net/moses/export/apps/sas/maclib;
/*/net/carmen/export/apps/sas/maclib;*/
/*%let pmaclib=/net/elektra/export/apps/sas/maclib;*/
                      /*/usr/apps/sas/maclib ;*/

    %let slash  = / ;
%end ;

  %if &N ^= %then %do;
  %end;
  %else %do;
      %let N = 1;
  %end;
  %let N2 = %eval(&N+1) ;

  proc sql noprint;

    /* ------------------------------------------------------------------
     * Establish file reference which contains SAS source file.  This is
     * the highest-numbered _TMP file that contains the string .sas
     * ------------------------------------------------------------------- */

    select max( fileref ) into :ref
    from dictionary.extfiles
    where index( xpath, ".sas" ) > 0;

    /* -------------------------------------------------------------------
     * The full file specification of the SAS source file is found in the
     * column called XPATH in the table called DICTIONARY.EXTFILES.  The
     * contents of this column is loaded into the local MACRO SOURCE.
     * -------------------------------------------------------------------- */
  %if &ref ^= %then %do ;
    select xpath into :source
    from dictionary.extfiles
    where fileref = "&ref.";

    %let saspgm = %trim(&source);
  %end ;
  %else %do ;
    %let saspgm = &home.&slash._NoProgram_.sas ;
  %end ;

quit ;

  /* ------------------------------------
   * Build FOOTNOTE and TITLE statements
   * ------------------------------------ */

  title&N.     "Health Care Policy - Harvard Medical School" ;
  footnote&N.  "Created by: &saspgm.." ;
  %let ln=%length(&saspgm);
  %if &ln>67 %then %do;
   %let N2=%eval(&N2+1);
   %let newn=%eval(&N+1);
   %let saspgm2=%substr(&saspgm,68);
   %let saspgm=%trim(%substr(&saspgm,1,67));
   footnote&N.  "Created by: &saspgm" ;
   footnote&newn.  "&saspgm2.." ;
  %end;
  footnote&N2. "User &sysuserid - SAS Version &sysver (&sysscp) - &sysday, &sysdate9" ;

  /* ------------------------------------
   * Extract path from full file name
   * ------------------------------------ */

  data _null_ ;
    length cpath crev mpath ypath zpath $ 132;
    crev = trim(reverse( trim("&saspgm") ));

    i = indexc( crev, "&slash." );
    if i > 0 then do ;
        crev = substr( crev, i+1 ) ;
        cpath = trim( reverse( trim(crev)) || "&slash.maclib" ) ;
    end ;
    else cpath = "" ;

    i = indexc( crev, "&slash." );
    if i > 0 then do ;
        crev = substr( crev, i+1 ) ;
        mpath = trim( reverse( trim(crev)) || "&slash.maclib" ) ;
    end ;
    else mpath = "" ;

    i = indexc( crev, "&slash." );
    if i > 0 then do ;
        crev = substr( crev, i+1 ) ;
        ypath = trim( reverse( trim(crev)) || "&slash.maclib" ) ;
    end ;
    else ypath = "" ;

    i = indexc( crev, "&slash." );
    if i > 0 then do ;
     crev = substr( crev, i+1 ) ;
     zpath = trim( reverse( trim(crev)) || "&slash.maclib" ) ;
    end ;
    else zpath = "" ;

    call symput ( 'cpath', trim(left(cpath)) );
    call symput ( 'mpath', trim(left(mpath)) );
    call symput ( 'ypath', trim(left(ypath)) );
    call symput ( 'zpath', trim(left(zpath)) );
  run ;
  /* ------------------------------------
   * Generate SASAUTOS statement
   * ------------------------------------ */
  options sasautos = (
    "&home.&slash.maclib"
    %if %length(&cpath) > 1 %then %do ; "&cpath" %end ;
    %if %length(&mpath) > 1 %then %do ; "&mpath" %end ;
    %if %length(&ypath) > 1 %then %do ; "&ypath" %end ;
    %if %length(&zpath) > 1 %then %do ; "&zpath" %end ;
    "&pmaclib"
%if &sysscp = WIN %then %do ;
        "W:\SASlib\"
        "!SASROOT\core\sasmacro"
        "!SASROOT\aacomp\sasmacro"
        "!SASROOT\accelmva\sasmacro"
        "!SASROOT\assist\sasmacro"
        "!SASROOT\dmine\sasmacro"
        "!SASROOT\dmscore\sasmacro"
        "!SASROOT\eis\sasmacro"
        "!SASROOT\ets\sasmacro"
        "!SASROOT\genetics\sasmacro"
        "!SASROOT\gis\sasmacro"
        "!SASROOT\graph\sasmacro"
        "!SASROOT\hps\sasmacro"
        "!SASROOT\iml\sasmacro"
        "!SASROOT\inttech\sasmacro"
        "!SASROOT\lasreng\sasmacro"
        "!SASROOT\or\sasmacro"
        "!SASROOT\qc\sasmacro"
        "!SASROOT\share\sasmacro"
        "!SASROOT\stat\sasmacro"
        "!SASROOT\tmine\sasmacro"
%end ;
%else %do ;
    "!SASROOT/sasautos"
    "/usr/apps/sas/srclib"
%end ;
        );

%if &sysscp = WIN %then %do ;
   libname  datalib ( "W:\data\share\sas_datalib\",
                      "W:\data\share\sas_datalib\brfss",
                      "W:\data\share\sas_datalib\census1990",
                      "W:\data\share\sas_datalib\census2000",
                      "W:\data\share\sas_datalib\census2010",
                      "W:\data\share\sas_datalib\cms",
                      "W:\data\share\sas_datalib\medicare5pct"
                     ) ;
   libname library "W:\data\share\sas_datalib\" ;
%end ;
%else %do ;
   libname  datalib ( "/data/share/sas_datalib/",
                      "/data/share/sas_datalib/brfss",
                      "/data/share/sas_datalib/census1990",
                      "/data/share/sas_datalib/census2000",
                      "/data/share/sas_datalib/census2010",
                      "/data/share/sas_datalib/cms",
                      "/data/share/sas_datalib/medicare5pct"
                     ) ;
   libname library "/data/share/sas_datalib/" ;
%end ;
*--------------------------------------------------------------------------*
| Determine the version of SAS being used and set format search path to    |
| use correct version.                                                     |
*--------------------------------------------------------------------------*;
   %let ver = %substr(&sysver, 1, 1) ;
%if &sysscp = WIN %then %do ;
   %let sys = win ;
%end ;
%if &sysscp = SUN X64 %then %do ;
   %let sys = sunx64 ;
%end ;
%else %do ;
   %let sys = ;
%end ;
   %put  "HCP NOTE:  Using SAS Version &ver format catalog in fmtsearch path" ;
   %put  "HCP NOTE:  SYSSCP= &sysscp and sys= &sys" ;
   options
        fmtsearch=(work library datalib)
        msglevel=i
   ;
   proc options option=fmtsearch ;
   run ;
   %put HCP NOTE:  End Macro autoid ;
  run;
%mend autoid;