function A = obj_fun(x, Testset)

b = [x(1:7), x(14), x(15)];
beta = x(13);

A = zeros(1,length(Testset));

for i = 1:length(Testset)
    
    if contains(Testset(i).name,'40')
        
        if ~contains(Testset(i).name,'140')
        A(i) = obj_fun_NOT_baseline(b, x(8), Testset(i), Testset(i).t(end),  Testset(i).t_off, beta, 0.15);
        else
        A(i) = obj_fun_NOT_baseline(b, x(12), Testset(i), Testset(i).t(end),  Testset(i).t_off, beta,  0);    
        end
        
    elseif contains(Testset(i).name,'60')
        
        A(i) = obj_fun_NOT_baseline(b, x(9), Testset(i), Testset(i).t(end),  Testset(i).t_off, beta, 0.15);
        
    elseif contains(Testset(i).name,'80')
        
        A(i) = obj_fun_NOT_baseline(b, x(10), Testset(i), Testset(i).t(end),  Testset(i).t_off, beta, 0.25);
        
    elseif contains(Testset(i).name,'100')
        
        A(i) = obj_fun_baseline(b, Testset(i), Testset(i).t(end),  Testset(i).t_off);
        
    elseif contains(Testset(i).name,'120')
        
        A(i) = obj_fun_NOT_baseline(b, x(11), Testset(i), Testset(i).t(end),  Testset(i).t_off, beta, 0);
        
    end
    
end


A = sum(A);
