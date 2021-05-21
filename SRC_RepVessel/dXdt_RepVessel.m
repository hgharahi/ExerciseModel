function f = dXdt_RepVessel(t, X, Vessel)

C_myo = Vessel.Params(8);  %% Myogenic signal coefficient
C_met = Vessel.Params(9);  %% Myogenic signal coefficient
C_HR = Vessel.Params(10);  %% Myogenic signal coefficient
C0  = Vessel.Params(11);    %% Constant determining the half maximal saturation
HR0  = Vessel.Params(12);    %% Heart rate threshold

D = X(1);
A = X(2);

R = D/2;

T = Vessel.Pressure*R;

[T_pass, T_max] = Tension(R, Vessel.Params);

switch Vessel.State
    case 'normal'
        
        S_myo = max(C_myo*T*133.32/1e6,0);
        
        S_myo = max(0, S_myo);        
        
        S_meta = C_met*Vessel.MetSignal;
        
        S_HR = C_HR*max(Vessel.HR-HR0,0);
        
        S = S_myo - S_meta - S_HR + C0;
        
        A_total = 1/(1 + exp(-S));
        
    case 'passive'
        A_total = 0;
    case 'constricted'
        A_total = 1;
end

T_total = T_pass + A * T_max;

f(1,:) = Vessel.gD*( T - T_total);
f(2,:) = Vessel.gA*( A_total - A);

