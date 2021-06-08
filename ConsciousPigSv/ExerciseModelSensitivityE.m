clear;clc;close all;

addpath('../SRC_Perfusion');
addpath('../SRC_RepVessel');

if exist('Data_Ready','var')==1
else
    
    ReadParams;
    
end


%% Establish the baseline state
% Assign baseline blood gas measurements from CPP=120 mmHg case (k = 5), Pig #i
k = 5;
Init.ArtO2Cnt   = Control.ArtO2Cnt(k);
Init.CVO2Cnt    = Control.CVO2Cnt(k);
Init.ArtPO2     = Control.ArtPO2(k);
Init.CvPO2      = Control.CvPO2(k);
Init.ArtO2Sat   = Control.ArtO2Sat(k);
Init.CvO2Sat    = Control.CvO2Sat(k);
Init.Hgb        = Control.Hgb(k);
Init.HCT        = Control.HCT(k);
Init.VisRatio   = Control.VisRatio(k);
Init.LVweight   = Control.LVweight;
Init.Exercise_LvL = 1.34;

MVO2 = 59.5395;
Init.MVO2 = Init.Exercise_LvL*MVO2;

Init.Params = PerfusionModel_ParamSet();

Init.t = tdata_E;
Init.dt = mean(diff(Init.t));
Init.AoP = AoP_E;
Init.PLV = PLV_E;
Init.Qexp = Flow_E;
[~, Init.T] = LeftVenPerssure(Init.AoP,Init.t,Init.dt);
Init.HR = 60/Init.T;

Init.Results = PerfusionModel( Init, 1);
Init =   Calculations_Exercise(Init, 'Baseline');
[C11, C12, C13] = ComplianceResistance(Init);
% 
% ENDOEPI_Control = Init.Results.ENDOEPI;
% QPA = Init.QPA;

%% Loop over the candidate sensitive parameters.
num_adj_pars = length(adjustables);

for j=0:num_adj_pars
    
    if j>0
        
        x = [xendo,xmid,xepi];
        x(adjustables(j)) = x(adjustables(j)) + 0.2*x(adjustables(j));
        x = reshape(x,12,3);
        xendo_S = x(:,1);
        xmid_S = x(:,2);
        xepi_S = x(:,3);
        
    else
        xendo_S = xendo;
        xmid_S = xmid;
        xepi_S = xepi;
    end
    
    %% Initialize
    
    Exercise = Init;
       
    QPA = Exercise.QPA;
      
    %%% Run State
    
    err = 10;
    c = 1;
    while err>1e-3 && c<50
        
    [Exercise.endo.D, Act_Endo_E, S_myo_Endo_E, S_meta_Endo_E, S_HR_Endo_E] = RepModel_Exercise(Exercise, Control, 'endo', xendo_S, MetSignal);
    
    [Exercise.mid.D, Act_Mid_E, S_myo_Mid_E, S_meta_Mid_E, S_HR_Mid_E] = RepModel_Exercise(Exercise, Control, 'mid', xmid_S, MetSignal);
    
    [Exercise.epi.D, Act_Epi_E, S_myo_Epi_E, S_meta_Epi_E, S_HR_Epi_E] = RepModel_Exercise(Exercise, Control, 'epi', xepi_S, MetSignal);
       
    [C11, C12, C13] = ComplianceResistance(Exercise);
    
    Exercise.Params.C11 = 0.2*Exercise.Params.C11 + 0.8*C11;
    Exercise.Params.C12 = 0.2*Exercise.Params.C12 + 0.8*C12;
    Exercise.Params.C13 = 0.2*Exercise.Params.C13 + 0.8*C13;
    
    Exercise.Results = PerfusionModel( Exercise, 0);
    
    Exercise =   Calculations_Exercise(Exercise, 'Exercise');
    
    Exercise.QPA
    
    err = abs(QPA - Exercise.QPA);
    QPA = Exercise.QPA;
        
        c = c+1
        
    end
    QPAS(j+1,:) = interp1(Exercise.Results.t,   Exercise.Results.Q_PA, Exercise.t);
    ENDOEPI(j+1) = Exercise.Results.ENDOEPI;

    if j>0
        E1(j,:) = 10./QPAS(1,:).* (QPAS(j+1,:) - QPAS(1,:));
        E2(j) = 10/ENDOEPI(1) * (ENDOEPI(j+1) - ENDOEPI(1));
    end
    
end

s1 = E1;
S1 = vecnorm(s1,2,2);

Sens1 = S1./max(S1);
% Sens1 = reshape(Sens1,12,3);

s2 = E2;
S2 = vecnorm(s2,2,1);
Sens2 = S2./max(S2);
% Sens2 = reshape(S2,12,3);

figure; hold on;
p0 = plot(Exercise.t,Exercise.Qexp(:),'k','LineWidth',2');
p1 = plot(Exercise.t,60*QPAS(1,:),'r','LineWidth',2');
for j=0:num_adj_pars
    
    [~, tmax] = max(60*QPAS(j+1,:));
%     text(Rest.t(tmax),60*max(QPAS(j+1,:)),num2str(adjustables(j)),'Color','r')
    plot(Exercise.t,60*QPAS(j+1,:),'color',[[62 88 166]/255 0.4]);
    
end
% plot(Exercise.t,60*QPAS(1,:),'r','LineWidth',2');
xlim([Exercise.tinp(1) Exercise.tinp(end)]);
ylabel('Myocardial Flow (ml/min)');
xlabel('time (s)');
legend('Data','Model-Nominal','Model-Perturbed');
uistack(p1,'top')
uistack(p0,'top')

SENSadj = 0*[xendo,xmid,xepi];
SENS = [Sens1+Sens2'];

for j = 1:length(adjustables)
    
    SENSadj(adjustables(j)) = SENS(j);

end

SENSadj = reshape(SENSadj,12,3);
adjust_pars = adjustables( find( SENS >0.3) );
