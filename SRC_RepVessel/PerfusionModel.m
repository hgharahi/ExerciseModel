function Results = PerfusionModel(Testset, Params, t_final, flg)

%% Exercise is modeled using the aortic pressure as the input pressure.
Xo_myo = [Testset.AoP(1) 1 50 50 85 85 120 120 5]'; % for 2713 Resting

[t,X] = ode15s(@dXdT_myocardium,[0 t_final],Xo_myo,[], Testset, Params);

Results = PostProcessing( t, X, Testset, Params);
Results.t = t;

t_idx = t>t_final-2*Testset.T & t<=t_final;
Dt = diff(Results.t);

Qendo = Results.Q13(t>t_final-2*Testset.T & t<=t_final);
Qendo = sum(Results.Q13(t_idx).*Dt(t_idx(2:end)))/(2*Testset.T);

Qmid = Results.Q12(t>t_final-2*Testset.T & t<t_final);
Qmid = sum(Results.Q12(t_idx).*Dt(t_idx(2:end)))/(2*Testset.T);

Qepi = Results.Q11(t>t_final-2*Testset.T & t<t_final);
Qepi = sum(Results.Q11(t_idx).*Dt(t_idx(2:end)))/(2*Testset.T);

disp(['ENDO/EPI = ',num2str(Qendo/Qepi)]);
disp(['ENDO/MID = ',num2str(Qendo/Qmid)]);
Results.ENDOEPI = Qendo/Qepi;

if flg==1
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
    ylabel('Myocardial Flow (ml/min)');
    yyaxis right
    plot(Testset.t,Testset.PLV,'Color',[1 0 0 0.4],'linewidth',1.5);
    ylabel('Left Ventricular Pressure (mmHg)');
    set(gca,'Fontsize',14);
    xlim([5 10]);
    xlabel('time (s)');
    left_color = [0 0 0];
    right_color = [1 0 0];
    set(h2,'defaultAxesColorOrder',[left_color; right_color]);
    
end
