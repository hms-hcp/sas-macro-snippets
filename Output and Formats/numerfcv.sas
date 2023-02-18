/* ----------------------------------------
 * @(#)numerfcv.sas	1.1 06/07/99
 *
 *   Performs field-content analysis on
 *   all numeric fields in a SAS data
 *   object.  Works on data sets and views.
 *
 *   Takes four parameters
 *     LIB - name of SAS libname
 *     MEM - name of member
 *     NZ  - if Y, screen out zero values.
 *     O   - if HTML, will call %OUT2HTM to
 *           generate HTML output.
 *           This won't work if %OUT2HTM is
 *           not available.
 *           ( default = LST )
 *
 *   For HTML, assumes HTML macro symbol
 *   exists which points to a directory.
 *
 * Edit history
 * 001 Original
 * 002 Accept HTML file
 * 003 Accept Table Name
 * ---------------------------------------- */

%macro NumerFCV(LIB=,MEM=,NZ=N,O=LST,HTML=,TNAM=X);

%put HCP NOTE:  Now running NumerFCV v3.0;

%let LIB = %upcase( &LIB );
%let MEM = %upcase( &MEM );

%local _N i;

%if &TNAM = X %then %do;
   %let TNAM = &LIB..&MEM;
%end;

proc sql;
  create view numer as
  select name, label, format
  from dictionary.columns
  where type = 'num' &
    libname = "&LIB." &
    memname = "&MEM.";

data _null_;
  set numer end = lastrec;
  n + 1;
  call symput( '_V' || left( n ), name );
  if label ^= "" then call symput( '_L' || left( _n_ ), label );
  else call symput( '_L' || left( _n_ ), name );
  call symput( '_F' || left( n ), format );
  if lastrec then call symput( '_N', left( n ) );
  run;

%do i = 1 %to &_N;
proc univariate data = &LIB..&MEM noprint;
  %if %upcase( &NZ ) = Y %then %do;
     where &&_V&i > .;
  %end;
  var &&_V&i;
  output out = stats
    n = nobs sum = tot mean = avg
    min = min q1 = q1 median = median q3 = q3 max = max;
    run;

data report;
  length name $ 8 format $ 12 label $ 40;
  set
  %if %eval( &i > 1 ) %then %do;
    report
  %end;
    stats( in = new );
  if new then do;
    name = "&&_V&i";
    label = "&&_L&i";
    format = "&&_F&i";
  end;
  run;

%end;

data report datevar dtvar;
  set report;
  if format in: ( 'DATETIME' ) then output dtvar;
  else if format in: ( 'DATE', 'MMDDYY' ) then output datevar;
  else output report;
  run;

%if &O = HTML %then %do;
  options linesize = 100 pagesize = 47;
  %Out2HTM( capture=on, runmode = b, window = output )
%end;

proc report data = report missing;
  columns name
    ( '. Parametric Statistics .' nobs tot avg )
    ( '. Rank Statistics .' min q1 median q3 max );
  define name / order format=$8. 'Column/Name/==';
  define nobs / display format=comma9. 'N Obs/==';
  define tot / display format=best10. 'Total/==';
  define avg / display format=best10. 'Average/==';
  define min / display format=best10. 'Minimum/==';
  define q1 / display format=best10. '25th Pct/==';
  define median / display format=best10. 'Median/==';
  define q3 / display format=best10. '75th Pct/==';
  define max / display format=best10. 'Maximum/==';
  title2 "Numeric Field Content Analysis:  &TNAM";
  run;

proc report data = datevar missing;
  columns name
    ( '. Parametric .' nobs avg )
    ( '. Rank Statistics .' min q1 median q3 max );
  define name / order format=$8. 'Column/Name/==';
  define nobs / display format=comma9. 'N Obs/==';
  define avg / display format=date9. 'Average/==';
  define min / display format=date9. 'Minimum/==';
  define q1 / display format=date9. '25th Pct/==';
  define median / display format=date9. 'Median/==';
  define q3 / display format=date9. '75th Pct/==';
  define max / display format=date9. 'Maximum/==';
  title2 "Date Field Content Analysis:  &TNAM";
  run;

proc report data = dtvar missing;
  columns name
    ( '. Parametric .' nobs avg )
    ( '. Rank Statistics .' min q1 median q3 max );
  define name / order format=$8. 'Column/Name/==';
  define nobs / display format=comma9. 'N Obs/==';
  define avg / display format=datetime9. 'Average/==';
  define min / display format=datetime9. 'Minimum/==';
  define q1 / display format=datetime9. '25th Pct/==';
  define median / display format=datetime9. 'Median/==';
  define q3 / display format=datetime9. '75th Pct/==';
  define max / display format=datetime9. 'Maximum/==';
  title2 "Date-Time Field Content Analysis:  &TNAM";
  run;

%if &O = HTML %then %do;

   %Out2HTM(capture=off,
      htmlfile = &HTML,
      brtitle = PharMetrics Numeric Field Content Analysis,
      proploc = library.htmlgen.outprop.slist )

%end;

%mend NumerFCV;
