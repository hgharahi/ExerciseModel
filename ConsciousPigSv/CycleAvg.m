function [var_endo, var_mid, var_epi] = CycleAvg(test, var)

CPP = [40 ,60, 80, 100, 120, 140];

for i = 1:length(CPP)
    
eval(['SubendoVar = test.Results{1,',num2str(2*i-1),'}.',var,'3;']);
eval(['MidVar = test.Results{1,',num2str(2*i-1),'}.',var,'2;']);
eval(['SubepiVar = test.Results{1,',num2str(2*i-1),'}.',var,'1;']);
eval(['t = test.Results{1,',num2str(2*i-1),'}.t;']);
eval('t_off = test.t_off(i);');
eval('T = test.Testset(i).T;');

t_idx = t>t_off-2*T & t<=t_off;
Dt = diff(t);

SubendoVar = sum(SubendoVar(t_idx).*Dt(t_idx(2:end)))/(2*T);
var_endo(i) = mean(SubendoVar);

MidVar = sum(MidVar(t_idx).*Dt(t_idx(2:end)))/(2*T);
var_mid(i) = mean(MidVar);

SubepiVar = sum(SubepiVar(t_idx).*Dt(t_idx(2:end)))/(2*T);
var_epi(i) = mean(SubepiVar);

end
