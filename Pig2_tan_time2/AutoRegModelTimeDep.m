clc;close all;
rng('shuffle');
%%% IMPORTANT NOTE:
% This pig does not have blood gas measurement data for Dob+Anemia case.
% Created Sep 16 by HG

addpath('../SRC');

rng('shuffle');

if exist('Data_Ready','var')==1
else
    
    ReadData;
    
end

%% What is the Metabolic Signal?

MetOptions = {'QM','ATP','VariableSV','Generic','MVO2','QdS','Q','M2'};
for k = 1:1
    
    MetSignal = MetOptions{k};
    
    BPmax = min([Control.endo.D,Control.mid.D,Control.epi.D,Anemia.endo.D,Anemia.mid.D,Anemia.epi.D])/2;
    Apmin = max([Control.endo.D,Control.mid.D,Control.epi.D,Anemia.endo.D,Anemia.mid.D,Anemia.epi.D])/2;
    
    %% Autoregulation model
    xendo0 = [ 19.99938975  80.65094806  33.80484243 -19.99872005  85.20668563  33.59681326 364.96632643   1.39691365   0.02021601   0.09999998   5.27452710 ];
    xmid0  = [  6.96943586  74.11025214  24.06090648  -1.61927584  91.37594593  37.72560985 295.92867256   9.19960966   0.10645834   0.09163584   3.68544202 ];
    xepi0  = [  1.14685356 108.73880166   4.82257028   2.38043938 167.46007080 173.69199158 211.72971072   7.46930751   0.20336500   0.01146744  -1.97564838 ];
    
    %     Cp,     Ap,     Bp,                phi_p,      phi_m,      Cm,    rho         C_myo,      C_met,   C_HR,     C0   HR0
    xl = [.50      Apmin     0.1*BPmax       -20          50.44      10     1.00e2       0.1          0      0.001       -10.0  50 ];
    xu = [40.0      1.5*Apmin    BPmax        30          175.44     200    4.50e2       100          1      0.1      10.0   100];
    
    switch MetSignal
        
        case 'ATP'
            
            % y = [Cp, Ap, Bp, phi_p, phi_m, Cm, rho_m, C_myo, C_met, C_HR, C0, S0];
            
            xl(13) = 0.01; %S00
            xu(13) = 0.04;  %So
            xendo0(13) = 0.03;
            xmid0(13) = 0.03;
            xepi0(13) = 0.03;
            nvar = 13;
            
        otherwise
            
            nvar = 12;
            
    end
    
    %% Genetic Algorithm
    objfun_mid = @(x) TanModelHR_obj(x, Control, Anemia, Dob, 'mid','normal',MetSignal);
    objfun_endo = @(x) TanModelHR_obj(x, Control, Anemia, Dob, 'endo','normal',MetSignal);
    objfun_epi = @(x) TanModelHR_obj(x, Control, Anemia, Dob, 'epi','normal',MetSignal);
    
    %    options = optimoptions('fmincon','Display','iter','Algorithm','sqp');
    %    warning('off','all')
    %    warning
    %    gs = GlobalSearch;
    %    ms = MultiStart;
    
    parpool(36);
    
    pctRunOnAll warning('off', 'all');
    
    
    gaoptions = GA_setup();
    
    xendo = ga(objfun_endo, nvar, [], [], [], [], xl, xu, [], gaoptions);
    PostPlots(Control, Anemia, Dob, 'endo', i, xendo, MetSignal);
    
    xmid = ga(objfun_mid, nvar, [], [], [], [], xl, xu, [], gaoptions);
    PostPlots(Control, Anemia, Dob, 'mid', i, xmid, MetSignal);
    
    xepi = ga(objfun_epi, nvar, [], [], [], [], xl, xu, [], gaoptions);
    PostPlots(Control, Anemia, Dob, 'epi', i, xepi, MetSignal);
    
    
    fileID = ['Params_',num2str(i),'_',MetSignal,'.txt'];
    fid = fopen(fileID,'w');
    formatSpec = ['xendo = [',repmat('%12.8f ',1,length(xendo)),'];\n',...
        'xmid  = [',repmat('%12.8f ',1,length(xmid)),'];\n',...
        'xepi  = [',repmat('%12.8f ',1,length(xepi)),'];\n'];
    fprintf(fid,formatSpec,xendo,xmid,xepi);
    fclose('all');
    
end
