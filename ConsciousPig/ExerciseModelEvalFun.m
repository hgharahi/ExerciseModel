function obj = ExerciseModelEvalFun(y, Init,xendo,xmid,xepi,adjust_pars, Control, MetSignal)

x = [xendo,xmid,xepi];

for j = 1:length(adjust_pars)
    
    x(adjust_pars(j)) = y(j);
    x = reshape(x,12,3);
    xendo_S = x(:,1);
    xmid_S = x(:,2);
    xepi_S = x(:,3);
    
end


%% Initialize

Exercise = Init;

QPA = Exercise.QPA;

%%% Run State

err = 10;
c = 1;
while err>1e-3 && c<100
    
    [Exercise.endo.D, Act_Endo_E, S_myo_Endo_E, S_meta_Endo_E, S_HR_Endo_E] = RepModel_Exercise(Exercise, Control, 'endo', xendo_S, MetSignal);
    
    [Exercise.mid.D, Act_Mid_E, S_myo_Mid_E, S_meta_Mid_E, S_HR_Mid_E] = RepModel_Exercise(Exercise, Control, 'mid', xmid_S, MetSignal);
    
    [Exercise.epi.D, Act_Epi_E, S_myo_Epi_E, S_meta_Epi_E, S_HR_Epi_E] = RepModel_Exercise(Exercise, Control, 'epi', xepi_S, MetSignal);
    
    [C11, C12, C13] = ComplianceResistance(Exercise);
    
    Exercise.Params.C11 = 0.5*Exercise.Params.C11 + 0.5*C11;
    Exercise.Params.C12 = 0.5*Exercise.Params.C12 + 0.5*C12;
    Exercise.Params.C13 = 0.5*Exercise.Params.C13 + 0.5*C13;
    
    Exercise.Results = PerfusionModel( Exercise, 0);
    
    Exercise =   Calculations_Exercise(Exercise, 'Exercise');
       
    err = abs(QPA - Exercise.QPA);
    QPA = Exercise.QPA;
    
    c = c+1;
    
end
QPAS = interp1(Exercise.Results.t,   Exercise.Results.Q_PA, Exercise.t);
ENDOEPI = Exercise.Results.ENDOEPI;

r = 1./Exercise.Qexp(Exercise.t>2).* (QPAS(Exercise.t>2)' - Exercise.Qexp(Exercise.t>2))*1/(sqrt(length(Exercise.Qexp(Exercise.t>2))));
E1 = r'*r;
E2 = abs(ENDOEPI - 0.95);
obj = E1 + E2;

return;