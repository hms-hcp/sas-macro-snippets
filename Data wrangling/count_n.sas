/* computes the number of observation in the data set and creates a
    global macro variable &n_obs that has the value*/

%macro count_n(ds_name);
    %global n_obs;
    data _null_;
      call symput('n_obs',left(put(num,8.)));
      stop;
      set &ds_name nobs=num;
    run;
    %put The Data Set &ds_name contains &n_obs Observations.;
%mend count_n;


