/*--------------------------------------------------------------------------*
| Mass-DAC Project - Dept of Health Care Policy - Harvard Medical School   |
*--------------------------------------------------------------------------*
| ProgramName  = age_years.sas
| Path         = /data/mass-dac/macros/
| VersionACC   = 3.04
| CreationDate = 17 Jan 2008
| Author       = Matthew Cioffi
*--------------------------------------------------------------------------*;

*--------------------------------------------------------------------------*
| Update Information: Repeat below fields for each update                  |
*--------------------------------------------------------------------------*
| ModifiedDate = 27 Jan 2009
| ByWhom       = Matthew Cioffi
   Updated Documentation
*--------------------------------------------------------------------------* ;

*--------------------------------------------------------------------------*
| Full Description:                                                        |
*--------------------------------------------------------------------------*
   This macro computes the age (in years) between two dates.  This is
often needed when computing the age of person on a given date or how long
something has been in service.


Parameters:
   Both paramteres are dates and must contain a SAS date value either as
a SAS date variable or as a text constant, i.e. "28NOV1999"d.
   DATE  = The relevant date to compute the age in years on

   BIRTH = The birth date or start date of the person or event


Functions Explanation:
   floor - returns the largest integer that is less than or equal to the
           computed result.

   intck - returns the integer count of the number of interval boundaries,
           (in our case, # of months) between two dates.

   day   - returns the day of the month from the SAS date value.


Terms Explanation:
   A = intck( 'month', &BIRTH, &DATE )
       Computes the total # of months between the two dates.
       EXAMPLE: If BIRTH=15Jan08 and DATE=04Jan09 then A=12

   B = ( day( &DATE ) < day( &BIRTH ))
       If the day of the month of the relevant date is before the day of
       the birth date, then B=1 and the day of birth has not passed so the
       total # of months between the two dates is reduced by 1, otherwise
       no change is needed in the total # of months.

   floor(( A-B ) / 12 ) =
       Divide the total adjusted months by 12 to get the age in years.
       If the BIRTH date is after the relevant date then the return value
       is a negative integer, otherwise the return value is 0 or a positive
       integer.


Macro Call:
   Use within a data step on the right side of the equation

   age = %age_years ( "28NOV2008"d, DOB ) ;

where DOB is a SAS date value in a data set.
*--------------------------------------------------------------------------*;
*--------------------------------------------------------------------------*
| DISCLAIMER:                                                              |
|--------------------------------------------------------------------------|
   The information contained within this file is provided "AS IS" by the
Department of Health Care Policy (HCP), Harvard Medical School, as a
service to the Department's SAS programmers.  There are no warranties,
expressed or implied, as to the merchantability or fitness for a
particular purpose regarding the accuracy of the materials or programming
code contained herein. This macro may be distributed freely as long as all
comments, headers and related files are included.

   Copyright (C) 2009 by The Department of Health Care Policy, Harvard
Medical School, Boston, MA, USA. All rights reserved.
*--------------------------------------------------------------------------*;
*/

%macro age_years ( DATE, BIRTH ) ;

   floor (( intck( 'month', &BIRTH, &DATE ) -
            ( day( &DATE ) < day( &BIRTH ))) / 12 )

%mend age_years ;







