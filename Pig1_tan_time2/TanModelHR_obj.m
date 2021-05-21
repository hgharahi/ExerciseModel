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

Dob = ATPconcentration(Dob, S0, MetSignal);

%%%%%%%%%%%%%% Control

eval(['DexpC = Control.',layer,'.D(1:5);']);
eval(['PexpC = Control.',layer,'.Ptm(1:5);']);
eval(['MetSignalC = Control.',layer,'.MetSignal(1:5);']);

Dc = DexpC(4);
Pc = PexpC(4);

[DmodC, ~ , ~, ~, ~, ~, convC] = CarlsonModelTime(x, PexpC, DexpC, MetSignalC, Control.HR, Dc, Pc, state);

%%%%------Passive and Fully active diameters
[DpC, ~] = CarlsonModelTime(x, PexpC, DexpC, MetSignalC, Control.HR, Dc, Pc, 'passive');
[DcC, ~] = CarlsonModelTime(x, PexpC, DexpC, MetSignalC, Control.HR, Dc, Pc, 'constricted');

% %%%%%%%%%%%%%% Anemia

eval(['DexpA = Anemia.',layer,'.D(1:5);']);
eval(['PexpA = Anemia.',layer,'.Ptm(1:5);']);
eval(['MetSignalA = Anemia.',layer,'.MetSignal(1:5);']);

[DmodA, ~ , ~, ~, ~, ~, convA] = CarlsonModelTime(x, PexpA, DexpA, MetSignalA, Anemia.HR, Dc, Pc, state);

%%%%------Passive and Fully active diameters
[DpA, ~] = CarlsonModelTime(x, PexpA, DexpA, MetSignalA, Anemia.HR, Dc, Pc, 'passive');
[DcA, ~] = CarlsonModelTime(x, PexpA, DexpA, MetSignalA, Anemia.HR, Dc, Pc, 'constricted');

% %%%%%%%%%%%%%% Dob+Anemia

eval(['DexpD = Dob.',layer,'.D(1:5);']);
eval(['PexpD = Dob.',layer,'.Ptm(1:5);']);
eval(['MetSignalD = Dob.',layer,'.MetSignal(1:5);']);

[DmodD, ~ , ~, ~, ~, ~, convD] = CarlsonModelTime(x, PexpD, DexpD, MetSignalD, Dob.HR, Dc, Pc, state);

%%%%------Passive and Fully active diameters
[DpD, ~] = CarlsonModelTime(x, PexpD, DexpD, MetSignalD, Dob.HR, Dc, Pc, 'passive');
[DcD, ~] = CarlsonModelTime(x, PexpD, DexpD, MetSignalD, Dob.HR, Dc, Pc,'constricted');

%%%%%%%%%%%%% Objective function
DMod = [DmodC,	DmodA,  DmodD];
DExp = [DexpC,	DexpA,	DexpD];

Dp = [DpC, DpA, DpD];
Dc = [DcC, DcA, DcD];
if sum(isnan(DMod)) || sum(convC+convA+convD)|| sum([sum((Dp-DExp)<0),sum((DExp-Dc)<0)])
    ER = 1000;
else
    ER = norm((DExp - DMod)./DExp); % + 1000*(x(2)<x(3));
end
