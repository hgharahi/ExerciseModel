clc;close all;

addpath('../SRC_RepVessel');

if exist('Data_Ready','var')==1
else
    
    ReadData;
    
end

%% Autoregulation model

% y = [Cp, Ap, Bp, phi_p, phi_m, Cm, rho_m, C_myo, C_met, C_HR, C0, S0];

%     Cp,     Ap,     Bp,     phi_p,      phi_m,      Cm,     rho         C_myo,      C_met,   C_HR,     C0,     S0

%% What is the Metabolic Signal?

MetOptions = {'QM','ATP','VariableSV','Generic','MVO2','QdS','Q','M2'};
for k = 1:1
    
    MetSignal = MetOptions{k};
    
    %% Read Parameters from file
    fileID = ['Params_',num2str(i),'_',MetSignal,'.txt'];
    fid = fopen(fileID,'rt');
    tline1 = fgets(fid);
    tline2 = fgets(fid);
    tline3 = fgets(fid);
    
    eval(tline1);eval(tline2);eval(tline3);
    
    fclose('all');
    
    objfun_mid = @(x) TanModelHR_obj(x, Control, Anemia, Dob, 'mid','normal',MetSignal);
    objfun_endo = @(x) TanModelHR_obj(x, Control, Anemia, Dob, 'endo','normal',MetSignal);
    objfun_epi = @(x) TanModelHR_obj(x, Control, Anemia, Dob, 'epi','normal',MetSignal);
    
    fendo = objfun_endo(xendo)
    PostPlots(Control, Anemia, Dob, 'endo', i, xendo, MetSignal)
    
    fmid = objfun_mid(xmid)
    PostPlots(Control, Anemia, Dob, 'mid', i, xmid, MetSignal)
    
    fepi = objfun_epi(xepi)
    PostPlots(Control, Anemia, Dob, 'epi', i, xepi, MetSignal)
    
end


