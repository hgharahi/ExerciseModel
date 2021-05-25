function obj = ExerciseModelObjFun(y, Init,xendo,xmid,xepi,adjust_pars, Control, MetSignal)

for j = 1:length(adjust_pars)
    
    x = [xendo,xmid,xepi];
    x(adjust_pars(j)) = y(j);
    x = reshape(x,12,3);
    xendo_S = x(:,1);
    xmid_S = x(:,2);
    xepi_S = x(:,3);
    
end


%% Initialize

Rest = Init;

QPA = Rest.QPA;

%%% Run State

err = 10;
c = 1;
while err>1e-3 && c<15
    
    [Rest.endo.D, Act_Endo_E, S_myo_Endo_E, S_meta_Endo_E, S_HR_Endo_E] = RepModel_Exercise(Rest, Control, 'endo', xendo_S, MetSignal);
    
    [Rest.mid.D, Act_Mid_E, S_myo_Mid_E, S_meta_Mid_E, S_HR_Mid_E] = RepModel_Exercise(Rest, Control, 'mid', xmid_S, MetSignal);
    
    [Rest.epi.D, Act_Epi_E, S_myo_Epi_E, S_meta_Epi_E, S_HR_Epi_E] = RepModel_Exercise(Rest, Control, 'epi', xepi_S, MetSignal);
    
    [C11, C12, C13] = ComplianceResistance(Rest);
    
    Rest.Params.C11 = 0.2*Rest.Params.C11 + 0.8*C11;
    Rest.Params.C12 = 0.2*Rest.Params.C12 + 0.8*C12;
    Rest.Params.C13 = 0.2*Rest.Params.C13 + 0.8*C13;
    
    Rest.Results = PerfusionModel( Rest, 0);
    
    Rest =   Calculations_Exercise(Rest, 'Exercise');
       
    err = abs(QPA - Rest.QPA);
    QPA = Rest.QPA;
    
    c = c+1;
    
end
QPAS = interp1(Rest.Results.t,   Rest.Results.Q_PA, Rest.t);
ENDOEPI = Rest.Results.ENDOEPI;

r = 1./Rest.Qexp(Rest.t>2).* (QPAS(Rest.t>2)' - Rest.Qexp(Rest.t>2))*1/(sqrt(length(Rest.Qexp(Rest.t>2))));
E1 = r'*r;
E2 = abs(ENDOEPI - 1.2);
obj = E1 + E2;

return;