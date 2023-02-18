/*macro ADDFRMT stores the addresses of the blocks within which the
   matching is performed as formats*/
/* Let'  suppose that the data is sorted by the &GROUP  variable.
This macro creates the formats that hold the record numbers(addresses) of
the beginning and the end of each group.
This could be used in any matching programs when matching is happening
within categories.
Macro parameters:
data - the name of the input data;
group - the group variable
fmtname- the name of the format created(1 to 5 characters)
          Last 3 character will be "PNT".
in-the name of the data library where the input data is created(by default
    it's blank). If you supply the name of the library you have to add
    the "." in the end.
The program using the macro addrfrmt has to have a reference to the format
library

Example of the macro call:

libname library '....';
%addrfrmt(mydata,hospid,hosp)
*/

%macro addrfrmt(data,group,fmtname,library,in=);

data mkfrmt(keep=start end label type fmtname);
set &in.&data;
by &group;
length begobs endobs $ 6 label $ 12;
retain begobs endobs;
if first.&group then begobs=_N_;
if last.&group then do;
    fmtname="&fmtname.PNT";
    type='n';
    start=&group;
    end=&group;
    endobs=_N_;
    label=begobs||endobs;
    output;
end;

proc format library=&library cntlin=mkfrmt;
run;

%mend addrfrmt;


