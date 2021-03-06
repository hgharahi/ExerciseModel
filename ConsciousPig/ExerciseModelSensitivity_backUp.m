clear;clc;close all;

addpath('../SRC_Perfusion');
addpath('../SRC_RepVessel');

if exist('Data_Ready','var')==1
else
    
    ReadParams;
    
end


%% Assign Perfusion Model parameters

for ii = 1:length(Control.Testset)
    Control.Params(ii) = PerfusionModel_ParamSet(Control.gasol, Control.Testset(ii));
    Anemia.Params(ii) = PerfusionModel_ParamSet(Anemia.gasol, Anemia.Testset(ii));
    Dob.Params(ii) = PerfusionModel_ParamSet(Dob.gasol, Dob.Testset(ii));
end


%% Assign RepVessel Model parameters

[Control.D13, Control.A13, MVO2, Control.S_myo13, Control.S_meta13, Control.S_HR13] = RepModel_ParamSet(Control, 'endo', xendo, MetSignal);

[Control.D12, Control.A12, ~, Control.S_myo12, Control.S_meta12, Control.S_HR12] = RepModel_ParamSet(Control, 'mid', xmid, MetSignal);

[Control.D11, Control.A11, ~, Control.S_myo11, Control.S_meta11, Control.S_HR11] = RepModel_ParamSet(Control, 'epi', xepi, MetSignal);


%% Establish the baseline state
%%% Determine the baseline state based on previous CPP experiments. k =
%%% 1:6, for CPP = 40:140, respectively.
k = 5;

%%%%% These values are taken from Dan's inital analysis
Control.Params(k).C_PA = 0.0013/3;
Control.Params(k).L_PA = 2;

t_final = Control.Testset(k).t(end);
Control.Results = PerfusionModel( Control.Testset(k),  Control.Params(k), t_final, 1);
Control =   Calculations_Exercise(Control, k);

ENDOEPI_Control = Control.Results.ENDOEPI;
QPA_Control = Control.QPA;

%% Loop over the candidate sensitive parameters.
num_adj_pars = length(adjustables);

for j=0:num_adj_pars
    
    if j>0
        
        x = [xendo,xmid,xepi];
        x(adjustables(j)) = x(adjustables(j)) + 0.1*x(adjustables(j));
        x = reshape(x,12,3);
        xendo_S = x(:,1);
        xmid_S = x(:,2);
        xepi_S = x(:,3);
        
    else
        xendo_S = xendo;
        xmid_S = xmid;
        xepi_S = xepi;
    end
    
    %%% Initialize Exercise
    
    Exercise = Control;
    
    Exercise.Exercise_LvL = 1.344;
    Exercise.MVO2 = Exercise.Exercise_LvL*MVO2;
    
    Exercise.Testset(k).t = tdata_E;
    Exercise.Testset(k).AoP = AoP_E;
    Exercise.Testset(k).PLV = PLV_E;
    [~, Exercise.Testset(k).T] = LeftVenPerssure(Exercise.Testset(k).AoP,Exercise.Testset(k).t,mean(diff(tdata_E)));
    Exercise.HR(k) = 60/Exercise.Testset(k).T;
    t_final = Exercise.Testset(k).t(end);
    
    Exercise.Results = PerfusionModel( Exercise.Testset(k),  Exercise.Params(k), t_final, 0);
    Exercise =   Calculations_Exercise(Exercise, k);
    
    QPA = Exercise.QPA;
    %%% Run Exercise
    
    err = 10;
    c = 1;
    while err>1e-3 && c<100
        
        [Exercise.endo.D(k), Act_Endo_E, S_myo_Endo_E, S_meta_Endo_E, S_HR_Endo_E] = RepModel_Exercise(Exercise, Control, 'endo', xendo_S, MetSignal, k);
        
        [Exercise.mid.D(k), Act_Mid_E, S_myo_Mid_E, S_meta_Mid_E, S_HR_Mid_E] = RepModel_Exercise(Exercise, Control, 'mid', xmid_S, MetSignal, k);
        
        [Exercise.epi.D(k), Act_Epi_E, S_myo_Epi_E, S_meta_Epi_E, S_HR_Epi_E] = RepModel_Exercise(Exercise, Control, 'epi', xepi_S, MetSignal, k);
        
        [Exercise] = ComplianceResistance(Exercise, Control, k);
        
        Exercise.Params(k).C11;
        Exercise.Params(k).C12;
        Exercise.Params(k).C13;
        
        Exercise.Results = PerfusionModel( Exercise.Testset(k),  Exercise.Params(k), t_final, 0);
        
        Exercise =   Calculations_Exercise(Exercise, k);
        
        Exercise.QPA
        
        err = abs(QPA - Exercise.QPA);
        QPA = Exercise.QPA;
        
        c = c+1;
        
    end
    QPAS(j+1,:) = Exercise.Qpa;
    ENDOEPI(j+1) = Exercise.Results.ENDOEPI;

    if j>0
        E1(j,:) = 10./QPAS(1,:).* (QPAS(j+1,:) - QPAS(1,:));
        E2(j) = 10/ENDOEPI(1) * (ENDOEPI(j+1) - ENDOEPI(1));
    end
    
end

s1 = E1;
S1 = vecnorm(s1,2,2);

Sens = S1./max(S1);
Sens = reshape(Sens,12,3);

for j=1:num_adj_pars
    
    E3(j) = 10./mean(QPAS(1,:)).* (mean(QPAS(j+1,:)) - mean(QPAS(1,:)));
    
end

s2 = [E3; E2];
S2 = vecnorm(s2,2,1);
Sens2 = reshape(S2,12,3);

figure; hold on;
for j=1:num_adj_pars
    plot(Exercise.tinp,60*QPAS(j,:),'color',[[62 88 166]/255 0.4]);
end
plot(Exercise.tinp,60*QPAS(1,:),'k','LineWidth',2');
xlim([Exercise.tinp(1) Exercise.tinp(end)]);
ylabel('Myocardial Flow (ml/min)');
xlabel('time (s)');

C = inv(s1*s1');

for ii = 1:36
    for jj = 1:36
        c(ii,jj) = C(ii,jj)/(sqrt(C(ii,ii)*C(jj,jj)));
    end
end

