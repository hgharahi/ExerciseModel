clear;clc;close all;

addpath('../SRC_Perfusion');
addpath('../SRC_RepVessel');

load Sensitivity.mat;


%% Establish the baseline state
% Assign baseline blood gas measurements from CPP=120 mmHg case (k = 5), Pig #i
%% Establish the baseline state
% Assign baseline blood gas measurements from CPP=120 mmHg case (k = 5), Pig #i
k = 5;
InitR.ArtO2Cnt   = Control.ArtO2Cnt(k);
InitR.CVO2Cnt    = Control.CVO2Cnt(k);
InitR.ArtPO2     = Control.ArtPO2(k);
InitR.CvPO2      = Control.CvPO2(k);
InitR.ArtO2Sat   = Control.ArtO2Sat(k);
InitR.CvO2Sat    = Control.CvO2Sat(k);
InitR.Hgb        = Control.Hgb(k);
InitR.HCT        = Control.HCT(k);
InitR.VisRatio   = Control.VisRatio(k);
InitR.LVweight   = Control.LVweight;
InitR.Exercise_LvL = 1.00;

MVO2 = 59.5395;
InitR.MVO2 = InitR.Exercise_LvL*MVO2;

InitR.Params = PerfusionModel_ParamSet();

InitR.t = tdata_R;
InitR.dt = mean(diff(InitR.t));
InitR.AoP = AoP_R;
InitR.PLV = PLV_R;
InitR.Qexp = Flow_R;
[~, InitR.T] = LeftVenPerssure(InitR.AoP,InitR.t,InitR.dt);
InitR.HR = 60/InitR.T;

InitR.Results = PerfusionModel( InitR, 0);
InitR =   Calculations_Exercise(InitR, 'Baseline');

% 
InitE = InitR;
InitE.Exercise_LvL = 1.34;

MVO2 = 59.5395;
InitE.MVO2 = InitE.Exercise_LvL*MVO2;

InitE.Params = PerfusionModel_ParamSet();

InitE.t = tdata_E;
InitE.dt = mean(diff(InitE.t));
InitE.AoP = AoP_E;
InitE.PLV = PLV_E;
InitE.Qexp = Flow_E;
[~, InitE.T] = LeftVenPerssure(InitE.AoP,InitE.t,InitE.dt);
InitE.HR = 60/InitE.T;

InitE.Results = PerfusionModel( InitE, 0);
InitE =   Calculations_Exercise(InitE, 'NoBaseline');

%% Setup the parameter estimation
popsize = 30;
maxgen = 200;
y0 = zeros(popsize,length(adjust_pars));

x = [xendo,xmid,xepi];

objfun = @(y) ExerciseModelObjFun2(y, InitR, InitE, xendo, xmid, xepi, adjust_pars, Control, MetSignal);

x_all = [subendo.x;mid.x;subepi.x];

% yl = min(x_all(adjust_pars,:),[],2);
% yu = max(x_all(adjust_pars,:),[],2);

for j = 1:length(adjust_pars)
    
    yl(j) = x(adjust_pars(j)) - 0.3*abs(x(adjust_pars(j)));
    yu(j) = x(adjust_pars(j)) + 0.3*abs(x(adjust_pars(j)));
end

for j = 1:popsize
    
    y0(j,:) = normrnd(x(adjust_pars)',0.1*abs(x(adjust_pars)'));
    
end
% options = optimoptions('fmincon','Display','iter','Algorithm','sqp');
p = gcp('nocreate'); % If no pool, do not create new one.
if isempty( p )==1
    parpool(36);
end

pctRunOnAll warning('off', 'all');

gaoptions = optimoptions('ga','MaxGenerations',200,'Display','iter','CreationFcn','gacreationlinearfeasible','MutationFcn', ...
    @mutationadaptfeasible);
    gaoptions = optimoptions(gaoptions,'InitialPopulationMatrix',y0);
    gaoptions = optimoptions(gaoptions,'UseParallel',true);
    gaoptions = optimoptions(gaoptions,'PopulationSize',30);
    gaoptions = optimoptions(gaoptions,'FunctionTolerance',1e-4);
    gaoptions = optimoptions(gaoptions,'OutputFcn',@GA_DISP);
    

y = ga(objfun, length(adjust_pars), [], [], [], [], yl, yu, [], gaoptions) ;  


%% Post
x = [xendo,xmid,xepi];
for j = 1:length(adjust_pars)
    
    x(adjust_pars(j)) = y(j);
    
end

x = reshape(x,12,3);
xendo = x(:,1);
xmid = x(:,2);
xepi = x(:,3);

[Rest, Exercise] = ExerciseModelEvalFun2(xendo,xmid,xepi, Control, MetSignal);

savePlots;