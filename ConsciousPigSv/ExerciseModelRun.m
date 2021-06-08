clear;clc;close all;

addpath('../SRC_Perfusion');
addpath('../SRC_RepVessel');

if exist('Data_Ready','var')==1
else
    
    ReadParams;
    
end

MetSignal = MetOptions{3};

[Rest, Exercise] = ExerciseModelEvalFun2(xendo,xmid,xepi, Control, MetSignal);