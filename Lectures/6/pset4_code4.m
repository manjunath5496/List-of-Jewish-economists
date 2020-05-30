function f = transversality(v0)

global theta_low theta_high

options=odeset('reltol',1e-5,'refine',100);
[~, Y] = ode45(@motion,[theta_low theta_high],[0 v0],options);

f = Y(end,1);
