function [DE, ActE, S_myo, S_meta, S_HR] = RepModel_Exercise(Exercise, Control, layer, x, MetSignal, k)

state = 'normal';
%%%%%%%%%%%%%% Preparation
switch MetSignal
    
    case 'ATP'
        
        S0 = x(13);
        
    otherwise
        
        S0 = 0.037;
        
end

Exercise = MetabolicSignalCalc_Exercise(Exercise, S0, MetSignal, k);

%%%%%%%%%%%%%% Control

eval(['Exercise.Dexp = Exercise.',layer,'.D(',num2str(k),');']);
eval(['Exercise.Ptm = Exercise.',layer,'.Ptm(',num2str(k),');']);
eval(['MetSignalC = Exercise.',layer,'.MetSignal;']);

eval(['Control.Dexp = Control.',layer,'.D(4);']);
eval(['Control.Ptm = Control.',layer,'.Ptm(4);']);
Dc = Control.Dexp;
Pc = Control.Ptm;

[DE, ActE, S_myo, S_meta, S_HR] = CarlsonModelTime(x, Exercise.Ptm, Exercise.Dexp, MetSignalC, Exercise.HR(5), Dc, Pc, state);

end
