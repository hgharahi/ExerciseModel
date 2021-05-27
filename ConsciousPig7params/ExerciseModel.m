clc;close all;clear;

addpath('../SRC_Perfusion');
addpath('../SRC_RepVessel');

if exist('Data_Ready','var')==1
else
    
    ReadParams;
    
end


%% Now get to Rest! & Exercise!
%%%%%%%%%%%%%%%%%%%%%%%%% Simulate Rest

% Assign baseline blood gas measurements from CPP=120 mmHg case (k = 5), Pig #i
k = 5;
Rest.ArtO2Cnt   = Control.ArtO2Cnt(k);
Rest.CVO2Cnt    = Control.CVO2Cnt(k);
Rest.ArtPO2     = Control.ArtPO2(k);
Rest.CvPO2      = Control.CvPO2(k);
Rest.ArtO2Sat   = Control.ArtO2Sat(k);
Rest.CvO2Sat    = Control.CvO2Sat(k);
Rest.Hgb        = Control.Hgb(k);
Rest.HCT        = Control.HCT(k);
Rest.VisRatio   = Control.VisRatio(k);
Rest.LVweight   = Control.LVweight;
Rest.Exercise_LvL = 1.00;

MVO2 = 40;
Rest.MVO2 = Rest.Exercise_LvL*MVO2;

Rest.Params = PerfusionModel_ParamSet();

Rest.t = tdata_R;
Rest.dt = mean(diff(Rest.t));
Rest.AoP = AoP_R;
Rest.PLV = PLV_R;
Rest.Qexp = Flow_R;
[~, Rest.T] = LeftVenPerssure(Rest.AoP,Rest.t,Rest.dt);
Rest.HR = 60/Rest.T;

figure;plot(Rest.t,Rest.AoP);hold on
plot(Rest.t,Rest.PLV);

Rest.Params.C11
Rest.Params.C12
Rest.Params.C13

Rest.Results = PerfusionModel( Rest, 1);
Rest =   Calculations_Exercise(Rest, 'Baseline');
[Rest] = ComplianceResistance(Rest);

Rest.Params.C11
Rest.Params.C12
Rest.Params.C13

[Rest.endo.D, Act_Endo_R, S_myo_Endo_R, S_meta_Endo_R, S_HR_Endo_R] = RepModel_Exercise(Rest, Control, 'endo', xendo, MetSignal);

[Rest.mid.D, Act_Mid_R, S_myo_Mid_R, S_meta_Mid_R, S_HR_Mid_R] = RepModel_Exercise(Rest, Control, 'mid', xmid, MetSignal);

[Rest.epi.D, Act_Epi_R, S_myo_Epi_R, S_meta_Epi_R, S_HR_Epi_R] = RepModel_Exercise(Rest, Control, 'epi', xepi, MetSignal);

[Rest] = ComplianceResistance(Rest);

Rest.Params.C11
Rest.Params.C12
Rest.Params.C13
    
%%%%%%%%%%%%%%%%%%%%%%%%% Now exercise!

Exercise = Rest;

Exercise.Exercise_LvL = 1.344;
MVO2 = 40;
Exercise.MVO2 = Exercise.Exercise_LvL*MVO2;

Exercise.t = tdata_E;
Exercise.dt = mean(diff(Exercise.t));
Exercise.AoP = AoP_E;
Exercise.PLV = PLV_E;
Exercise.Qexp = Flow_E;
[~, Exercise.T] = LeftVenPerssure(Exercise.AoP,Exercise.t,Exercise.dt);
Exercise.HR = 60/Exercise.T;
t_final = Exercise.t(end);

figure;plot(Exercise.t,Exercise.AoP);hold on
plot(Exercise.t,Exercise.PLV);


Exercise.Results = PerfusionModel( Exercise, 1);
Exercise =   Calculations_Exercise(Exercise, 'Exercise');

QPA = Exercise.QPA;

err = 10;

while err>1e-3
    
    [Exercise.endo.D, Act_Endo_E, S_myo_Endo_E, S_meta_Endo_E, S_HR_Endo_E] = RepModel_Exercise(Exercise, Control, 'endo', xendo, MetSignal);
    
    [Exercise.mid.D, Act_Mid_E, S_myo_Mid_E, S_meta_Mid_E, S_HR_Mid_E] = RepModel_Exercise(Exercise, Control, 'mid', xmid, MetSignal);
    
    [Exercise.epi.D, Act_Epi_E, S_myo_Epi_E, S_meta_Epi_E, S_HR_Epi_E] = RepModel_Exercise(Exercise, Control, 'epi', xepi, MetSignal);
       
    [Exercise] = ComplianceResistance(Exercise);
    
    Exercise.Params.C11;
    Exercise.Params.C12;
    Exercise.Params.C13;
    
    Exercise.Results = PerfusionModel( Exercise, 0);
    
    Exercise =   Calculations_Exercise(Exercise, 'Exercise');
    
    Exercise.QPA
    
    err = abs(QPA - Exercise.QPA);
    QPA = Exercise.QPA;
    
end

Exercise.Results = PerfusionModel( Exercise, 1);

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
plot([1 2],[Act_Epi_R, Act_Epi_E],'o-','MarkerEdgeColor','r',...
    'MarkerFaceColor','r','LineWidth',2,'Color','r'); hold on;
plot([1 2],[Act_Mid_R, Act_Mid_E],'o-','MarkerEdgeColor','g',...
    'MarkerFaceColor','g','LineWidth',2,'Color','g');
plot([1 2],[Act_Endo_R, Act_Endo_E],'o-','MarkerEdgeColor','b',...
    'MarkerFaceColor','b','LineWidth',2,'Color','b');
set(gca,'xtick',[1,2],'xticklabel',{'Baseline','Exercise'},'Fontsize',12);
axis([0.5 2.5 0 1.0]);ylabel('A (-)','Interpreter','Latex');pbaspect([1 2 1]);
% legend('subepi','midwall','subendo');

subplot(1,2,2);
plot([1 2],[Rest.epi.D/100, Exercise.epi.D/100],'o-','MarkerEdgeColor','r',...
    'MarkerFaceColor','r','LineWidth',2,'Color','r'); hold on;
plot([1 2],[Rest.mid.D/100, Exercise.mid.D/100],'o-','MarkerEdgeColor','g',...
    'MarkerFaceColor','g','LineWidth',2,'Color','g');
plot([1 2],[Rest.endo.D/100, Exercise.endo.D/100],'o-','MarkerEdgeColor','b',...
    'MarkerFaceColor','b','LineWidth',2,'Color','b');
set(gca,'xtick',[1,2],'xticklabel',{'Baseline','Exercise'},'Fontsize',12);
axis([0.5 2.5 0.5 1.5]);ylabel('$\bar{D}$ (-)','Interpreter','Latex');pbaspect([1 2 1]);
% legend('subepi','midwall','subendo');

h1 = figure;
set(h1,'Position',[10 10 1000 500]);
subplot(1,3,1);
plot([1 2],[S_myo_Epi_E, S_myo_Epi_E],'o-','MarkerEdgeColor','r',...
    'MarkerFaceColor','r','LineWidth',2,'Color','r'); hold on;
plot([1 2],[S_myo_Mid_R, S_myo_Mid_E],'o-','MarkerEdgeColor','g',...
    'MarkerFaceColor','g','LineWidth',2,'Color','g');
plot([1 2],[S_myo_Endo_R, S_myo_Endo_E],'o-','MarkerEdgeColor','b',...
    'MarkerFaceColor','b','LineWidth',2,'Color','b');
set(gca,'xtick',[1,2],'xticklabel',{'Baseline','Exercise'},'Fontsize',12);
xlim([0.5 2.5]);ylabel('Smyo','Fontsize',12);pbaspect([1 2 1]);

subplot(1,3,2);
plot([1 2],[S_meta_Epi_R, S_meta_Epi_E],'o-','MarkerEdgeColor','r',...
    'MarkerFaceColor','r','LineWidth',2,'Color','r'); hold on;
plot([1 2],[S_meta_Mid_R, S_meta_Mid_E],'o-','MarkerEdgeColor','g',...
    'MarkerFaceColor','g','LineWidth',2,'Color','g');
plot([1 2],[S_meta_Endo_R, S_meta_Endo_E],'o-','MarkerEdgeColor','b',...
    'MarkerFaceColor','b','LineWidth',2,'Color','b');
set(gca,'xtick',[1,2],'xticklabel',{'Baseline','Exercise'},'Fontsize',12);
xlim([0.5 2.5]);ylabel('S_{meta}','Fontsize',12);pbaspect([1 2 1]);

subplot(1,3,3);
plot([1 2],[S_HR_Epi_R, S_HR_Epi_E],'o-','MarkerEdgeColor','r',...
    'MarkerFaceColor','r','LineWidth',2,'Color','r'); hold on;
plot([1 2],[S_HR_Mid_R, S_HR_Mid_E],'o-','MarkerEdgeColor','g',...
    'MarkerFaceColor','g','LineWidth',2,'Color','g');
plot([1 2],[S_HR_Endo_R, S_HR_Endo_E],'o-','MarkerEdgeColor','b',...
    'MarkerFaceColor','b','LineWidth',2,'Color','b');
set(gca,'xtick',[1,2],'xticklabel',{'Baseline','Exercise'},'Fontsize',12);
xlim([0.5 2.5]);ylabel('S_{HR}','Fontsize',12);pbaspect([1 2 1]);


savePlots