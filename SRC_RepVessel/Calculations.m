function Case = Calculations(Case)
%% This function evaluate the steady state hemodynamics and resistances.

for j = 1:6
    
    %% Read simulation time, PLV, and CPP
    
    Case.HR(j) = 1/Case.Testset(j).T*60;
    T = Case.Testset(j).T;
    
    t_idx = Case.Results{1,2*j-1}.t>Case.t_off(j)-2*Case.Testset(j).T & Case.Results{1,2*j-1}.t<=Case.t_off(j);
    Dt = diff(Case.Results{1,2*j-1}.t);
    
    Ppa = Case.Results{1,2*j-1}.P_PA(t_idx);
    Case.PLV = interp1(Case.Testset(j).t,Case.Testset(j).PLV,Case.Results{1,2*j-1}.t(t_idx));
    Case.endo.Pim = Case.PLV*1.2*0.833;
    Case.mid.Pim = Case.PLV*1.2*0.5;
    Case.epi.Pim = Case.PLV*1.2*0.167;
    
    %% Subendo
    
    Qendo = Case.Results{1,2*j-1}.Q13(t_idx);
    Pendo = Case.Results{1,2*j-1}.P13(t_idx);
    
    Case.endo.RA(j) = sum(((Ppa - Pendo)./Qendo).*Dt(t_idx(2:end)))/(2*T);
    Case.endo.Pl = (Ppa + Pendo)/2;
    Case.endo.Ptm(j) = sum((Case.endo.Pl -   Case.endo.Pim).*Dt(t_idx(2:end)))/(2*T);
    Case.endo.PC(j) =   sum((Pendo -   Case.endo.Pim).*Dt(t_idx(2:end)))/(2*T);
    Case.endo.Q(j) = sum((Qendo).*Dt(t_idx(2:end)))/(2*T);
    Case.endo.Pc(j) = sum((Pendo).*Dt(t_idx(2:end)))/(2*T);
    
    %% Mid
    
    Qmid = Case.Results{1,2*j-1}.Q12(t_idx);
    Pmid = Case.Results{1,2*j-1}.P12(t_idx);
    
    Case.mid.RA(j) = sum(((Ppa - Pmid)./Qmid).*Dt(t_idx(2:end)))/(2*T);
    Case.mid.Pl = (Ppa + Pmid)/2;
    Case.mid.Ptm(j) = sum((Case.mid.Pl -   Case.mid.Pim).*Dt(t_idx(2:end)))/(2*T);
    Case.mid.PC(j) =   sum((Pmid -   Case.mid.Pim).*Dt(t_idx(2:end)))/(2*T);
    Case.mid.Q(j) = sum((Qmid).*Dt(t_idx(2:end)))/(2*T);
    Case.mid.Pc(j) = sum((Pmid).*Dt(t_idx(2:end)))/(2*T);
    
    %% Subepi
    
    Qepi = Case.Results{1,2*j-1}.Q11(t_idx);
    Pepi = Case.Results{1,2*j-1}.P11(t_idx);
    
    Case.epi.RA(j) = sum(((Ppa - Pepi)./Qepi).*Dt(t_idx(2:end)))/(2*T);
    Case.epi.Pl = (Ppa + Pepi)/2;
    Case.epi.Ptm(j) = sum((Case.epi.Pl -   Case.epi.Pim).*Dt(t_idx(2:end)))/(2*T);
    Case.epi.PC(j) =   sum((Pepi -   Case.epi.Pim).*Dt(t_idx(2:end)))/(2*T);
    Case.epi.Q(j) = sum((Qepi).*Dt(t_idx(2:end)))/(2*T);
    Case.epi.Pc(j) = sum((Pepi).*Dt(t_idx(2:end)))/(2*T);
    
end

return
