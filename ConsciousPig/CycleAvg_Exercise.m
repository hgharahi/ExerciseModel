function [var_endo, var_mid, var_epi] = CycleAvg_Exercise(test, var, k)

   
eval(['SubendoVar = test.Results.',var,'3;']);
eval(['MidVar = test.Results.',var,'2;']);
eval(['SubepiVar = test.Results.',var,'1;']);
eval(['t = test.Results.t;']);
eval('t_final = test.Results.t(end);');
eval('T = test.Testset(k).T;');

t_idx = t>t_final-2*T & t<=t_final;
Dt = diff(t);

SubendoVar = sum(SubendoVar(t_idx).*Dt(t_idx(2:end)))/(2*T);
var_endo(k) = mean(SubendoVar);

MidVar = sum(MidVar(t_idx).*Dt(t_idx(2:end)))/(2*T);
var_mid(k) = mean(MidVar);

SubepiVar = sum(SubepiVar(t_idx).*Dt(t_idx(2:end)))/(2*T);
var_epi(k) = mean(SubepiVar);


