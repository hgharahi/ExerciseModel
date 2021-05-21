function A = obj_fun_baseline(b, Testset, t_final, t_off)

Params = ModelParameters_ParamEst(b, 1, 1);

%% Pressure input simulation: Initialization and solution to ODE
% With the case of coronary perfusion of 100 mmHg, we determine the
% baseline. The flow waveform from this simulation is then used for
% modeling the Pzf in other coronary pressure cases.
Xo_myo = [80 1 50 50 85 85 120 120 5]'; % for 2713 Resting

[t,X] = ode15s(@dXdT_myocardium,[0 t_off],Xo_myo,[], Testset, Params);

Result_ON = PostProcessing(t,X,Testset, Params);

Qendo = Result_ON.Q13(t>t_off-2*Testset.T & t<=t_off);
Qendo = mean(Qendo);

Qepi = Result_ON.Q11(t>t_off-2*Testset.T & t<t_off);
Qepi = mean(Qepi);


ENDOEPI = Qendo/Qepi;
%% Flow input simulation
% The input flow from the baseline simulation is used as the input into
% another simulation. Vasoconstriction/dilation leads to increased input
% pressures. We try to match the experimental CPP's with the right factors.

InFlow = Flow(t,X(:,2),t_off, t_final); %Using the results from the baseline simulation.

% Q1   = smoothdata(InFlow.Q,'gaussian','smoothingfactor',0.15);
% [~, locs] = findpeaks(Q1);
% 
% if length(locs)>3
%     Qmean = 60*mean(InFlow.Q(locs(2):locs(4)));
% else
%     Qmean = 10000;
% end
Qmean = 60*mean(InFlow.Q(t>t_off-2*Testset.T & t<t_off));


 Xo_myo = [X(end,1),X(end,3:end)];

[t1,X1] = ode15s(@dXdT_myocardium_Qin,[t_off t_final],Xo_myo,[], Testset, InFlow, Params);

%% Calculate variables and cost function

CPP_exp = interp1(Testset.t,Testset.CPP,[t; t1]);

CPP_sim = [X(:,1); X1(:,1)];
t_sim = [t;t1];

A = abs((Testset.FlowAverage - Qmean) / Testset.FlowAverage) + ...
    1.5*sqrt(sum((CPP_exp(t_sim>1) - CPP_sim(t_sim>1)).^2)./sum(CPP_exp(t_sim>1).^2)) + ...
    0.2*abs(ENDOEPI-1.2);

% A = [abs((Testset.FlowAverage - Qmean) / Testset.FlowAverage);(CPP_exp - CPP_sim)./CPP_exp];














