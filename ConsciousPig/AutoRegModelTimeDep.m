clc;close all;

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
    xendo0 = [  9.26495746 104.15237041   1.87626078 -13.99079703 147.59803592 199.99994371 256.18918466   2.64429686   0.00000097   0.00804754  -1.07612705 ];
    xmid0  = [  5.52871055 104.15236762   1.87460656  -0.00000004 128.86992920  67.89860371 449.99999977   4.32553563   0.00000005   0.01970690  -0.26456057 ];
    xepi0  = [ 10.82583175 143.82670977   2.05909490  -8.50587340 127.10417721 199.79970367 152.43706596   9.98987999   0.02396097   0.00742267  -2.74089867 ];
    
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
