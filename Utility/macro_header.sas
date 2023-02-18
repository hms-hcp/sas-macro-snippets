*--------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA   |
|--------------------------------------------------------------------------|
| File Name      = Enter the saved macro file name (doc_macro_header.txt)  |
| Path or URL    = Enter path-local or URL-internet (/usr/apps/sas/maclib/)|
| Version        = Enter version number of macro (10 char max)             |
| Creation Date  = Enter date in DD MMM YYYY (15 Dec 2003)                 |
| Author         = Enter author's Name(s) (Matthew J. Cioffi)              |
| Affiliation    = Enter author's affiliation or company (HCP)             |
| Category       = Chose Utility-Statistics-Medical-Data-Other             |
| Keys           = Enter key words in lowercase (template header)          |
|                                                                          |
|--------------------------------------------------------------------------|
| Brief Description: (1-2 sentences)                                       |
|--------------------------------------------------------------------------|
   This file is a template that can be used to document macros located 
in the /usr/apps/sas/maclib/ folder at HCP.
*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Update Information: Repeat below fields for each update                  |
|--------------------------------------------------------------------------|
| Modified Date  = DD MMM YYYY                                             |
| By Whom        =                                                         |
| Reason:
   Enter text here describing the update or modification to the macro.
*--------------------------------------------------------------------------*
| Modified Date  = DD MMM YYYY                                             |
| By Whom        =                                                         |
| Reason:
   Enter text here describing the update or modification to the macro.
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

   Copyright (C) 2003 by The Department of Health Care Policy, Harvard 
Medical School, Boston, MA, USA. All rights reserved.
*--------------------------------------------------------------------------*;


*--------------------------------------------------------------------------*
| Full Description:                                                        |
|--------------------------------------------------------------------------|
   This file is designed to be a common template that can be used to create
the header documentation for SAS macros.  The information in the fields and
the details in the instructions are intended to guide users in filling out
the fields (name followed by an '=' sign) and free text sections (area 
below text in box followed by a colon, ':'. 

There are several advantages to using common header structures and common 
date formats.  The biggest advantage is that an individual can look at the
text of the macro file and easily determine if the macro will fit their 
purpose.  The second big advantage is that the web links to these macros 
will bring up text formatted in a similar structure, so a quick scan of
the header can locate important information for each macro.  The third
advantage is that administratively, maintenance is easier and a database
of all the macros can easily be created. 

*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| External Macros Required:                                                |
|--------------------------------------------------------------------------|
   Identify any external macros needed by this macro program.  Listing the 
external macros helps to locate additional components that must be moved,
shared or archived with this macro file to a different location.  For 
example, if macros are called from the SASAUTOS path /usr/apps/sas/maclib/,
then the macros used must be included in some way when sending the program
off-site.  One way to do this is using a %INCLUDE statement and sending a
copy of the called macro with the program.  

/usr/apps/sas/maclib/
   timestamp.sas

*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Instructions:                                                            |
|--------------------------------------------------------------------------|
   The instruction section of the header provides an area to document how
the macro should be used, to fully document each parameter and define
global variables.  The instructions also can expand upon the purpose and
intended uses of the macro as well as provide additional macro development
background.  
   
   In the case of this file, since it is a template to help document
the macros, the instructions below are intended to guide the user on 
filling in the structured fields and free text sections.  Field names in
the header are identified by an '=' sign after some text.  These fields 
should have the text after the '=' restricted to a single line, (no 
carriage returns or line feeds).  Free text sections are identified by the
text in boxes followed by a ':', colon.  The text for these fields should
be entered below the box line beneath the free text field name.  For these
fields there is no limit on the number of lines of text to enter, but it 
is good practice to try to limit each line of text to 80 characters or 
less if possible, or about the width of the comment box.


   For the Department of Health Care Policy macros, we have set up a few 
naming conventions that will help minimize conflicts when using the macros
and help identify macro sources and documentation when scanning the names
of the macros.  If a macro produces global variables, it is recommended
that the name of the global variable be prefixed with an '_', underscore.
Doing this should help to minimize conflicts with other macro variables
used by the calling program and will also help identify the macro created 
variables from SAS macro variables which have the format _*_.  Providing
a full list of all global variables created and a brief description will
also help minimize programming errors or logic conflicts in the calling
SAS program.

   The macro names must have the same name as the macro in the code.
If the code has %macro mymacro then the filename must be mymacro.sas.

   PREFIXES:
   doc_ for files that provide information on combining multiple macros
        together, like a readme file, or for general information files
        like this one on using the macro header template.  These files
        will usually be text files, *.txt, or some other common document
        file like Portable Document Files, *.pdf, 
        Rich Text Format, *.rtf, or Microsoft Word, *.doc.

   hcp_ Macro created by HCP programmer.
   sas_ Macro downloaded or aquired from SAS web site.
   oth_ Macro downloaded or aquired from other source, not SAS.
   
The remainder of the macro name should be in lowercase letters and the 
the length of the full macro name, before the .sas, should not exceed 
32 characters.

   As time goes by, macros will need occasional updating and these updates
should be documented within the macro itself, by using the update fields
located near the top of the header.  Over time, multiple updates may occur.
In these cases, the three fields, Modified Date, By Whom and Reason, and the 
separator line *-------------..., should be copied for each additional 
update.  If the update significantly changes the output from the macro,
you may want to consider saving the older version with a date suffix, in
the format _yyyymmdd, where yyyy is the four digit year, mm is the two digit
month with leading zeros, and dd is the 2-digit day with leading zeros.
That way the most recent version will have the original macro name, so 
programs calling it will always use the most recent version, but the old 
version will be available in order to create the output using the older
version.  
   
   For example if the original macro name was mymacro.sas, and major 
changes were made that causes the output to create different numbers 
than before, then the original version should be renamed with the 
date, in yyyymmdd format, as a part of the file name.  If you want
the old macro to be available through the autocall library, then name
it

   mymacro_20031204.sas

To keep a copy of the file available, for people to view or copy, but
not through the autocall library, then name it

   mymacro.sas.20031204

The new current version would maintain the original name of mymacro.sas.
In the renamed version, be sure to change the macro name as well, from
%macro mymacro to %macro mymacro_20031204, if you want it available
in the autocall library. 

Here is sample of some subheadings that could be used.
   
   Parameters:


   Global Variables:
  
*--------------------------------------------------------------------------*;

/*-------------------------------------------------------------------------*
| Examples:                                                                |
|--------------------------------------------------------------------------|

   If an example would help users understand what the macro does, provide
SAS code that creates a small data set and then uses the macro call.  By 
providing sample code, the user could then cut and paste it into SAS and
they can experiment with it to better understand the macro. For macros 
that produce output, a sample of the output may also prove helpful.

*--------------------------------------------------------------------------*/
 


%macro sample ( ) ;

%*-------------------------------------------------------------------------*
| This is an example of an inline macro comment.                           |
*--------------------------------------------------------------------------*;
 
%mend sample ;

