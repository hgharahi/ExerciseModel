clear;clc;close all;

addpath('../SRC_Perfusion');
addpath('../SRC_RepVessel');

load Sensitivity9.mat;


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

objfun = @(y) ExerciseModelObjFun2(y, Init, xendo, xmid, xepi, adjust_pars, Control, MetSignal);

x_all = [subendo.x;mid.x;subepi.x];

yl = min(x_all(adjust_pars,:),[],2);
yu = max(x_all(adjust_pars,:),[],2);

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
    

y = ga(objfun, length(adjust_pars), [], [], [], [], yl, yu, [], gaoptions) ;  


%% Post

[Rest, Exercise] = ExerciseModelEvalFun(y, Init,xendo,xmid,xepi,adjust_pars, Control, MetSignal);

