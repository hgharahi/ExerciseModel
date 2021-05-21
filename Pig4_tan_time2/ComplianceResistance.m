function [Case] = ComplianceResistance(Case, Control, k)


Rn = Control.mid.RA(4);

C_R13 = Rn*(Case.endo.D(k)/100)^(-4);
C_R12 = Rn*(Case.mid.D(k)/100)^(-4);
C_R11 = Rn*(Case.epi.D(k)/100)^(-4);

C11 = (sqrt(Case.Params(1).rf1/(Case.Params(1).cf1)^2*Case.Params(1).R01./C_R11)*Case.Params(1).V01-Case.Params(1).V01)./Case.epi.PC(k);
C12 = (sqrt(Case.Params(1).rf2/(Case.Params(1).cf2)^2*Case.Params(1).R01./C_R12)*Case.Params(1).V01-Case.Params(1).V01)./Case.mid.PC(k);
C13 = (sqrt(Case.Params(1).R01./C_R13)*Case.Params(1).V01-Case.Params(1).V01)./Case.endo.PC(k);

Case.Params(k).C11 = 0.9*abs(C11)+0.1*Case.Params(k).C11;
Case.Params(k).C12 = 0.9*abs(C12)+0.1*Case.Params(k).C12;
Case.Params(k).C13 = 0.9*abs(C13)+0.1*Case.Params(k).C13;