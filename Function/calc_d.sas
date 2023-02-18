%macro calc_d(a_latitude=,a_longitude=,b_latitude=,b_longitude=);
R = 6371030;
pi = 4*atan(1);
if (&a_latitude=&b_latitude and &a_longitude=&b_longitude and &a_latitude ne . and &a_longitude ne .) then distance_meters=0;
else
distance_meters = Arcos(Cos(&a_latitude*pi/180) * Cos(&a_longitude*pi/180) * Cos(&b_latitude*pi/180) * Cos(&b_longitude*pi/180)
                + Cos(&a_latitude*pi/180) * Sin(&a_longitude*pi/180) * Cos(&b_latitude*pi/180) * Sin(&b_longitude*pi/180)
                + Sin(&a_latitude*pi/180) * Sin(&b_latitude*pi/180)) * R ;  ****DISTANCE IN METERS;

distance_miles = distance_meters/(52.8*12*2.54); ****DISTANCE IN MILES;
%mend calc_d;
