function Case = Calculations_Exercise(Case, k)
%% This function evaluate the steady state hemodynamics and resistances.


%% Read simulation time, PLV, and CPP

Case.HR(k) = 1/Case.Testset(k).T*60;
t_final = Case.Results.t(end);
t_idx = Case.Results.t>t_final-2*Case.Testset(k).T & Case.Results.t<=t_final;
Dt = diff(Case.Results.t);
T = Case.Testset(k).T;
t = Case.Results.t(t_idx);

Ppa = Case.Results.P_PA(t_idx);
Case.PLV = interp1(Case.Testset(k).t,Case.Testset(k).PLV,Case.Results.t(t_idx));
Case.endo.Pim = Case.PLV*1.2*0.833;
Case.mid.Pim = Case.PLV*1.2*0.5;
Case.epi.Pim = Case.PLV*1.2*0.167;

%% Subendo

Qendo = Case.Results.Q13(t_idx);
Pendo = Case.Results.P13(t_idx);

Case.endo.RA(k) = sum(((Ppa - Pendo)./Qendo).*Dt(t_idx(2:end)))/(2*T);
Case.endo.Pl = (Ppa + Pendo)/2;
Case.endo.Ptm(k) = sum((Case.endo.Pl -   Case.endo.Pim).*Dt(t_idx(2:end)))/(2*T);
Case.endo.PC(k) =   sum((Pendo -   Case.endo.Pim).*Dt(t_idx(2:end)))/(2*T);
Case.endo.Q(k) = sum((Qendo).*Dt(t_idx(2:end)))/(2*T);
Case.endo.Pc(k) = sum((Pendo).*Dt(t_idx(2:end)))/(2*T);

%% Mid

Qmid = Case.Results.Q12(t_idx);
Pmid = Case.Results.P12(t_idx);

Case.mid.RA(k) = sum(((Ppa - Pmid)./Qmid).*Dt(t_idx(2:end)))/(2*T);
Case.mid.Pl = (Ppa + Pmid)/2;
Case.mid.Ptm(k) = sum((Case.mid.Pl -   Case.mid.Pim).*Dt(t_idx(2:end)))/(2*T);
Case.mid.PC(k) =   sum((Pmid -   Case.mid.Pim).*Dt(t_idx(2:end)))/(2*T);
Case.mid.Q(k) = sum((Qmid).*Dt(t_idx(2:end)))/(2*T);
Case.mid.Pc(k) = sum((Pmid).*Dt(t_idx(2:end)))/(2*T);

%% Subepi

Qepi = Case.Results.Q11(t_idx);
Pepi = Case.Results.P11(t_idx);

Case.epi.RA(k) = sum(((Ppa - Pepi)./Qepi).*Dt(t_idx(2:end)))/(2*T);
Case.epi.Pl = (Ppa + Pepi)/2;
Case.epi.Ptm(k) = sum((Case.epi.Pl -   Case.epi.Pim).*Dt(t_idx(2:end)))/(2*T);
Case.epi.PC(k) =   sum((Pepi -   Case.epi.Pim).*Dt(t_idx(2:end)))/(2*T);
Case.epi.Q(k) = sum((Qepi).*Dt(t_idx(2:end)))/(2*T);
Case.epi.Pc(k) = sum((Pepi).*Dt(t_idx(2:end)))/(2*T);

%% Total 
QPA = Case.Results.Q_PA(t_idx);
Case.QPA = sum(QPA.*Dt(t_idx(2:end)))/(2*T);

Case.tinp = linspace(t(1),t(end),300);
Case.Qpa = interp1(t,Case.Results.Q_PA(t_idx),Case.tinp');

return
