function CheckCaps(Case, xendo, xmid, xepi, MetSignal)

[Case.D13, Case.A13, ~, Case.S_myo13, Case.S_meta13, Case.S_HR13] = RepModel_ParamSet(Case, 'endo', xendo, MetSignal);

[Case.D12, Case.A12, ~, Case.S_myo12, Case.S_meta12, Case.S_HR12] = RepModel_ParamSet(Case, 'mid', xmid, MetSignal);

[Case.D11, Case.A11, ~, Case.S_myo11, Case.S_meta11, Case.S_HR11] = RepModel_ParamSet(Case, 'epi', xepi, MetSignal);

C_C11 = [Case.Params(:).C11];
C_C12 = [Case.Params(:).C12];
C_C13 = [Case.Params(:).C13];
C_R11 = Case.epi.RA;
C_R12 = Case.mid.RA;
C_R13 = Case.endo.RA;

Cb_C11 = abs((sqrt(Case.Params(1).rf1/(Case.Params(1).cf1)^2*Case.Params(1).R01./C_R11)*Case.Params(1).V01-Case.Params(1).V01)./Case.epi.PC);
Cb_C12 = abs((sqrt(Case.Params(1).rf2/(Case.Params(1).cf2)^2*Case.Params(1).R01./C_R12)*Case.Params(1).V01-Case.Params(1).V01)./Case.mid.PC);
Cb_C13 = abs((sqrt(Case.Params(1).R01./C_R13)*Case.Params(1).V01-Case.Params(1).V01)./Case.endo.PC);
figure;
scatter(Cb_C11,C_C11,'filled','r');
hold on
scatter(Cb_C12,C_C12,'filled','g');
scatter(Cb_C13,C_C13,'filled','b');
plot([min([Cb_C11, Cb_C12, Cb_C13]) max([Cb_C11, Cb_C12, Cb_C13])],[min([Cb_C11, Cb_C12, Cb_C13]) max([Cb_C11, Cb_C12, Cb_C13])],'-k','LineWidth',2);
set(gca,'yscale','log');
set(gca,'xscale','log');
ylabel('Model 1 Estimated C1 (mL/mmHg)');
xlabel('C1 Average Approximation (mL/mmHg)');

end