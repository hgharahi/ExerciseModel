function [Results , ENDOEPI, Qmean, FlowAverage, h1, h2, Tension, Params, Pzf] =  eval_fun_BaseLine(x, Testset, t_final, t_off)

disp(Testset.name)

b = [x(1:7), x(14), x(15)];
t_off = t_off(4);
t_final = t_final(4);
Params = ModelParameters_ParamEst(b , 1, 1);

%% Pressure input simulation: Initialization and solution to ODE
% With the case of coronary perfusion of 100 mmHg, we determine the
% baseline. The flow waveform from this simulation is then used for
% modeling the Pzf in other coronary pressure cases.
Xo_myo = [Testset.Ppump(1) 1 50 50 85 85 120 120 5]'; % for 2713 Resting
tic
[t,X] = ode15s(@dXdT_myocardium,[0 t_off],Xo_myo,[], Testset, Params);
toc;

Result_ON = PostProcessing(t,X,Testset, Params);

Qendo = Result_ON.Q13(t>t_off-2*Testset.T & t<=t_off);
Qendo = mean(Qendo);

Qepi = Result_ON.Q11(t>t_off-2*Testset.T & t<t_off);
Qepi = mean(Qepi);

ENDOEPI = Qendo/Qepi;
disp(['ENDO/EPI = ',num2str(Qendo/Qepi)]);
%% Flow input simulation
% The input flow from the baseline simulation is used as the input into
% another simulation. Vasoconstriction/dilation leads to increased input
% pressures. We try to match the experimental CPP's with the right factors.

InFlow = Flow(t,X(:,2),t_off, t_final); %Using the results from the baseline simulation.

% Q1   = smoothdata(InFlow.Q,'gaussian','smoothingfactor',0.2);
% [~, locs] = findpeaks(Q1);
Qmean = 60*mean(InFlow.Q(t>t_off-2*Testset.T & t<t_off));

 Xo_myo = [X(end,1),X(end,3:end)];

tic;
[t1,X1] = ode15s(@dXdT_myocardium_Qin,[t_off t_final],Xo_myo,[], Testset, InFlow, Params);
toc;

Result_OFF = PostProcessing_Qin(t1,X1,Testset,InFlow,Params);

Result_ON.t = t;
Result_OFF.t = t1;


Results = {Result_ON, Result_OFF};

%% Calculate variables

CPP_exp = interp1(Testset.t,Testset.CPP,[t; t1]);

CPP_sim = [X(:,1); X1(:,1)];

t_sim = [t;t1];


h1 = figure(1); clf;  hold on;%axes('position',[0.15 0.15 0.75 0.75]);
% plot(tdata,Plv1,'k-','linewidth',1.5,'color',0.8*[1 1 1]);
plot(Testset.t,Testset.CPP,'k-','linewidth',2);
plot(t, X(:,1),'r-','linewidth',2);
plot(t1,X1(:,1),'r-','linewidth',2);
% plot(Testset.t,Testset.CPP,'k-','linewidth',1.5,'color',0.8*[0 1 1]);
set(gca,'Fontsize',22); box on
xlabel('time (sec)','interpreter','latex','fontsize',22);
ylabel('Pressure (mmHg)','interpreter','latex','fontsize',22);
% legend('Data','Model','location','best','FontSize',22);
ylim([0 200]);
xlim([1 t1(end)]);

h2 = figure(2); clf;  hold on;%axes('position',[0.15 0.15 0.75 0.75]);
% plot(tdata,Plv1,'k-','linewidth',1.5,'color',0.8*[1 1 1]);
plot(Testset.t,Testset.Flow,'r-','linewidth',1.5);
plot(t,60*X(:,2),'k-','linewidth',1.5,'color',0.8*[0 1 1]);
% plot(Testset.t,Testset.CPP,'k-','linewidth',1.5,'color',0.8*[0 1 1]);
set(gca,'Fontsize',22); box on

FlowAverage = Testset.FlowAverage;
% disp(['Average flow before clamping: Experiment: ' num2str(Testset.FlowAverage)]);
% disp(['Average flow before clamping: Simulation: ' num2str(Qmean)]);
% axis([0 3 0 100]);

% time-averaged total arterial volume:

V_total = mean(Result_ON.V11 + Result_ON.V12 + Result_ON.V13);

CPP = mean(Result_ON.P_PA);

Tension = CPP*sqrt(V_total);

% figure(1);
Pzf(1) = mean(X1((t1>(t_final-Testset.T)),1));
% plot(t1(t1>(t_final-Testset.T)), Pzf_sim,'*');

[~, a] = min(abs(Testset.t-(t_final-Testset.T)));
[~, b] = min(abs(Testset.t-t_final));

Pzf(2) = mean(Testset.CPP(a:b),1);


% plot(Testset.t(Testset.t>(t_final-Testset.T)), Pzf_exp,'o');







