function f = u(c,l)

global sigma theta

if sigma == 1
    f = log(c.^theta.*(1-l).^(1-theta));
else
    f = (c.^theta.*(1-l).^(1-theta)).^(1-sigma)/(1-sigma);
end