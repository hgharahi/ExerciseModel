clear;clc;close all;
% Created Sep 16 by HG

% global Testset t_final t_off
%% Reading data / modeling / analysis based on Pzf data from John Tune:

% Reading all the data from files
dat_files = dir([pwd '/*dat']);
num_dats = size(dat_files,1);
CPPcase = 100;
t_off = 3.50;
t_final = 7;

for i = 1:num_dats
    CMP = contains(dat_files(i).name,num2str(CPPcase));
    if CMP ~= 0
        idx = i;
        break;
    end
end
name = ['CPP',num2str(CPPcase)];% erase(dat_files(i).name,'.dat');
eval(['Testset','= DataPzf("',dat_files(i).name,'",',erase(name,'CPP'),');']);
% end

%% Parameter initialization and estimation
% b = C_pa, b(2) = x*R0m, V01, C11, cf1, rf1]
b0 = [0.013,   2.5,    .25,  0.006];
% b0 = [0.0100    1.0000    0.1000    0.0050];
bmin = [0.00001, 0.00001, 0.00001, 0.00001, 0.1, 1.0];
bmax = [0.1      , 5, 1, 0.01, 0.9, 3.0];

if max(size(gcp)) == 0
    parpool;
end


fun = @(x)obj_fun(x, Testset, t_final, t_off);

%% fmincon

% options = optimoptions('fmincon','Display','iter','Algorithm','interior-point');
% options = optimoptions(options,'UseParallel',true);
% x = fmincon(      fun,        x0,	A,	b,	Aeq,beq,lb,   ub,nonlcon, options)
% startTime = tic;
% [b, fval] = fmincon(fun,	b0, [], [], [], [], bmin,   [], [], options);
% optTime = toc(startTime);

%% GA

nvar = 6;
gaoptions = optimoptions('ga','MaxGenerations',100,'Display','iter');
    gaoptions = optimoptions(gaoptions,'UseParallel',true);
    gaoptions = optimoptions(gaoptions,'PopulationSize',20);
    gaoptions = optimoptions(gaoptions,'FunctionTolerance',1e-3);

startTime = tic;

gasol = ga(fun, nvar, [], [], [], [], bmin, bmax, [], gaoptions);

optTime = toc(startTime);


%% Final Evualtion


Filename = sprintf('GA_RES_%s', datestr(now,'mm-dd-HH-MM'));

saveas([Filename,'.mat']);

[A, Result_ON, Result_OFF, t]   = eval_fun(gasol, Testset, t_final, t_off);
mean(Result_ON.Q13(t>1)./Result_ON.Q11(t>1))