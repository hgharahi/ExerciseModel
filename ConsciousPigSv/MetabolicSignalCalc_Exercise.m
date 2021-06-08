function test = MetabolicSignalCalc_Exercise(test, So, MetabolicDrive)


[Q_endo, Q_mid, Q_epi] = CycleAvg_Exercise(test, 'Q1');
Q_endo = Q_endo;
Q_mid = Q_mid;
Q_epi = Q_epi;


R_MVO2 = 1.5; % Endo to Epi MVO2 ratio
Vc = 0.04;
J0 = 283.388e3;
Ta = 28.151;
C0 = 476;

q_endo = Q_endo*60 / (test.LVweight); % the last 1/3 is roughly for subendo layer
q_mid = Q_mid*60 / (test.LVweight); % the last 1/3 is roughly for mid layer
q_epi = Q_epi*60 / (test.LVweight); % the last 1/3 is roughly for subepi layer

Ht = test.HCT/100;

Sa = test.ArtO2Sat/100;
Sv = test.CvO2Sat/100;

test.Mtotal = test.Exercise_LvL*test.MVO2;

% divide the Mtotal to layers
Mendo = R_MVO2/(3/2*(R_MVO2+1));
Mmid  = ((R_MVO2+1)/2)/(3/2*(R_MVO2+1));
Mepi  = 1/(3/2*(R_MVO2+1));

test.endo.MVO2 = test.Mtotal*Mendo;
test.mid.MVO2 = test.Mtotal*Mmid;
test.epi.MVO2 = test.Mtotal*Mepi;

test.endo.Tv = Vc*Ht*J0*So/(q_endo*(Sa-Sv)) * exp(-Sa/So) * ( exp( (Sa-Sv)/So ) - 1) + Ta;
test.mid.Tv  = Vc*Ht*J0*So/(q_mid*(Sa-Sv)) * exp(-Sa/So) * ( exp( (Sa-Sv)/So ) - 1) + Ta;
test.epi.Tv  = Vc*Ht*J0*So/(q_epi*(Sa-Sv)) * exp(-Sa/So) * ( exp( (Sa-Sv)/So ) - 1) + Ta;

test.endo.dS = Sv;
test.mid.dS  = Sv;
test.epi.dS  = Sv;

test.endo.Sv = Sa - test.endo.MVO2/(C0*Ht*q_endo);
test.mid.Sv  = Sa - test.mid.MVO2/(C0*Ht*q_mid);
test.epi.Sv  = Sa - test.epi.MVO2/(C0*Ht*q_epi);

switch MetabolicDrive
    case 'QM'
        
        test.endo.MetSignal = test.endo.MVO2*q_endo;
        test.mid.MetSignal = test.mid.MVO2*q_mid;
        test.epi.MetSignal = test.epi.MVO2*q_epi;
        
    case 'ATP'
        
        test.endo.MetSignal = test.endo.Tv;
        test.mid.MetSignal  = test.mid.Tv;
        test.epi.MetSignal  = test.epi.Tv;
        
    case 'VariableSV'
        
        test.endo.MetSignal = Sa - max(test.endo.Sv,0);
        test.mid.MetSignal  = Sa - max(test.mid.Sv,0);
        test.epi.MetSignal  = Sa - max(test.epi.Sv,0);
        
    case 'Generic'
        
        test.endo.MetSignal = test.endo.dS;
        test.mid.MetSignal  = test.mid.dS;
        test.epi.MetSignal  = test.epi.dS;
        
    case 'MVO2'
        
        test.endo.MetSignal = test.endo.MVO2;
        test.mid.MetSignal = test.mid.MVO2;
        test.epi.MetSignal = test.epi.MVO2;
        
    case 'QdS'
        
        test.endo.MetSignal = q_endo*(Sa-Sv);
        test.mid.MetSignal = q_mid*(Sa-Sv);
        test.epi.MetSignal = q_epi*(Sa-Sv);
        
    case 'Q'
        
        test.endo.MetSignal = q_endo;
        test.mid.MetSignal = q_mid;
        test.epi.MetSignal = q_epi;
        
    case 'M2'
        
        test.endo.MetSignal = test.endo.MVO2^2;
        test.mid.MetSignal = test.mid.MVO2^2;
        test.epi.MetSignal = test.epi.MVO2^2;
        
end

return
