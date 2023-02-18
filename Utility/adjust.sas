*--------------------------------------------------------------------------*
| Department of Health Care Policy - Harvard Medical School - Boston, MA   |
|--------------------------------------------------------------------------|
| File Name      = adjust.sas                                              |
| Path or URL    = /usr/apps/sas/maclib/                                   |
| Version        =                                                         |
| Creation Date  = 9 Feb 2004                                              |
| Author         = Alan Zaslavsky                                          |
| Affiliation    = HCP                                                     |
| Category       = Statistics                                              |
|                                                                          |
|--------------------------------------------------------------------------|
| Brief Description: Direct adjustment of a rate using logistic regression |
|                                    model.                                |
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
| Given: a dataset with an outcome, adjuster variables, and a variable that|
| defines units to be adjusted.                                            |
|                                                                          |
|Results: a dataset containing adjusted rates, reflecting the prediction   |
|(under the logistic model) for each unit if it had a standard population  |
|on the adjuster variables (defined as either the combined population for  |
|all units, or a systematic sample from that population).  Units with 0%   |
|or 100% on the outcome are not affected by the adjustment.                |
|                                                                          |
|                    Macro Parameters:                                     |
|   inset = dataset with unit identifier, binary outcome, casemix variables|
|   outset = dataset that will get the adjusted rates                      |
|   unit = variable that defines the units, positive integers but          |
|		not necessarily consecutive                                |
|   casemix = list of variables that are casemix adjusters                 |
|   class = variables in casemix that are class variables                  |
|   outcome = outcome variable, must be a 0/1 numeric variable             |
|   thin = thinning factor, 1/thin of the observations will be used        |
|		in standardized rate                                       |
|                                                                          |
| The "units" are those for which you are getting adjusted estimates.  For |
|example if you want estimates for hospitals adjusted for other variables, |
|then you would define a numerical variable for hospital and that would be |
|your "unit" variable.  Other possible units might be health plans or      |
|geographic areas.                                                         |
|The "thin" variable is used to cut down the size of datasets that are     |
|becoming too large.  If you had 20 units and there were 1000 observations |
|altogether, the program would create a dataset with 20 X 1000 = 20,000    |
|observations because it gets the predictions if all 1000 people were put  |
|in region 1, if all 1000 were put in region 2, etc.  A set of 20,000 is   |
|not so bad, but what if there 100 units and 50,000 observations?  Then    |
|you might set thin=10 and it would only take one out of every ten         |
|observations for calculating the predictions.  This is for practical      |
|purposes just as good, and perfectly valid as a way of comparing units    |
|since the same 1/10 of the observations are used for predicting from      |
|every region.                                                             |
|--------------------------------------------------------------------------*;
   
*--------------------------------------------------------------------------*
| Macro Code Begins Here.                                                  |
*--------------------------------------------------------------------------*;
%macro adjust(inset,outset,unit,casemix,class,outcome,thin);
title "Outcome is &outcome from &inset, units are &unit";
title2 "Casemix variables &casemix";

	/* count cases with no successes or no failures */
proc freq data = &inset noprint ;
   tables &unit * &outcome / out=zeroone ;
proc freq data = &inset noprint ;
   tables &unit  / out=counts ;
	/* identify units with all 0 or all 1 */
data zeroone ;
   merge zeroone (rename = (count=outcomecounts)) counts ;
   by &unit ;
   if count = outcomecounts ;

	/* remove units with all 0 or all 1 from the input dataset to 
	make analytic dataset for fitting models */
data analytic;
  set &inset ;
  keep &outcome &casemix &unit ;
proc sort data = analytic ;
  by &unit;
data analytic ;
  merge analytic zeroone;
  by &unit ;
  if outcomecounts = . ;
  lines = _n_ ;
  keep &outcome &casemix &unit lines;
	/* thin the dataset (for manageable size for simulation) */
data sample ;
  set analytic ;
  if mod(_n_,&thin)=0 ; 
  lines = _n_ ;

	/* produce dataset of all unit values (with unique numbers) 
	   excluding those with all zero or all one, and the duplicate value
	   (arbitrarily, with outcome=0) for each unit */
data units ; 
   merge zeroone counts ;
   by &unit ;		/* added 7 Sep 2004 */
   if outcomecounts NE . OR &outcome = 0 then delete ;
   keep &unit  ;

	/* transpose this dataset to make a single a row with a variable
           name for each unit  */
proc transpose data = units out = unitgroup (drop = _name_ ) prefix=UNIT ;
   id &unit  ;
   var &unit ;
data unitgroup ; 
   set unitgroup;
   dummy = 1 ;

	/* pull line numbers out of sample dataset; dummy is to force merge */
data lines ; 
  set sample ;
  keep lines dummy ;
  dummy = 1 ;
data unitgroup ; 
  merge lines unitgroup ;
  drop dummy ;
  by dummy ;
proc transpose data=unitgroup out=exploded (drop = _name_ );
  by lines ;

	/* merge the real data onto the exploded combinations; 
	    for prediction only with outcome variable set to missing */
data exploded ; 
  merge exploded ( rename = (col1=&unit)) sample (drop = &unit) ;
  by lines ;
  &outcome = . ; 

	/* combine with real data */
data exploded ;
  set analytic exploded ;

	/* fit the real model and get predictions to use for adjustment */
proc logistic data = exploded descending ;
  class &unit &class ;
  model &outcome = &unit &casemix
	/  nodummyprint xconv=1e-15  ;
  output out=predict (keep =&unit predprob &outcome) predicted = predprob;

	/* pull the "real" cases out of predicted dataset */
data realpredict ; 
  set predict ;
  if &outcome > . ;
	/* calculate raw (observed) and predicted rates for real cases 
	   only as a check on accuracy of model fitting */
proc means data = realpredict n mean noprint;
  class &unit ;
  var &outcome predprob ;
  output out=rawmean mean=rawrate fittedrate n=cases  ;

	/* using only the "fake" cases from predicted dataset, calculate
	   adjusted rates for each unit */
data predict ; 
  set predict ;
  keep &unit predprob ;
  if &outcome = . ;
proc sort data=predict ;
  by &unit ;
proc means data = predict mean noprint;
  class &unit ;
  var predprob ;
  output out=adjmean mean=adjrate ;

	/* merge together raw and adjusted rates */
data outset ;
  merge rawmean (where=(_type_=1)) 
	adjmean (where=(_type_=1));
  by &unit ;
  drop _type_ _freq_ ;
  delta = adjrate - rawrate ;
  label cases='Number observations'
	rawrate='Raw rate'
	fittedrate='Unadjusted predicted rate'
	adjrate="Adjusted rate" 
	delta = "Adjustment " ;

	/* merge in the cases with all 0 or all 1 outcomes 
	   from zeroone dataset */
data &outset ;
  set zeroone (in = zeroone rename=(outcomecounts = cases) ) outset ;
  keep &unit cases rawrate fittedrate adjrate delta ;
  if zeroone then do ;
    rawrate = &outcome ;
    fittedrate = &outcome ;
    adjrate = &outcome ;
    delta = adjrate - rawrate ;
    end ;
proc sort data=&outset ;
  by &unit ;
  run;
%mend adjust;
