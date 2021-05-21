function [T_pass, T_max] = Tension(R, Params)
    
% R0      = Params(1);
Cp      = Params(1);
Ap      = Params(2);
Bp      = Params(3);
phi_p   = Params(4);
phi_m   = Params(5);
Cm      = Params(6);
rho_m   = Params(7);

R0 = (Ap - Bp)/pi * ( atan(-phi_p/Cp) + pi/2 ) + Bp;

T_pass = R .* (phi_p + Cp * (tan(pi*(R - Bp)./(Ap - Bp) - pi/2)));

T_max = rho_m * R .* exp( - ((R - phi_m)/Cm).^2 );%* max((R - R0),0).^2/R0 