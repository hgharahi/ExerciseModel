function [Control, Anemia, Dob] = TanModelHR_eval(x, Control, Anemia, Dob, layer, state, MetSignal)

Ap = x(2);
Bp = x(3);

switch state
    case 'normal'
        
        
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
        
        eval(['Control.Dexp = Control.',layer,'.D(1:5);']);
        eval(['Control.Ptm = Control.',layer,'.Ptm(1:5);']);
        eval(['MetSignalC = Control.',layer,'.MetSignal(1:5);']);
        
        Dc = Control.Dexp(4);
        Pc = Control.Ptm(4);
        
        [Control.Dmod, Control.Act, Control.Smyo, Control.Smeta, Control.SHR] = CarlsonModelTime(x, Control.Ptm, Control.Dexp, MetSignalC, Control.HR, Dc, Pc, state);
        
        % %%%%%%%%%%%%%% Anemia
        
        eval(['Anemia.Dexp  = Anemia.',layer,'.D(1:5);']);
        eval(['Anemia.Ptm = Anemia.',layer,'.Ptm(1:5);']);
        eval(['MetSignalA = Anemia.',layer,'.MetSignal(1:5);']);
        
        [Anemia.Dmod, Anemia.Act, Anemia.Smyo, Anemia.Smeta, Anemia.SHR] = CarlsonModelTime(x, Anemia.Ptm, Anemia.Dexp, MetSignalA, Anemia.HR, Dc, Pc, state);
        
        % %%%%%%%%%%%%%% Dob+Anemia
        
        eval(['Dob.Dexp = Dob.',layer,'.D(1:5);']);
        eval(['Dob.Ptm = Dob.',layer,'.Ptm(1:5);']);
        eval(['MetSignalD = Dob.',layer,'.MetSignal(1:5);']);
        
        [Dob.Dmod, Dob.Act, Dob.Smyo, Dob.Smeta, Dob.SHR] = CarlsonModelTime(x, Dob.Ptm, Dob.Dexp, MetSignalD, Dob.HR, Dc, Pc, state);
        
    case 'passive'
        
        R = (Bp+1):0.1:(Ap-1);
        D = R*2;
        
        [T_pass, ~] = Tension(R, x);
        
        Control = T_pass./R;
        Anemia = D;
        
    case 'constricted'
        
        R = (Bp+1):0.1:(Ap-1);
        D = R*2;
        
        [T_pass, T_act] = Tension(R, x);
        
        Control = (T_pass + T_act)./R;
        Anemia = D;
        Dob = T_act./R;
        
end
