clear;clc;close all;

addpath('../SRC_Perfusion');
addpath('../SRC_RepVessel');

if exist('Data_Ready','var')==1
else
    
    ReadParams;
    
end


[Rest, Exercise] = ExerciseModelEvalFun2(xendo,xmid,xepi, Control, MetSignal);