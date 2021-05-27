function obj = ExerciseModelObjFun(y, Init,xendo,xmid,xepi,adjust_pars, Control, MetSignal)

x = [xendo,xmid,xepi];
for j = 1:length(adjust_pars)
    
    x(adjust_pars(j)) = y(j);
    x = reshape(x,12,3);
    xendo_S = x(:,1);
    xmid_S = x(:,2);
    xepi_S = x(:,3);
    
end


%% Initialize

Case = Init;

QPA = Case.QPA;

%%% Run State

err = 10;
c = 1;
while err>1e-3 && c<100
    
    [Case.endo.D, Act_Endo_E, S_myo_Endo_E, S_meta_Endo_E, S_HR_Endo_E] = RepModel_Exercise(Case, Control, 'endo', xendo_S, MetSignal);
    
    [Case.mid.D, Act_Mid_E, S_myo_Mid_E, S_meta_Mid_E, S_HR_Mid_E] = RepModel_Exercise(Case, Control, 'mid', xmid_S, MetSignal);
    
    [Case.epi.D, Act_Epi_E, S_myo_Epi_E, S_meta_Epi_E, S_HR_Epi_E] = RepModel_Exercise(Case, Control, 'epi', xepi_S, MetSignal);
    
    [C11, C12, C13] = ComplianceResistance(Case);
    
    Case.Params.C11 = 0.5*Case.Params.C11 + 0.5*C11;
    Case.Params.C12 = 0.5*Case.Params.C12 + 0.5*C12;
    Case.Params.C13 = 0.5*Case.Params.C13 + 0.5*C13;
    
    Case.Results = PerfusionModel( Case, 0);
    
    Case =   Calculations_Exercise(Case, 'Exercise');
       
    err = abs(QPA - Case.QPA);
    QPA = Case.QPA;
    
    c = c+1;
    
end
QPAS = interp1(Case.Results.t,   Case.Results.Q_PA, Case.t);
ENDOEPI = Case.Results.ENDOEPI;

r = 1./Case.Qexp(Case.t>2).* (QPAS(Case.t>2)' - Case.Qexp(Case.t>2))*1/(sqrt(length(Case.Qexp(Case.t>2))));
E1 = r'*r;
E2 = abs(ENDOEPI - 0.95);
obj = E1 + E2;

return;
