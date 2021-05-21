function Params = ModelParameters_ParamEst(b, fact, beta)

% PARAMETERS
Params.C_PA = b(1);  % mL / mmHg
Params.L_PA = b(8); % ?????
Params.R_PA = b(9); % mmHg / (mL / sec)
Params.R_PV = 2; % mmHg / (mL / sec)
Params.C_PV = 0.0254/3; % mL / mmHg
Params.R0m = 44; % mmHg / (mL / sec)
Params.R01 = b(2)*Params.R0m;
Params.R02 = 0.5*Params.R0m;
Params.V01 = b(3); % mL
Params.V02 = 8.0/9; % mL

Params.Vc = Params.V01 * b(7); % b(7) is the Vc factor, to make sure Vc<V01

fact1 = fact - (fact-1)*beta;
fact2 = fact;
fact3 = fact + (fact-1)*beta;

if fact3<0
    fact3 = fact;
end

if fact3>13
    fact3 = 13;
end

Params.C11 = fact1*b(4); % mL / mmHg
Params.C12 = fact2*b(4); % mL / mmHg
Params.C13 = fact3*b(4); % mL / mmHg

Params.C2 = 0.254/9; % mL / mmHg
Params.gamma = 0.75; 
Params.cf1 = b(5);%0.55; % epi/endo compliance factor
Params.rf1 = b(6);%1.28; % epi/endo resistance factor
Params.cf2 = 2*b(5)/(b(5)+1);%0.68; % epi/mid compliance factor 
Params.rf2 = 0.5+0.5*b(6);%1.12; % epi/mid resistance factor

% ^^ the last formula are based on taking an average of resistance in the
% subepi and subedno for he mid-wall parameters.