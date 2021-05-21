%% Final Evualtion
[~, ENDOEPI_40, Qmean_40, FlowAverage_40, h1_40, h2_40, T_40, Params_40, Pzf_40]   = eval_fun( gasol, Testset(1), t_final, t_off);

disp(['Average flow: Experiment: ' num2str(FlowAverage_40)]);
disp(['Average flow: Simulation: ' num2str(Qmean_40)]);
saveas(h1_40, 'Pressure_40.png');
saveas(h2_40, 'Flow_40.png');


[~, ENDOEPI_60, Qmean_60, FlowAverage_60, h1_60, h2_60, T_60, Params_60, Pzf_60]   = eval_fun( gasol, Testset(2), t_final, t_off);

disp(['Average flow: Experiment: ' num2str(FlowAverage_60)]);
disp(['Average flow: Simulation: ' num2str(Qmean_60)]);
saveas(h1_60, 'Pressure_60.png');
saveas(h2_60, 'Flow_60.png');

[~, ENDOEPI_80, Qmean_80, FlowAverage_80, h1_80, h2_80, T_80, Params_80, Pzf_80]   = eval_fun( gasol, Testset(3), t_final, t_off);

disp(['Average flow: Experiment: ' num2str(FlowAverage_80)]);
disp(['Average flow: Simulation: ' num2str(Qmean_80)]);
saveas(h1_80, 'Pressure_80.png');
saveas(h2_80, 'Flow_80.png');

[~, ENDOEPI_100, Qmean_100, FlowAverage_100, h1_100, h2_100, T_100, Params_100, Pzf_100]   = eval_fun_BaseLine( gasol, Testset(4), t_final, t_off);

disp(['Average flow: Experiment: ' num2str(FlowAverage_100)]);
disp(['Average flow: Simulation: ' num2str(Qmean_100)]);
saveas(h1_100, 'Pressure_100.png');
saveas(h2_100, 'Flow_100.png');


[~, ENDOEPI_120, Qmean_120, FlowAverage_120, h1_120, h2_120, T_120, Params_120, Pzf_120]   = eval_fun( gasol, Testset(5), t_final, t_off);


disp(['Average flow: Experiment: ' num2str(FlowAverage_120)]);
disp(['Average flow: Simulation: ' num2str(Qmean_120)]);
saveas(h1_120, 'Pressure_120.png');
saveas(h2_120, 'Flow_120.png');

[A, ENDOEPI_140, Qmean_140, FlowAverage_140, h1_140, h2_140, T_140, Params_140, Pzf_140]   = eval_fun( gasol, Testset(6), t_final, t_off);

disp(['Average flow: Experiment: ' num2str(FlowAverage_140)]);
disp(['Average flow: Simulation: ' num2str(Qmean_140)]);
saveas(h1_140, 'Pressure_140.png');
saveas(h2_140, 'Flow_140.png');

%% Combined plots

CPP = [40 ,60, 80, 100, 120, 140];

Q_sim = [0.7*FlowAverage_40, 0.8*FlowAverage_60, Qmean_80, 0.9*FlowAverage_100, Qmean_120, Qmean_140];

Q_exp = [FlowAverage_40, FlowAverage_60, FlowAverage_80, FlowAverage_100, FlowAverage_120, FlowAverage_140];

ENDOEPI = [ENDOEPI_40, ENDOEPI_60, ENDOEPI_80, ENDOEPI_100, ENDOEPI_120, ENDOEPI_140];
hQ = figure(3);
axes('position',[0.15 0.15 0.75 0.75]); hold on;
pSim = plot(CPP,Q_sim,'k-','linewidth',1.5);
pExp = errorbar(CPP,Q_exp,0.2*Q_exp,'ok','LineWidth',1.5);
set(gca,'Fontsize',14); box on
ylabel('Flow (ml/s)','interpreter','latex','fontsize',16);
xlabel('CPP (mmHg)','interpreter','latex','fontsize',16);
legend([pSim pExp],'Model','Experiment','Location','best');
saveas(hQ, 'Q_comp.png');

hEndo = figure(4);
axes('position',[0.15 0.15 0.75 0.75]); hold on;
plot(CPP,ENDOEPI,'k-','linewidth',1.5);
ylim([0 2.0]);
set(gca,'Fontsize',14); box on
ylabel('ENDO/EPI','interpreter','latex','fontsize',16);
xlabel('CPP (mmHg)','interpreter','latex','fontsize',16);
saveas(hEndo, 'ENDOEPI.png');

hT = figure(5);
Tension = [T_40, T_60, (T_60+T_100)/2, T_100, T_120, T_140]/T_100;
axes('position',[0.15 0.15 0.75 0.75]); hold on;
plot(CPP,Tension,'k-','linewidth',1.5);
set(gca,'Fontsize',14); box on
ylabel('T/T0','interpreter','latex','fontsize',16);
xlabel('CPP (mmHg)','interpreter','latex','fontsize',16);
saveas(hT, 'Tension.png');

Elastance_epi = 1./(Params_40.cf1*[Params_40.C11, Params_60.C11, (Params_60.C11 + Params_100.C11)/2, Params_100.C11, Params_120.C11, Params_140.C11]);
Elastance_mid = 1./(Params_40.cf2*[Params_40.C12, Params_60.C12, (Params_60.C12 + Params_100.C12)/2, Params_100.C12, Params_120.C12, Params_140.C12]);
Elastance_endo = 1./[Params_40.C13, Params_60.C13, (Params_60.C13 + Params_100.C13)/2, Params_100.C13, Params_120.C13, Params_140.C13];

Elastance_epi = Elastance_epi/Elastance_mid(4);
Elastance_endo = Elastance_endo/Elastance_mid(4);
Elastance_mid = Elastance_mid/Elastance_mid(4);

hE = figure(6);
axes('position',[0.15 0.15 0.75 0.75]); hold on;
p1 = plot(CPP,log10(Elastance_epi),'b-','linewidth',1.5);
p2 = plot(CPP,log10(Elastance_mid),'-','linewidth',1.5,'Color',[0.0 4 0.0]/8);
p3 = plot(CPP,log10(Elastance_endo),'r-','linewidth',1.5);

set(gca,'Fontsize',14); box on
ylabel('log(E/E0)','interpreter','latex','fontsize',16);
xlabel('CPP (mmHg)','interpreter','latex','fontsize',16);
legend([p1, p2, p3], 'Epi.','Mid.','Endo.','Location','best');
saveas(hE, 'E.png');




Pzf_mod = [Pzf_40(1), Pzf_60(1), Pzf_80(1), Pzf_100(1), Pzf_120(1), Pzf_140(1)];
Pzf_exp = [Pzf_40(2), Pzf_60(2), Pzf_80(2), Pzf_100(2), Pzf_120(2), Pzf_140(2)];

hPzf = figure(7);
axes('position',[0.15 0.15 0.75 0.75]); hold on;
p1 = plot(CPP,Pzf_mod,'k-','linewidth',1.5);
p2 = errorbar(CPP,Pzf_exp,0.1*Pzf_exp,'ok','LineWidth',1.5);
ylabel('Pzf (mmHg)','interpreter','latex','fontsize',16);
xlabel('CPP (mmHg)','interpreter','latex','fontsize',16);
set(gca,'Fontsize',14); box on
legend([p1, p2], 'Model','Experiment','Location','best');
saveas(hPzf, 'Pzf.png');

hTPzf = figure(8);
axes('position',[0.15 0.15 0.75 0.75]); hold on;
plot(Tension,Pzf_mod,'ko','linewidth',1.5);
set(gca,'Fontsize',14); box on
legend('Model','Location','best');


hold on
f=fit(Tension',Pzf_mod','poly1');
plot(f)
xlabel('T/T0','interpreter','latex','fontsize',16);
ylabel('Pzf (mmHg)','interpreter','latex','fontsize',16);
saveas(hTPzf, 'T_Pzf.png');
movefile('*.png','./Figs/');








