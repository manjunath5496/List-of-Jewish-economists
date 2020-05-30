function dY = motion(theta,Y)

global gamma

eta = Y(1);
v  = Y(2);
f  = density(theta);

%
deta = 
dv  = 

dY = [deta ; dv];
