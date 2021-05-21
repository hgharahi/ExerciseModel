clc;close all;

%%% IMPORTANT NOTE:
% This pig does not have blood gas measurement data for CPP 140 mmHg case.

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
    
    
    BPmax = min([Control.endo.D,Control.mid.D,Control.epi.D,Anemia.endo.D,Anemia.mid.D,Anemia.epi.D,Dob.endo.D,Dob.mid.D,Dob.epi.D])/2;
    Apmin = max([Control.endo.D,Control.mid.D,Control.epi.D,Anemia.endo.D,Anemia.mid.D,Anemia.epi.D,Dob.endo.D,Dob.mid.D,Dob.epi.D])/2;
    
    %% Initial guess and parameter bounds
    
    xendo0 = [ 26.39247038  89.59213420  13.03914689 -14.70629502 133.99801311 118.59707416 116.88029005  12.76120986   0.0   0.00000000  -1.47921180 70];
    xmid0  = [ 1.14542189 130.30170973   4.61103941  -5.22115574 173.54273799 125.70916094 211.39111478   9.95648620   0.06918041   0.00000000  -2.05864981 70];
    xepi0  = [ 19.24361785  88.86046149  24.50963678 -19.75247166 136.53094405 160.12941378 200.94234079   9.21378171   0.0   0.00000212  -1.96174970 70];
    
    %     Cp,     Ap,     Bp,                phi_p,      phi_m,      Cm,    rho         C_myo,      C_met,   C_HR,     C0   HR0
    xl = [.50      Apmin     0.1*BPmax       -20          50.44      10     1.00e2       0.1          0      0.001       -10.0  50 ];
    xu = [40.0      1.5*Apmin    BPmax        30          175.44     200    4.50e2       100          1      0.1      10.0   100];
    
    switch MetSignal
        
        case 'ATP'
            
            
            xl(13) = 0.01; %S0
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
