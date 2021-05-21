function Params = PerfusionModel_ParamSet(x, Testset)

b = [x(1:7), x(14), x(15)];

if contains(Testset.name,'40')
    if ~contains(Testset.name,'140')
        fact =  x(8);
        Params = ModelParameters_ParamEst(b , fact, x(13));
    else
        fact = x(12);
        Params = ModelParameters_ParamEst(b , fact, x(13));
    end
elseif contains(Testset.name,'60')
    fact =  x(9);
    Params = ModelParameters_ParamEst(b , fact, x(13));
elseif contains(Testset.name,'80')
    fact = x(10);
    Params = ModelParameters_ParamEst(b , fact, x(13));
elseif contains(Testset.name,'100')
    fact = 1;
    Params = ModelParameters_ParamEst(b , fact, x(13));
elseif contains(Testset.name,'120')
    fact = x(11);
    Params = ModelParameters_ParamEst(b , fact, x(13));    
end

