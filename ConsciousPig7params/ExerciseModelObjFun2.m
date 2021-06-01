function obj = ExerciseModelObjFun2(y, InitR, InitE,xendo,xmid,xepi,adjust_pars, Control, MetSignal)

x = [xendo,xmid,xepi];
for j = 1:length(adjust_pars)
    
    x(adjust_pars(j)) = y(j);
    x = reshape(x,12,3);
    xendo_S = x(:,1);
    xmid_S = x(:,2);
    xepi_S = x(:,3);
    
end



%% Initialize Rest

Rest = InitR;

QPA = Rest.QPA;

%% Run Rest

% xendo_S = C0finder(Rest, 'endo', xendo_S, MetSignal);
% xmid_S = C0finder(Rest, 'mid', xmid_S, MetSignal);
% xepi_S = C0finder(Rest, 'epi', xepi_S, MetSignal);

err = 10;
c = 1;
while err>1e-3 && c<50
    
    [Rest.endo.D, Rest.Act_Endo, R.S_myo_Endo, R.S_meta_Endo, R.S_HR_Endo] = RepModel_Exercise(Rest, Control, 'endo', xendo_S, MetSignal);
    
    [Rest.mid.D, Rest.Act_Mid, Rest.S_myo_Mid, Rest.S_meta_Mid, Rest.S_HR_Mid] = RepModel_Exercise(Rest, Control, 'mid', xmid_S, MetSignal);
    
    [Rest.epi.D, Rest.Act_Epi, Rest.S_myo_Epi, Rest.S_meta_Epi, Rest.S_HR_Epi] = RepModel_Exercise(Rest, Control, 'epi', xepi_S, MetSignal);
    
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
Rest.Results = PerfusionModel( Rest, 1);
QPAS = interp1(Rest.Results.t,   Rest.Results.Q_PA, Rest.t);
ENDOEPI = Rest.Results.ENDOEPI;
ENDOMID = Rest.Results.ENDOMID;

r = 1./Rest.Qexp(Rest.t>2).* (QPAS(Rest.t>2)' - Rest.Qexp(Rest.t>2))*1/(sqrt(length(Rest.Qexp(Rest.t>2))));
E1 = r'*r;
E2 = abs(ENDOEPI - 1.2);
E3 = abs(ENDOMID - 1.1);
Rest.obj = E1 + E2 + 0.5*E3;


%% Initialize Exercise

Exercise = InitE;
QPA = Exercise.QPA;

%% Run Exercise

err = 10;
c = 1;
while err>1e-3 && c<50
    
    [Exercise.endo.D, Exercise.Act_Endo, Exercise.S_myo_Endo, Exercise.S_meta_Endo, Exercise.S_HR_Endo] = RepModel_Exercise(Exercise, Control, 'endo', xendo_S, MetSignal);
    
    [Exercise.mid.D, Exercise.Act_Mid, Exercise.S_myo_Mid, Exercise.S_meta_Mid, Exercise.S_HR_Mid] = RepModel_Exercise(Exercise, Control, 'mid', xmid_S, MetSignal);
    
    [Exercise.epi.D, Exercise.Act_Epi, Exercise.S_myo_Epi, Exercise.S_meta_Epi, Exercise.S_HR_Epi] = RepModel_Exercise(Exercise, Control, 'epi', xepi_S, MetSignal);
    
    [C11, C12, C13] = ComplianceResistance(Exercise);
    
    Exercise.Params.C11 = 0.2*Exercise.Params.C11 + 0.8*C11;
    Exercise.Params.C12 = 0.2*Exercise.Params.C12 + 0.8*C12;
    Exercise.Params.C13 = 0.2*Exercise.Params.C13 + 0.8*C13;
    
    Exercise.Results = PerfusionModel( Exercise, 0);
    
    Exercise =   Calculations_Exercise(Exercise, 'Exercise');
       
    err = abs(QPA - Exercise.QPA);
    QPA = Exercise.QPA;
    
    c = c+1;
    
end

Exercise.Results = PerfusionModel( Exercise, 1);
QPAS = interp1(Exercise.Results.t,   Exercise.Results.Q_PA, Exercise.t);
ENDOEPI = Exercise.Results.ENDOEPI;
ENDOMID = Exercise.Results.ENDOMID;

r = 1./Exercise.Qexp(Exercise.t>2).* (QPAS(Exercise.t>2)' - Exercise.Qexp(Exercise.t>2))*1/(sqrt(length(Exercise.Qexp(Exercise.t>2))));
E1 = r'*r;
E2 = abs(ENDOEPI - 0.95);
E3 = abs(ENDOMID - 0.975);
Exercise.obj = E1 + E2 + 0.5*E3;

obj = Exercise.obj + Rest.obj;
return;
