clear;clc;close all;

addpath('../SRC_Perfusion');
addpath('../SRC_RepVessel');

load Sensitivity7.mat;


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
% 
% ENDOEPI_Control = Init.Results.ENDOEPI;
% QPA = Init.QPA;


x = [xendo,xmid,xepi];
y0 = x(adjust_pars);

% options = optimoptions('fmincon','Display','iter','Algorithm','sqp');
p = gcp('nocreate'); % If no pool, do not create new one.
if isempty( p )==1
    parpool(36);
end

pctRunOnAll warning('off', 'all');

gaoptions = optimoptions('ga','MaxGenerations',200,'Display','iter','CreationFcn','gacreationlinearfeasible','MutationFcn', ...
    @mutationadaptfeasible);
    gaoptions = optimoptions(gaoptions,'UseParallel',true);
    gaoptions = optimoptions(gaoptions,'PopulationSize',30);
    gaoptions = optimoptions(gaoptions,'FunctionTolerance',1e-4);
    gaoptions = optimoptions(gaoptions,'OutputFcn',@GA_DISP);
    
objfun = @(y) ExerciseModelObjFun(y, Init, xendo, xmid, xepi, adjust_pars, Control, MetSignal);


yl = [50,   10,     -20,    50,     10,     0.1,  -10];
yu = [200,  200,    30,     200,    200,    100,  10];

% y = fmincon(objfun,y0,[],[],[],[],yl,yu) ;
y = ga(objfun, 7, [], [], [], [], yl, yu, [], gaoptions) ;  

%% Post
x = [xendo,xmid,xepi];
for j = 1:length(adjust_pars)
    
    x(adjust_pars(j)) = y(j);
    x = reshape(x,12,3);
    xendo_S = x(:,1);
    xmid_S = x(:,2);
    xepi_S = x(:,3);
    
end


%% Initialize

Exercise = Init;

QPA = Exercise.QPA;

%%% Run State

err = 10;
c = 1;
while err>1e-3 && c<100
    
    [Exercise.endo.D, Act_Endo_E, S_myo_Endo_E, S_meta_Endo_E, S_HR_Endo_E] = RepModel_Exercise(Exercise, Control, 'endo', xendo_S, MetSignal);
    
    [Exercise.mid.D, Act_Mid_E, S_myo_Mid_E, S_meta_Mid_E, S_HR_Mid_E] = RepModel_Exercise(Exercise, Control, 'mid', xmid_S, MetSignal);
    
    [Exercise.epi.D, Act_Epi_E, S_myo_Epi_E, S_meta_Epi_E, S_HR_Epi_E] = RepModel_Exercise(Exercise, Control, 'epi', xepi_S, MetSignal);
    
    [C11, C12, C13] = ComplianceResistance(Exercise);
    
    Exercise.Params.C11 = 0.5*Exercise.Params.C11 + 0.5*C11;
    Exercise.Params.C12 = 0.5*Exercise.Params.C12 + 0.5*C12;
    Exercise.Params.C13 = 0.5*Exercise.Params.C13 + 0.5*C13;
    
    Exercise.Results = PerfusionModel( Exercise, 0);
    
    Exercise =   Calculations_Exercise(Exercise, 'Exercise');
       
    err = abs(QPA - Exercise.QPA);
    QPA = Exercise.QPA
    
    c = c+1
    
end

Exercise.Results = PerfusionModel( Exercise, 1);
QPAS = interp1(Exercise.Results.t,   Exercise.Results.Q_PA, Exercise.t);
ENDOEPI = Exercise.Results.ENDOEPI;


savePlots;
