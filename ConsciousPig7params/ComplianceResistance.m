function [C11, C12, C13] = ComplianceResistance(Case)


Rn = Case.Rn;

C_R11 = Rn*(Case.epi.D/100)^(-4);
C_R12 = Rn*(Case.mid.D/100)^(-4);
C_R13 = Rn*(Case.endo.D/100)^(-4);

t_final = Case.Results.t(end);
t_idx = Case.Results.t>t_final-4*Case.T & Case.Results.t<=t_final;
t = Case.Results.t(t_idx);
Case.tinp = linspace(t(1),t(end),300);
Case.Qpa = interp1(t,Case.Results.Q_PA(t_idx),Case.tinp');
Case.PLV1 = interp1(Case.t,Case.PLV,Case.Results.t(t_idx));
Case.endo.Pim = Case.PLV1*1.2*0.833;
Case.mid.Pim = Case.PLV1*1.2*0.5;
Case.epi.Pim = Case.PLV1*1.2*0.167;

Pendo = Case.Results.P13(t_idx);
Pmid = Case.Results.P12(t_idx);
Pepi = Case.Results.P11(t_idx);

Case.endo.PC    =   (Pendo -   Case.endo.Pim);
Case.mid.PC     =   (Pmid -   Case.mid.Pim);
Case.epi.PC     =   (Pepi -   Case.epi.Pim);

Rendo = Case.Results.R13(t_idx);
Rmid = Case.Results.R12(t_idx);
Repi = Case.Results.R11(t_idx);

mRendo = mean(interp1(t, Rendo, Case.tinp));
mRmid = mean(interp1(t, Rmid, Case.tinp));
mRepi = mean(interp1(t, Repi, Case.tinp));

Rendo = (C_R13./mRendo)*Rendo;
Rmid = (C_R12./mRmid)*Rmid;
Repi = (C_R11./mRepi)*Repi;

dPCdt = TwoPtDeriv(Case.endo.PC,mean(diff(t)));
Cidx = find(abs(dPCdt)<50);

C11 = abs((sqrt(Case.Params.rf1/(Case.Params.cf1)^2*Case.Params.R01./Repi)*Case.Params.V01-Case.Params.V01)./Case.epi.PC);
C12 = abs((sqrt(Case.Params.rf2/(Case.Params.cf2)^2*Case.Params.R01./Rmid)*Case.Params.V01-Case.Params.V01)./Case.mid.PC);
C13 = abs((sqrt(Case.Params.R01./Rendo(Cidx))*Case.Params.V01-Case.Params.V01)./Case.endo.PC(Cidx));

C11 = mean(interp1(t, C11, Case.tinp));
C12 = mean(interp1(t, C12, Case.tinp));
C13 = mean(C13);

return

