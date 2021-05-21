function var1 = CycleAvg2(test, var)

CPP = [40 ,60, 80, 100, 120, 140];

for i = 1:length(CPP)
    
eval(['Var = test.Results{1,',num2str(2*i-1),'}.',var,';'])

eval(['t = test.Results{1,',num2str(2*i-1),'}.t;']);
eval('t_off = test.t_off(i);');
eval('T = test.Testset(i).T;');

Var = Var(t>t_off-4*T & t<=t_off);
var1(i) = mean(Var);


end
