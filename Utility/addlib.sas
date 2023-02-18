/*Adds additional macro libraries - in addition to /usr/apps/sas/maclib*/
%macro addlib(lib);
 %let before=%sysfunc(compress(%sysfunc(getoption(sasautos)),()));
 %put BEFORE==>&before;
 options sasautos=(&lib &before);
 %put AFTER==>%sysfunc(getoption(sasautos));
%mend addlib; 