function ER = TanModelHR_obj(x, Control, Anemia, Dob, layer, state, MetSignal)


%%%%%%%%%%%%%% Preparation
switch MetSignal
    
    case 'ATP'
        
        S0 = x(13);
        
    otherwise
        
        S0 = 0.037;
        
end

Control = ATPconcentration(Control, S0, MetSignal);

Anemia = ATPconcentration(Anemia, S0, MetSignal);

%%%%%%%%%%%%%% Control

eval(['DexpC = Control.',layer,'.D;']);
eval(['PexpC = Control.',layer,'.Ptm;']);
eval(['MetSignalC = Control.',layer,'.MetSignal;']);

Dc = DexpC(4);
Pc = PexpC(4);

[DmodC, ~] = CarlsonModelTime(x, PexpC, DexpC, MetSignalC, Control.HR, Dc, Pc, state);

% %%%%%%%%%%%%%% Anemia

eval(['DexpA = Anemia.',layer,'.D;']);
eval(['PexpA = Anemia.',layer,'.Ptm;']);
eval(['MetSignalA = Anemia.',layer,'.MetSignal;']);

[DmodA, ~] = CarlsonModelTime(x, PexpA, DexpA, MetSignalA, Anemia.HR, Dc, Pc, state);

%%%%%%%%%%%%% Objective function
DMod = [DmodC,	DmodA];
DExp = [DexpC,	DexpA];


if isnan(DMod)
    ER = 1000;
else
    ER = norm((DExp - DMod)./DExp); % + 1000*(x(2)<x(3));
end
