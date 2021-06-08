function [Rest, Exercise] = ExerciseModelEvalFun2(xendo,xmid,xepi, Control, MetSignal)


%% Read aortic and left venctricular pressure from the
data_rest = xlsread('TuneExercisePig','2713 Resting','B9:D5005');
data_exercise = xlsread('TuneExercisePig','2713 Exercise Level 2','B9:D5005');

[tdata_R,AoP_R,PLV_R,Flow_R] = ReadExerciseInput(data_rest);
[tdata_E,AoP_E,PLV_E,Flow_E] = ReadExerciseInput(data_exercise);
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

%% Rest
Init.Exercise_LvL = 1.00;
MVO2 = 59.5395;
Init.MVO2 = Init.Exercise_LvL*MVO2;

Init.Params = PerfusionModel_ParamSet();

Init.t = tdata_R;
Init.dt = mean(diff(Init.t));
Init.AoP = AoP_R;
Init.PLV = PLV_R;
Init.Qexp = Flow_R;
[~, Init.T] = LeftVenPerssure(Init.AoP,Init.t,Init.dt);
Init.HR = 60/Init.T;

Init.Results = PerfusionModel( Init, 0);
Init =   Calculations_Exercise(Init, 'Baseline');

%% Initialize Rest

Rest = Init;

QPA = Rest.QPA;

%% Run Rest

% xendo_S = C0finder(Rest, 'endo', xendo_S, MetSignal);
% xmid_S = C0finder(Rest, 'mid', xmid_S, MetSignal);
% xepi_S = C0finder(Rest, 'epi', xepi_S, MetSignal);

err = 10;
c = 1;
while err>1e-3 && c<50
    
    [Rest.endo.D, Rest.Act_Endo, Rest.S_myo_Endo, Rest.S_meta_Endo, Rest.S_HR_Endo] = RepModel_Exercise(Rest, Control, 'endo', xendo, MetSignal);
    
    [Rest.mid.D, Rest.Act_Mid, Rest.S_myo_Mid, Rest.S_meta_Mid, Rest.S_HR_Mid] = RepModel_Exercise(Rest, Control, 'mid', xmid, MetSignal);
    
    [Rest.epi.D, Rest.Act_Epi, Rest.S_myo_Epi, Rest.S_meta_Epi, Rest.S_HR_Epi] = RepModel_Exercise(Rest, Control, 'epi', xepi, MetSignal);
    
    [C11, C12, C13] = ComplianceResistance(Rest);
    
    Rest.Params.C11 = 0.2*Rest.Params.C11 + 0.8*C11;
    Rest.Params.C12 = 0.2*Rest.Params.C12 + 0.8*C12;
    Rest.Params.C13 = 0.2*Rest.Params.C13 + 0.8*C13;
    
    Rest.Results = PerfusionModel( Rest, 0);
    
    Rest =   Calculations_Exercise(Rest, 'Exercise');
       
    err = abs(QPA - Rest.QPA);
    QPA = Rest.QPA
    
    c = c+1
    
end
Rest.Results = PerfusionModel( Rest, 1);
QPAS = interp1(Rest.Results.t,   Rest.Results.Q_PA, Rest.t);
ENDOEPI = Rest.Results.ENDOEPI;
ENDOMID = Rest.Results.ENDOMID;

r = 1./Rest.Qexp(Rest.t>2).* (QPAS(Rest.t>2)' - Rest.Qexp(Rest.t>2))*1/(sqrt(length(Rest.Qexp(Rest.t>2))));
E1 = r'*r;
E2 = abs(ENDOEPI - 1.2);
E3 = abs(ENDOMID - 1.1);
Rest.obj = E1 + E2 + 0.5*E3;


%% Initialize Exercise
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

Init.Results = PerfusionModel( Init, 0);
Init =   Calculations_Exercise(Init, 'NoBaseline');

Exercise = Init;

QPA = Exercise.QPA;

%% Run Exercise

err = 10;
c = 1;
while err>1e-3 && c<50
    
    [Exercise.endo.D, Exercise.Act_Endo, Exercise.S_myo_Endo, Exercise.S_meta_Endo, Exercise.S_HR_Endo] = RepModel_Exercise(Exercise, Control, 'endo', xendo, MetSignal);
    
    [Exercise.mid.D, Exercise.Act_Mid, Exercise.S_myo_Mid, Exercise.S_meta_Mid, Exercise.S_HR_Mid] = RepModel_Exercise(Exercise, Control, 'mid', xmid, MetSignal);
    
    [Exercise.epi.D, Exercise.Act_Epi, Exercise.S_myo_Epi, Exercise.S_meta_Epi, Exercise.S_HR_Epi] = RepModel_Exercise(Exercise, Control, 'epi', xepi, MetSignal);
    
    [C11, C12, C13] = ComplianceResistance(Exercise);
    
    Exercise.Params.C11 = 0.2*Exercise.Params.C11 + 0.8*C11;
    Exercise.Params.C12 = 0.2*Exercise.Params.C12 + 0.8*C12;
    Exercise.Params.C13 = 0.2*Exercise.Params.C13 + 0.8*C13;
    
    Exercise.Results = PerfusionModel( Exercise, 0);
    
    Exercise =   Calculations_Exercise(Exercise, 'Exercise');
       
    err = abs(QPA - Exercise.QPA);
    QPA = Exercise.QPA
    
    c = c+1
    
end

Exercise.Results = PerfusionModel( Exercise, 1);
QPAS = interp1(Exercise.Results.t,   Exercise.Results.Q_PA, Exercise.t);
ENDOEPI = Exercise.Results.ENDOEPI;
ENDOMID = Exercise.Results.ENDOMID;

r = 1./Exercise.Qexp(Exercise.t>2).* (QPAS(Exercise.t>2)' - Exercise.Qexp(Exercise.t>2))*1/(sqrt(length(Exercise.Qexp(Exercise.t>2))));
E1 = r'*r;
E2 = abs(ENDOEPI - 0.95);
E3 = abs(ENDOMID - 0.975);
Exercise.obj = E1 + E2 + 0.5*E3;

%% Plots

figure;
subplot(1,2,1);hold on
scatter(1,60*Rest.QPA,'ok');hold on
% scatter(2,60*Rest.QPA,'ok');
scatter(2,60*Exercise.QPA,'ok','filled');
set(gca,'xtick',[1,2,3],'xticklabel',{'Baseline','Exercise'},'Fontsize',12);
ylabel('Myocardial Flow (ml/min)','Fontsize',12);
axis([0.5 2.5 0 60*Exercise.QPA*1.3]);box on;pbaspect([1 2 1]);
subplot(1,2,2);hold on
scatter(1,Rest.Results.ENDOEPI,'ok');hold on
scatter(2,Exercise.Results.ENDOEPI,'ok','filled');
set(gca,'xtick',[1,2,3],'xticklabel',{'Baseline','Exercise'},'Fontsize',12);
ylabel('ENDO/EPI Flow Ratio','Fontsize',12);
axis([0.5 2.5 0 1.5]);box on;pbaspect([1 2 1]);


figure;
subplot(1,2,1);
plot([1 2],[Rest.Act_Epi, Exercise.Act_Epi],'o-','MarkerEdgeColor','r',...
    'MarkerFaceColor','r','LineWidth',2,'Color','r'); hold on;
plot([1 2],[Rest.Act_Mid, Exercise.Act_Mid],'o-','MarkerEdgeColor','g',...
    'MarkerFaceColor','g','LineWidth',2,'Color','g');
plot([1 2],[Rest.Act_Endo, Exercise.Act_Endo],'o-','MarkerEdgeColor','b',...
    'MarkerFaceColor','b','LineWidth',2,'Color','b');
set(gca,'xtick',[1,2],'xticklabel',{'Rest','Exercise'},'Fontsize',12);
axis([0.5 2.5 0 1.0]);ylabel('A (-)','Interpreter','Latex');pbaspect([1 2 1]);
% legend('subepi','midwall','subendo');

subplot(1,2,2);
plot([1 2],[Rest.epi.D/100, Exercise.epi.D/100],'o-','MarkerEdgeColor','r',...
    'MarkerFaceColor','r','LineWidth',2,'Color','r'); hold on;
plot([1 2],[Rest.mid.D/100, Exercise.mid.D/100],'o-','MarkerEdgeColor','g',...
    'MarkerFaceColor','g','LineWidth',2,'Color','g');
plot([1 2],[Rest.endo.D/100, Exercise.endo.D/100],'o-','MarkerEdgeColor','b',...
    'MarkerFaceColor','b','LineWidth',2,'Color','b');
set(gca,'xtick',[1,2],'xticklabel',{'Rest','Exercise'},'Fontsize',12);
axis([0.5 2.5 0.0 1.5]);ylabel('$\bar{D}$ (-)','Interpreter','Latex');pbaspect([1 2 1]);
% legend('subepi','midwall','subendo');

h1 = figure;
set(h1,'Position',[10 10 1000 500]);
subplot(1,3,1);
plot([1 2],[Rest.S_myo_Epi, Exercise.S_myo_Epi],'o-','MarkerEdgeColor','r',...
    'MarkerFaceColor','r','LineWidth',2,'Color','r'); hold on;
plot([1 2],[Rest.S_myo_Mid, Exercise.S_myo_Mid],'o-','MarkerEdgeColor','g',...
    'MarkerFaceColor','g','LineWidth',2,'Color','g');
plot([1 2],[Rest.S_myo_Endo, Exercise.S_myo_Endo],'o-','MarkerEdgeColor','b',...
    'MarkerFaceColor','b','LineWidth',2,'Color','b');
set(gca,'xtick',[1,2],'xticklabel',{'Rest','Exercise'},'Fontsize',12);
xlim([0.5 2.5]);ylabel('Smyo','Fontsize',12);pbaspect([1 2 1]);

subplot(1,3,2);
plot([1 2],[Rest.S_meta_Epi, Exercise.S_meta_Epi],'o-','MarkerEdgeColor','r',...
    'MarkerFaceColor','r','LineWidth',2,'Color','r'); hold on;
plot([1 2],[Rest.S_meta_Mid, Exercise.S_meta_Mid],'o-','MarkerEdgeColor','g',...
    'MarkerFaceColor','g','LineWidth',2,'Color','g');
plot([1 2],[Rest.S_meta_Endo, Exercise.S_meta_Endo],'o-','MarkerEdgeColor','b',...
    'MarkerFaceColor','b','LineWidth',2,'Color','b');
set(gca,'xtick',[1,2],'xticklabel',{'Rest','Exercise'},'Fontsize',12);
xlim([0.5 2.5]);ylabel('S_{meta}','Fontsize',12);pbaspect([1 2 1]);

subplot(1,3,3);
plot([1 2],[Rest.S_HR_Epi, Exercise.S_HR_Epi],'o-','MarkerEdgeColor','r',...
    'MarkerFaceColor','r','LineWidth',2,'Color','r'); hold on;
plot([1 2],[Rest.S_HR_Mid, Exercise.S_HR_Mid],'o-','MarkerEdgeColor','g',...
    'MarkerFaceColor','g','LineWidth',2,'Color','g');
plot([1 2],[Rest.S_HR_Endo, Exercise.S_HR_Endo],'o-','MarkerEdgeColor','b',...
    'MarkerFaceColor','b','LineWidth',2,'Color','b');
set(gca,'xtick',[1,2],'xticklabel',{'Rest','Exercise'},'Fontsize',12);
xlim([0.5 2.5]);ylabel('S_{HR}','Fontsize',12);pbaspect([1 2 1]);

return;
