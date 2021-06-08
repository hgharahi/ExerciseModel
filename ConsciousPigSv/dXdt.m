function f = dXdt(t, X, P, gD, gA, state, Params)

C_myo = Params(8);  %% Myogenic signal coefficient
C_met = Params(9);  %% Myogenic signal coefficient
C_HR = Params(10);  %% Myogenic signal coefficient
C0 = Params(11);    %% Constant determining the half maximal saturation

D = X(1);
A = X(2);

R = D/2;

T = P*R;

[T_pass, T_max] = Tension(R, Params);

switch state
    case 'normal'
        
        S_myo = C_myo*T*133.32/1e6;
        
        S_meta = C_met*ATP;
        
        S_HR = C_HR*HR;
        
        S = S_myo - S_meta - S_HR + C0;
        
        A_total = 1/(1 + exp(-S));
        
    case 'passive'
        A_total = 0;
    case 'constricted'
        A_total = 1;
end

T_total = T_pass + A * T_max;

f(1) = gD*( T - T_total);
f(2) = gA*( A_total - A);