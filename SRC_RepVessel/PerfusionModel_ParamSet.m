function Params = PerfusionModel_ParamSet()

% PARAMETERS
Params.C_PA = 0.0013/3;  % mL / mmHg
Params.L_PA = 2.0; % ?????
Params.R_PA = 4; % mmHg / (mL / sec)
Params.R_PV = 2; % mmHg / (mL / sec)
Params.C_PV = 0.0254/3; % mL / mmHg
Params.R0m = 44; % mmHg / (mL / sec)
Params.R01 = 1.2*Params.R0m;
Params.R02 = 0.5*Params.R0m;
Params.V01 = 2.5/9; % mL
Params.Vc = 0.01*Params.V01; % mL
Params.V02 = 8.0/9; % mL
Params.C11 = 0.013/9; % mL / mmHg
Params.C12 = 0.013/9; % mL / mmHg
Params.C13 = 0.013/9; % mL / mmHg
Params.C2 = 0.254/9; % mL / mmHg
Params.gamma = 0.75; 
Params.cf1 = 0.55; % epi/endo compliance factor
Params.rf1 = 1.28; % epi/endo resistance factor
Params.cf2 = 0.68; % epi/mid compliance factor
Params.rf2 = 1.12; % epi/mid resistance factor
