function Results = PerfusionModel(Case, flg)

%% Exercise is modeled using the aortic pressure as the input pressure.
Xo_myo = [Case.AoP(1) 1 50 50 85 85 120 120 5]'; % for 2713 Resting

t_final = Case.t(end);
Params = Case.Params;

[t,X] = ode15s(@dXdT_myocardium,[0 t_final],Xo_myo,[], Case, Params);

Results = PostProcessing( t, X, Case, Params);
Results.t = t;

t_idx = t>t_final-2*Case.T & t<=t_final;
Dt = diff(Results.t);

Qendo = Results.Q13(t>t_final-2*Case.T & t<=t_final);
Qendo = sum(Results.Q13(t_idx).*Dt(t_idx(2:end)))/(2*Case.T);

Qmid = Results.Q12(t>t_final-2*Case.T & t<t_final);
Qmid = sum(Results.Q12(t_idx).*Dt(t_idx(2:end)))/(2*Case.T);

Qepi = Results.Q11(t>t_final-2*Case.T & t<t_final);
Qepi = sum(Results.Q11(t_idx).*Dt(t_idx(2:end)))/(2*Case.T);


Results.ENDOEPI = Qendo/Qepi;
Results.ENDOMID = Qendo/Qmid;

if flg==1
    
    
    disp(['ENDO/EPI = ',num2str(Qendo/Qepi)]);
    disp(['ENDO/MID = ',num2str(Qendo/Qmid)]);
    
    
    h1 = figure;hold on;
    plot(t,60*Results.Q13,'b','LineWidth',2);
    plot(t,60*Results.Q12,'g','LineWidth',2);
    plot(t,60*Results.Q11,'r','LineWidth',2);
    xlim([5 10]);
    xlabel('time (s)','FontSize',14);
    ylabel('Myocardial Flow (ml/min)','FontSize',14);
    legend('subendo','midwall','subepi','FontSize',14,'location','best');
    set(gca,'Fontsize',14);

%     yyaxis right
%     plot(Testset.t,Testset.AoP,'k-','linewidth',1.5);
    
    h2 = figure; hold on;
    yyaxis left
    plot(t,60*X(:,2),'linewidth',1.5);
    plot(Case.t,Case.Qexp,'linewidth',3,'Color',[0 0 0 0.4]);
    ylabel('Myocardial Flow (ml/min)');
    yyaxis right
    plot(Case.t,Case.PLV,'Color',[1 0 0 0.4],'linewidth',1.5);
    ylabel('Left Ventricular Pressure (mmHg)');
    set(gca,'Fontsize',14);
    xlim([5 10]);
    xlabel('time (s)');
    left_color = [0 0 0];
    right_color = [1 0 0];
    set(h2,'defaultAxesColorOrder',[left_color; right_color]);
    
end
