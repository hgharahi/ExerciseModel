function Case = Calculations_Exercise(Case, state)
%% This function evaluate the steady state hemodynamics and resistances.


%% Read simulation time, PLV, and CPP

Case.HR = 1/Case.T*60;
t_final = Case.Results.t(end);
t_idx = Case.Results.t>t_final-4*Case.T & Case.Results.t<=t_final;
Dt = diff(Case.Results.t);
T = Case.T;
t = Case.Results.t(t_idx);

Ppa = Case.Results.P_PA(t_idx);
Case.PLV1 = interp1(Case.t,Case.PLV,Case.Results.t(t_idx));
Case.endo.Pim = Case.PLV1*1.2*0.833;
Case.mid.Pim = Case.PLV1*1.2*0.5;
Case.epi.Pim = Case.PLV1*1.2*0.167;

%% Subendo

Qendo = Case.Results.Q13(t_idx);
Pendo = Case.Results.P13(t_idx);

Case.endo.RA = sum(((Ppa - Pendo)./Qendo).*Dt(t_idx(2:end)))/(4*T);
Case.endo.Pl = (Ppa + Pendo)/2;
Case.endo.Ptm = sum((Case.endo.Pl -   Case.endo.Pim).*Dt(t_idx(2:end)))/(4*T);
Case.endo.PC =   sum((Pendo -   Case.endo.Pim).*Dt(t_idx(2:end)))/(4*T);
Case.endo.Q = sum((Qendo).*Dt(t_idx(2:end)))/(4*T);
Case.endo.Pc = sum((Pendo).*Dt(t_idx(2:end)))/(4*T);

%% Mid

Qmid = Case.Results.Q12(t_idx);
Pmid = Case.Results.P12(t_idx);

Case.mid.RA = sum(((Ppa - Pmid)./Qmid).*Dt(t_idx(2:end)))/(4*T);
Case.mid.Pl = (Ppa + Pmid)/2;
Case.mid.Ptm = sum((Case.mid.Pl -   Case.mid.Pim).*Dt(t_idx(2:end)))/(4*T);
Case.mid.PC =   sum((Pmid -   Case.mid.Pim).*Dt(t_idx(2:end)))/(4*T);
Case.mid.Q = sum((Qmid).*Dt(t_idx(2:end)))/(4*T);
Case.mid.Pc = sum((Pmid).*Dt(t_idx(2:end)))/(4*T);

%% Subepi

Qepi = Case.Results.Q11(t_idx);
Pepi = Case.Results.P11(t_idx);

Case.epi.RA = sum(((Ppa - Pepi)./Qepi).*Dt(t_idx(2:end)))/(4*T);
Case.epi.Pl = (Ppa + Pepi)/2;
Case.epi.Ptm = sum((Case.epi.Pl -   Case.epi.Pim).*Dt(t_idx(2:end)))/(4*T);
Case.epi.PC =   sum((Pepi -   Case.epi.Pim).*Dt(t_idx(2:end)))/(4*T);
Case.epi.Q = sum((Qepi).*Dt(t_idx(2:end)))/(4*T);
Case.epi.Pc = sum((Pepi).*Dt(t_idx(2:end)))/(4*T);


%% Eqiovalent diameter calculation
switch state
    case 'Baseline'
        Case.Rn = Case.mid.RA;
    otherwise
end
Case.endo.D = 100*(Case.Rn./Case.endo.RA).^(1/4);
Case.mid.D = 100*(Case.Rn./Case.mid.RA).^(1/4);
Case.epi.D = 100*(Case.Rn./Case.epi.RA).^(1/4);
%% Total 
QPA = Case.Results.Q_PA(t_idx);
Case.QPA = sum(QPA.*Dt(t_idx(2:end)))/(4*T);

Case.tinp = linspace(t(1),t(end),300);
Case.Qpa = interp1(t,Case.Results.Q_PA(t_idx),Case.tinp');

return
