function [D, A, S_myo, S_meta, S_HR, R0, conv] = CarlsonModelTime(Params, P, D, MetSignal, HR, Dc, Pc, state)

Cp          = Params(1);
Ap          = Params(2);
Bp          = Params(3);
phi_p       = Params(4);
C_myo       = Params(8);  %% Myogenic signal coefficient
C_met       = Params(9);  %% Myogenic signal coefficient
C_HR        = Params(10);  %% Myogenic signal coefficient
C0          = Params(11);    %% Constant determining the half maximal saturation
HR0         = Params(12);

R0 = (Ap - Bp)/pi * ( atan(-phi_p/Cp) + pi/2 ) + Bp;

T = zeros(1,length(P));
A0 = zeros(1,length(P));
D0= zeros(1,length(P));
S_myo = zeros(1,length(P));
S_meta = zeros(1,length(P));
S_HR = zeros(1,length(P));

% Time Course Parameters

tD = 1;
tA = 20;
Tc = Pc*Dc/2;
Ac = 0.5;
gD = 1/tD*Dc/Tc;
gA = 1/tA;


for i = 1:length(P)
    
    X0 = [100, 0.5];
    
    V.MetSignal = MetSignal(i);
    V.Params = Params(:);
    V.HR = HR(i);
    V.gD = gD;
    V.gA = gD;
    V.State = state;
    V.Pressure = P(i);
    
    [t, X] = ode15s(@dXdt_RepVessel, [0 200], X0, [], V);
    
    D(i) = X(end,1);
    A(i) = X(end,2);
    
    R = D(i)/2;
    
    T = V.Pressure*R;
    
%     [T_pass, T_max] = Tension(R, V.Params);
    
    switch V.State
        case 'normal'
            
            S_myo(i) = max(C_myo*T*133.32/1e6,0);
            
            S_meta(i) = C_met*V.MetSignal;
            
            S_HR(i) = C_HR*max(V.HR-HR0,0);
                      
        case 'passive'
            A(i) = 0;
        case 'constricted'
            A(i) = 1;
    end
    
    %% Check if the solution is converged!
    dtx = diff(t);
    dDdt = gradient(X(:,2),mean(dtx));

    if abs(dDdt(end)) < 1e-4
        conv(i) = 0;
    else
        conv(i) = -1;
    end
    
end



