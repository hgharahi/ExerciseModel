function x = C0finder(Exercise, layer, x, MetSignal)


C_myo       = x(8);  %% Myogenic signal coefficient
C_met       = x(9);  %% Myogenic signal coefficient
C_HR        = x(10);  %% Myogenic signal coefficient
HR0         = x(12);


switch MetSignal
    
    case 'ATP'
        
        S0 = x(13);
        
    otherwise
        
        S0 = 0.037;
        
end

Exercise = MetabolicSignalCalc_Exercise(Exercise, S0, MetSignal);

eval(['Exercise.Dexp = Exercise.',layer,'.D;']);
eval(['Exercise.Ptm = Exercise.',layer,'.Ptm;']);
eval(['MetSignal = Exercise.',layer,'.MetSignal;']);
eval(['D = Exercise.',layer,'.D;']);

[T_pass, T_act] = Tension(D/2, x);

T = Exercise.Ptm*D/2;
A = (T - T_pass)/T_act;

S_myo = max(C_myo*T*133.32/1e6,0);

S_meta = C_met*MetSignal;

S_HR = C_HR*max(Exercise.HR-HR0,0);

S = -log(1/A - 1);

C0 = - ( S_myo - S_meta - S_HR - S );

x(end - 1) = C0;
end
