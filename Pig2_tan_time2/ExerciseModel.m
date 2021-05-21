clc;close all;

addpath('../SRC_Perfusion');
addpath('../SRC_RepVessel');

if exist('Data_Ready','var')==1
else
    
    ReadData;
    
end


%% Assign Perfusion Model parameters

for ii = 1:length(Control.Testset)
    Control.Params(ii) = PerfusionModel_ParamSet(Control.gasol, Control.Testset(ii));
    Anemia.Params(ii) = PerfusionModel_ParamSet(Anemia.gasol, Anemia.Testset(ii));
end


%% Assign RepVessel Model parameters

[Control.D13, Control.A13, MVO2, Control.S_myo13, Control.S_meta13, Control.S_HR13] = RepModel_ParamSet(Control, 'endo', xendo, MetSignal);

[Control.D12, Control.A12, ~, Control.S_myo12, Control.S_meta12, Control.S_HR12] = RepModel_ParamSet(Control, 'mid', xmid, MetSignal);

[Control.D11, Control.A11, ~, Control.S_myo11, Control.S_meta11, Control.S_HR11] = RepModel_ParamSet(Control, 'epi', xepi, MetSignal);

C_C11 = [Control.Params(:).C11];
C_C12 = [Control.Params(:).C12];
C_C13 = [Control.Params(:).C13];
C_R11 = Control.epi.RA;
C_R12 = Control.mid.RA;
C_R13 = Control.endo.RA;

Cb_C11 = abs((sqrt(Control.Params(1).rf1/(Control.Params(1).cf1)^2*Control.Params(1).R01./C_R11)*Control.Params(1).V01-Control.Params(1).V01)./Control.epi.PC);
Cb_C12 = abs((sqrt(Control.Params(1).rf2/(Control.Params(1).cf2)^2*Control.Params(1).R01./C_R12)*Control.Params(1).V01-Control.Params(1).V01)./Control.mid.PC);
Cb_C13 = abs((sqrt(Control.Params(1).R01./C_R13)*Control.Params(1).V01-Control.Params(1).V01)./Control.endo.PC);
figure;
scatter(Cb_C11,C_C11,'filled','r');
hold on
scatter(Cb_C12,C_C12,'filled','g');
scatter(Cb_C13,C_C13,'filled','b');
plot([min([Cb_C11, Cb_C12, Cb_C13]) max([Cb_C11, Cb_C12, Cb_C13])],[min([Cb_C11, Cb_C12, Cb_C13]) max([Cb_C11, Cb_C12, Cb_C13])],'-k','LineWidth',2);
set(gca,'yscale','log');
set(gca,'xscale','log');
ylabel('Model 1 Estimated C1 (mL/mmHg)');
xlabel('C1 Average Approximation (mL/mmHg)');


figure; hold on;
p(1)=scatter(Control.A11(1:end),C_C11(1:end),'filled','r');
LineEpi = polyfit(Control.A11(1:end),log(C_C11(1:end)),1);
Ath = 0:0.1:1;
LogCth = LineEpi(1)*Ath + LineEpi(2);
Cth = exp(LogCth);
plot(Ath,Cth,'r');
p(2)=scatter(Control.A12(1:end),C_C12(1:end),'filled','g');
LineMid = polyfit(Control.A12(1:end),log(C_C12(1:end)),1);
Ath = 0:0.1:1;
LogCth = LineMid(1)*Ath + LineMid(2);
Cth = exp(LogCth);
plot(Ath,Cth,'g');
p(3)=scatter(Control.A13(1:end),C_C13(1:end),'filled','b');
LineEndo = polyfit(Control.A13(1:end),log(C_C13(1:end)),1);
Ath = 0:0.1:1;
LogCth = LineEndo(1)*Ath + LineEndo(2);
Cth = exp(LogCth);
plot(Ath,Cth,'b');
set(gca,'yscale','log');
legend(p,{'subepi','midwall','subendo'});
xlabel('Activation (-)');
ylabel('C1 (mL/mmHg)');


%% Now get to Rest! & Exercise!
%%%%%%%%%%%%%%%%%%%%%%%%% Find resting state
%%% Determine the baseline state based on previous CPP experiments. k =
%%% 1:6, for CPP = 40:140, respectively.
k = 5;

%%%%% These values are taken from Dan's inital analysis
Control.Params(k).C_PA = 0.0013/3;
Control.Params(k).L_PA = 2;

Rest = Control;
t_final = Rest.Testset(k).t(end);
Rest.Results = PerfusionModel( Rest.Testset(k),  Rest.Params(k), t_final, 1);
Rest =   Calculations_Exercise(Rest, k);

ENDOEPI_Control = Rest.Results.ENDOEPI;
QPA_Control = Rest.QPA

Rest.Exercise_LvL = 1;
Rest.MVO2 = Rest.Exercise_LvL*MVO2;

Rest.Testset(k).t = tdata_R;
Rest.Testset(k).AoP = AoP_R;
Rest.Testset(k).PLV = PLV_R;
[~, Rest.Testset(k).T] = LeftVenPerssure(Rest.Testset(k).AoP,Rest.Testset(k).t,mean(diff(tdata_R)));
figure;plot(Rest.Testset(k).t,Rest.Testset(k).AoP);hold on
plot(Rest.Testset(k).t,Rest.Testset(k).PLV);
Rest.HR(k) = 60/Rest.Testset(k).T;
t_final = Rest.Testset(k).t(end);

Rest.Results = PerfusionModel( Rest.Testset(k),  Rest.Params(k), t_final, 0);
Rest =   Calculations_Exercise(Rest, k);

QPA = Rest.QPA;

err = 10;

while err>1e-3
    
    [Rest.endo.D(k), Act_Endo_R, S_myo_Endo_R, S_meta_Endo_R, S_HR_Endo_R] = RepModel_Exercise(Rest, Control, 'endo', xendo, MetSignal, k);
    
    [Rest.mid.D(k), Act_Mid_R, S_myo_Mid_R, S_meta_Mid_R, S_HR_Mid_R] = RepModel_Exercise(Rest, Control, 'mid', xmid, MetSignal, k);
    
    [Rest.epi.D(k), Act_Epi_R, S_myo_Epi_R, S_meta_Epi_R, S_HR_Epi_R] = RepModel_Exercise(Rest, Control, 'epi', xepi, MetSignal, k);
    
    [Rest] = ComplianceResistance(Rest, Control, k);
    
    Rest.Params(k).C11;
    Rest.Params(k).C12;
    Rest.Params(k).C13;
    
    Rest.Results = PerfusionModel( Rest.Testset(k),  Rest.Params(k), t_final, 0);
    
    Rest =   Calculations_Exercise(Rest, k);
    
    Rest.QPA
    
    err = abs(QPA - Rest.QPA);
    QPA = Rest.QPA;
    
end

Rest.Results = PerfusionModel( Rest.Testset(k),  Rest.Params(k), t_final, 1);

%%%%%%%%%%%%%%%%%%%%%%%%% Now exercise!

Exercise = Rest;

Exercise.Exercise_LvL = 1.344;
Exercise.MVO2 = Exercise.Exercise_LvL*MVO2;

Exercise.Testset(k).t = tdata_E;
Exercise.Testset(k).AoP = AoP_E;
Exercise.Testset(k).PLV = PLV_E;
[~, Exercise.Testset(k).T] = LeftVenPerssure(Exercise.Testset(k).AoP,Exercise.Testset(k).t,mean(diff(tdata_E)));
figure;plot(Exercise.Testset(k).t,Exercise.Testset(k).AoP);hold on
plot(Exercise.Testset(k).t,Exercise.Testset(k).PLV);
Exercise.HR(k) = 60/Exercise.Testset(k).T;
t_final = Exercise.Testset(k).t(end);

Exercise.Results = PerfusionModel( Exercise.Testset(k),  Exercise.Params(k), t_final, 0);
Exercise =   Calculations_Exercise(Exercise, k);

QPA = Exercise.QPA;

err = 10;

while err>1e-3
    
    [Exercise.endo.D(k), Act_Endo_E, S_myo_Endo_E, S_meta_Endo_E, S_HR_Endo_E] = RepModel_Exercise(Exercise, Control, 'endo', xendo, MetSignal, k);
    
    [Exercise.mid.D(k), Act_Mid_E, S_myo_Mid_E, S_meta_Mid_E, S_HR_Mid_E] = RepModel_Exercise(Exercise, Control, 'mid', xmid, MetSignal, k);
    
    [Exercise.epi.D(k), Act_Epi_E, S_myo_Epi_E, S_meta_Epi_E, S_HR_Epi_E] = RepModel_Exercise(Exercise, Control, 'epi', xepi, MetSignal, k);
       
    [Exercise] = ComplianceResistance(Exercise, Control, k);
    
    Exercise.Params(k).C11;
    Exercise.Params(k).C12;
    Exercise.Params(k).C13;
    
    Exercise.Results = PerfusionModel( Exercise.Testset(k),  Exercise.Params(k), t_final, 0);
    
    Exercise =   Calculations_Exercise(Exercise, k);
    
    Exercise.QPA
    
    err = abs(QPA - Exercise.QPA);
    QPA = Exercise.QPA;
    
end

Exercise.Results = PerfusionModel( Exercise.Testset(k),  Exercise.Params(k), t_final, 1);

%% Plots

figure;
subplot(1,2,1);hold on
scatter(1,60*QPA_Control,'ok');hold on
scatter(2,60*Rest.QPA,'ok');
scatter(3,60*Exercise.QPA,'ok','filled');
set(gca,'xtick',[1,2,3],'xticklabel',{'Baseline','Rest','Exercise'},'Fontsize',12);
ylabel('Myocardial Flow (ml/min)','Fontsize',12);
axis([0.5 3.5 0 60*Exercise.QPA*1.3]);box on;pbaspect([1 2 1]);
subplot(1,2,2);hold on
scatter(1,ENDOEPI_Control,'ok');hold on
scatter(2,Rest.Results.ENDOEPI,'ok');
scatter(3,Exercise.Results.ENDOEPI,'ok','filled');
set(gca,'xtick',[1,2,3],'xticklabel',{'Baseline','Rest','Exercise'},'Fontsize',12);
ylabel('ENDO/EPI Flow Ratio','Fontsize',12);
axis([0.5 3.5 0 1.5]);box on;pbaspect([1 2 1]);


figure;
subplot(1,2,1);
plot([1 2 3],[Control.A11(k), Act_Epi_R, Act_Epi_E],'o-','MarkerEdgeColor','r',...
    'MarkerFaceColor','r','LineWidth',2,'Color','r'); hold on;
plot([1 2 3],[Control.A12(k), Act_Mid_R, Act_Mid_E],'o-','MarkerEdgeColor','g',...
    'MarkerFaceColor','g','LineWidth',2,'Color','g');
plot([1 2 3],[Control.A13(k), Act_Endo_R, Act_Endo_E],'o-','MarkerEdgeColor','b',...
    'MarkerFaceColor','b','LineWidth',2,'Color','b');
set(gca,'xtick',[1,2,3],'xticklabel',{'Baseline','Rest','Exercise'},'Fontsize',12);
ylabel('Activation','Fontsize',12);pbaspect([1 2 1]);
% legend('subepi','midwall','subendo');

subplot(1,2,2);
plot([1 2 3],[Control.D11(k)/100, Rest.epi.D(k)/100, Exercise.epi.D(k)/100],'o-','MarkerEdgeColor','r',...
    'MarkerFaceColor','r','LineWidth',2,'Color','r'); hold on;
plot([1 2 3],[Control.D12(k)/100, Rest.mid.D(k)/100, Exercise.mid.D(k)/100],'o-','MarkerEdgeColor','g',...
    'MarkerFaceColor','g','LineWidth',2,'Color','g');
plot([1 2 3],[Control.D13(k)/100, Rest.endo.D(k)/100, Exercise.endo.D(k)/100],'o-','MarkerEdgeColor','b',...
    'MarkerFaceColor','b','LineWidth',2,'Color','b');
set(gca,'xtick',[1,2,3],'xticklabel',{'Baseline','Rest','Exercise'},'Fontsize',12);
ylabel('Diameter','Fontsize',12);pbaspect([1 2 1]);
% legend('subepi','midwall','subendo');

h1 = figure;
set(h1,'Position',[10 10 1000 1000]);
subplot(1,3,1);
plot([1 2 3],[Control.S_myo11(k), S_myo_Epi_R, S_myo_Epi_E],'o-','MarkerEdgeColor','r',...
    'MarkerFaceColor','r','LineWidth',2,'Color','r'); hold on;
plot([1 2 3],[Control.S_myo12(k), S_myo_Mid_R, S_myo_Mid_E],'o-','MarkerEdgeColor','g',...
    'MarkerFaceColor','g','LineWidth',2,'Color','g');
plot([1 2 3],[Control.S_myo13(k), S_myo_Endo_R, S_myo_Endo_E],'o-','MarkerEdgeColor','b',...
    'MarkerFaceColor','b','LineWidth',2,'Color','b');
set(gca,'xtick',[1,2,3],'xticklabel',{'Baseline','Rest','Exercise'},'Fontsize',12);
ylabel('Smyo','Fontsize',12);pbaspect([1 2 1]);

subplot(1,3,2);
plot([1 2 3],[Control.S_HR11(k), S_HR_Epi_R, S_HR_Epi_E],'o-','MarkerEdgeColor','r',...
    'MarkerFaceColor','r','LineWidth',2,'Color','r'); hold on;
plot([1 2 3],[Control.S_HR12(k), S_HR_Mid_R, S_HR_Mid_E],'o-','MarkerEdgeColor','g',...
    'MarkerFaceColor','g','LineWidth',2,'Color','g');
plot([1 2 3],[Control.S_HR13(k), S_HR_Endo_R, S_HR_Endo_E],'o-','MarkerEdgeColor','b',...
    'MarkerFaceColor','b','LineWidth',2,'Color','b');
set(gca,'xtick',[1,2, 3],'xticklabel',{'Baseline','Rest','Exercise'},'Fontsize',12);
ylabel('SHR','Fontsize',12);pbaspect([1 2 1]);

subplot(1,3,3);
plot([1 2 3],[Control.S_meta11(k), S_meta_Epi_R, S_meta_Epi_E],'o-','MarkerEdgeColor','r',...
    'MarkerFaceColor','r','LineWidth',2,'Color','r'); hold on;
plot([1 2 3],[Control.S_meta12(k), S_meta_Mid_R, S_meta_Mid_E],'o-','MarkerEdgeColor','g',...
    'MarkerFaceColor','g','LineWidth',2,'Color','g');
plot([1 2 3],[Control.S_meta13(k), S_meta_Endo_R, S_meta_Endo_E],'o-','MarkerEdgeColor','b',...
    'MarkerFaceColor','b','LineWidth',2,'Color','b');
set(gca,'xtick',[1,2, 3],'xticklabel',{'Baseline','Rest','Exercise'},'Fontsize',12);
ylabel('Smeta','Fontsize',12);pbaspect([1 2 1]);

savePlots