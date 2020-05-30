tic
clear all
global tau k y_low theta_low theta_high gamma

% parameters
tau = 0.3;
k = 4;
y_low = 2;

% truncate distribution at the top
Fhigh = 1-1e-3;
theta_low = 
theta_high = 
y_high = 
ygrid = y_low:(y_high-y_low)/1000:y_high;

% 
gamma = 0.50;
rr = 1;
iter = 1;
while (abs(rr)> 1e-3) && (iter < 1000);

    % 
    v0 = fzero(@transversality,[0.2 1000]);
    [tt X] = ode45(@motion,[theta_low theta_high],[0 v0]);
    vv = X(:,2); 
    eta = X(:,1); 
    clear X

    % 
    f = zeros(length(tt),1);
    for i=1:length(tt)
        f(i) = density(tt(i));
    end

    % 
    yy = 
    cc = 

    % 
    r = zeros(1,length(tt)-1);
    for i=1:length(tt)-1
        r(i) = (cc(i)-yy(i))*f(i)*(tt(i+1)-tt(i));
    end
    rr=sum(r);

    % 
    gamma = gamma + 0.001*sign(rr);
    iter = iter+1;
end

% plots
figure(1);
plot(yy,yy-cc); title('tax function (y-c as function of y)'); grid on

figure(2);
subplot(2,1,1); plot(yy,1-yy./(tt.^2)); title('marginal tax (as function of y)'); grid on
subplot(2,1,2); plot(yy,(yy-cc)./yy); title('average tax (as function of y)'); grid on

figure(3);
subplot(2,1,1); plot(tt,eta); title('eta (as function of theta)'); grid on
subplot(2,1,2); plot(tt,vv); title('v (as function of theta)'); grid on

figure(4);
subplot(2,1,1); plot(tt,cc); title('c (as function of theta)'); grid on
subplot(2,1,2); plot(tt,yy); title('y (as function of theta)'); grid on

figure(5);
plot(ygrid,k*ygrid.^(-k-1)*y_low^k); title('density of income'); grid on
