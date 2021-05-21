function [gaoptions] = GA_setup()


gaoptions = optimoptions('ga','MaxGenerations',10,'Display','iter','CreationFcn','gacreationlinearfeasible','MutationFcn', ... 
@mutationadaptfeasible);
    gaoptions = optimoptions(gaoptions,'UseParallel',true);
    gaoptions = optimoptions(gaoptions,'PopulationSize',10);
    gaoptions = optimoptions(gaoptions,'FunctionTolerance',1e-8);
    gaoptions = optimoptions(gaoptions,'OutputFcn',@GA_DISP);
