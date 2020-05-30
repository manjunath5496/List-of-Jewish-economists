%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dynamic Ramsey Taxation Problem                              %
%                                                              %
% by Florian Scheuer, 2007                                     %
% modified by Greg Leiserson
% verified by Daan Struyven
%                                                              %
% note: uses                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
global sigma theta alpha delta beta A

tic

% Set the model parameters
sigma = 2;
beta  = .99;
theta = .38;
delta = .08;
alpha = .30;
A     =  10;

% Set the labor tax (tau) and grid the capital tax (kappa)
tau = 0;
kappa = 0;
kappagrid = 200;
kappa_vec = (-.5:1/kappagrid:.5);
gridn = length(kappa_vec);

% Compute the steady state for all values of kappa
R=1/beta;
r_vec=(R-1)./(1-kappa_vec)+delta;
kl_vec=(alpha*A./r_vec).^(1/(1-alpha));
w_vec=(1-alpha).*A.*kl_vec.^alpha;
cl_vec=A.*kl_vec.^alpha-delta.*kl_vec;
l_vec=(theta.*(1-tau).*w_vec)./((1-theta).*cl_vec+theta.*(1-tau).*w_vec);
c_vec=cl_vec.*l_vec;
k_vec=kl_vec.*l_vec;
y_vec=A.*k_vec.^alpha.*l_vec.^(1-alpha);
u_vec=u(c_vec,l_vec);  
v_vec=u_vec/(1-beta);

% Compute % increase in consumption for instantaneous zero capital tax
if sigma==1
    lambda_vec=(exp((1-beta)*v_vec(kappagrid/2+1))./ ...
        (1-l_vec).^(1-theta)).^(1/theta)./c_vec-1;
else
    lambda_vec=(((1-beta)*(1-sigma)*v_vec(kappagrid/2+1)).^ ...
        (1/(1-sigma))./(1-l_vec).^(1-theta)).^(1/theta)./c_vec-1;
end

% Plot steady state variables as functions of kappa
figure(1); subplot(3,1,1); plot(kappa_vec,[c_vec; l_vec; y_vec]); 
title('steady state c, l, y as function of kappa'); grid on
figure(1); subplot(3,1,2); plot(kappa_vec,k_vec); 
title('steady state k as function of kappa'); grid on
figure(1); subplot(3,1,3); plot(kappa_vec,lambda_vec); 
title('lambda as function of kappa'); grid on

% Loop over multiple values of sigma
nsigma = 0;
for sigma = 2:4
    nsigma = nsigma + 1;

    % Create Bellman iteration variables for transition analysis
    klow  = min(k_vec); 
    khigh = max(k_vec);
    kss0  = k_vec(kappagrid/2+1); % kss with kappa == 0;
    css0  = c_vec(kappagrid/2+1); % css with kappa == 0;
    e     = ones(gridn,1);
    k     = k_vec;

    K = e*k; % matrix of capital levels constant down columns
    Kprime = k'*e'; % matrix of capital levels constant across rows

    % Find minimal labor supply such that k, k' is feasible (i.e. at zero c)
    lmin = min(((max(0,Kprime-(1-delta).*K))./(A.*K.^alpha)).^(1/(1-alpha)),1);

    % Find the optimal l, create matrix U(k',k)
    U = zeros(gridn,gridn);
    for i=1:gridn
        if (mod(i,10)==0)
            disp('10 Rows completed.');
        end
        for j=1:gridn
            % penalize infeasible/corner solution values for k
            if lmin(i,j)==1;
                U(i,j)=-1e20;
            % compute utility for optimal value of l
            else
                lopt=fminbnd(@(l) -u(pf(K(i,j),l)-Kprime(i,j),l),lmin(i,j),1);
                U(i,j)=u(pf(K(i,j),lopt)-Kprime(i,j),lopt);
            end
        end
    end

    % Initialize iteration
    crit   = 1; 
    iter   = 1;
    l_init =.5;

    % Initial guess for value function
    v = u(pf(k,l_init) - k,l_init)/(1-beta);
    v = v';

    % Iterate on Bellman equation
    while crit > 1e-10

        vnew = max(U + beta*v(:,iter)*e')';

        % Compute normalized criterion, (maxdiff/cssvalue)
        critnew = (1-beta)*max(abs(vnew - v(:,iter)))/css0^(-sigma+1);

        % Display iteration information
        [iter, critnew, critnew/crit]
        crit = critnew; iter = iter +1; v(: , iter)  = vnew;

    end

    % Compute policy functions
    [v, policykindex]= max(U + beta*v(:,iter)*e');
    policyk = k(policykindex);
    policyl=zeros(length(k),1);
    policyc=zeros(length(k),1);
    for i=1:length(k)
        policyl(i,1)=fminbnd(@(l) -u(pf(k(1,i),l)-policyk(1,i),l), ...
            lmin(policykindex(i),i),1);
        policyc(i,1)=pf(k(1,i),policyl(i,1))-policyk(1,i);
    end

    % Compute % increase in consumption for zero capital tax w/ transition
    if sigma==1
        lambda_vec2=(exp((1-beta)*vprime)./(1-l_vec).^ ...
            (1-theta)).^(1/theta)./c_vec-1;
    else
        lambda_vec2=(((1-beta)*(1-sigma)*v).^(1/(1-sigma))./ ...
            (1-l_vec).^(1-theta)).^(1/theta)./c_vec-1;
    end

    % Save results for the current sigma to matrix
    P(:,nsigma) = lambda_vec2;
    
end;

% Plot value function and % increase in c with transition
figure(2); subplot(2,1,1); plot(k,v); 
title('value without taxes as function of k(kappa)'); grid on
figure(2); subplot(2,1,2); plot(kappa_vec,[P(:,1),P(:,2),P(:,3)]); 
title('lambda as function of kappa'); grid on

toc