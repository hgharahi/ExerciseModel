clc;close all;

%%% IMPORTANT NOTE:

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
   xendo0 = [  9.46120259  91.27032000  14.52569240 -27.46890575  50.61374854 199.99995886 280.11640735   2.01497091   0.00001217   0.00881362  -1.19262400 ];
    xmid0  = [ 13.47879504 127.39719225  22.55964529  -8.35422560 171.82273144 159.34179177 439.38785178   4.32452825   1.00000000   0.00685243  -1.64377780 ];
    xepi0  = [  1.49443503  92.12540966   6.82916498  -8.85825712  72.25126636 150.54263630 345.52985900   3.77609697   0.00031759   0.09220873   3.82138488 ];
 
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
