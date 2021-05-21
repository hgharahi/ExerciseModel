function [DC, ActC, MVO2, S_myo, S_meta, S_HR] = RepModel_ParamSet(Control, layer, x, MetSignal)

state = 'normal';
%%%%%%%%%%%%%% Preparation
switch MetSignal
    
    case 'ATP'
        
        S0 = x(13);
        
    otherwise
        
        S0 = 0.037;
        
end

Control = MetabolicSignalCalc(Control, S0, MetSignal);

%%%%%%%%%%%%%% Control

eval(['Control.Dexp = Control.',layer,'.D(1:5);']);
eval(['Control.Ptm = Control.',layer,'.Ptm(1:5);']);
eval(['MetSignalC = Control.',layer,'.MetSignal;']);

Dc = Control.Dexp(4);
Pc = Control.Ptm(4);

[DC, ActC, S_myo, S_meta, S_HR] = CarlsonModelTime(x, Control.Ptm, Control.Dexp, MetSignalC, Control.HR, Dc, Pc, state);

MVO2 = Control.Mtotal;

end
