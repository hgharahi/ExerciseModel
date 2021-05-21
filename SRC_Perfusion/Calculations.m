function Case = Calculations(Case)
%% This function evaluate the steady state hemodynamics and resistances.

for j = 1:6
    
    %% Read simulation time, PLV, and CPP
    
    Case.HR(j) = 1/Case.Testset(j).T*60;
    
    t_idx = Case.Results{1,2*j-1}.t>Case.t_off(j)-2*Case.Testset(j).T & Case.Results{1,2*j-1}.t<=Case.t_off(j);
    Ppa = Case.Results{1,2*j-1}.P_PA(t_idx);
    Case.PLV = Case.Testset(j).PLV(t_idx);
    Case.endo.Pim = Case.PLV*1.2*0.833;
    Case.mid.Pim = Case.PLV*1.2*0.5;
    Case.epi.Pim = Case.PLV*1.2*0.167;
    
    %% Subendo
    
    Qendo = Case.Results{1,2*j-1}.Q13(t_idx);
    Pendo = Case.Results{1,2*j-1}.P13(t_idx);
    Case.endo.RA(j) = mean((Ppa - Pendo)./Qendo);
    Case.endo.Pl = (Ppa + Pendo)/2;
    Case.endo.Ptm(j) =   mean(Case.endo.Pl -   Case.endo.Pim);
    %% Mid
    
    Qmid = Case.Results{1,2*j-1}.Q12(t_idx);
    Pmid = Case.Results{1,2*j-1}.P12(t_idx);    
    Case.mid.RA(j) = mean((Ppa - Pmid)./Qmid);
    Case.mid.Pl = (Ppa + Pmid)/2;
    Case.mid.Ptm(j) =   mean(Case.mid.Pl -   Case.mid.Pim);
    
    %% Subepi
    
    Qepi = Case.Results{1,2*j-1}.Q11(t_idx);    
    Pepi = Case.Results{1,2*j-1}.P11(t_idx);    
    Case.epi.RA(j) = mean((Ppa - Pepi)./Qepi);
    Case.epi.Pl = (Ppa + Pepi)/2;
    Case.epi.Ptm(j) =   mean(Case.epi.Pl -   Case.epi.Pim);
    
end