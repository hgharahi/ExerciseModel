clear;clc;close all;
%% Read the estimated parameters for all the layers of all pigs

%% What is the Metabolic Signal?

MetOptions = {'QM','ATP','VariableSV','Generic','MVO2','QdS','Q','M2'};
MetSignal = MetOptions{1};

%% Read RepVessel Model Parameters
for i = 1:4
    
fileID = ['Params_',num2str(i),'_',MetSignal,'.txt'];
fid = fopen(fileID,'rt');
tline1 = fgets(fid);
tline2 = fgets(fid);
tline3 = fgets(fid);

eval(tline1);eval(tline2);eval(tline3);

fclose('all');

subendo.x(:,i) = xendo';
mid.x(:,i) = xmid';
subepi.x(:,i) = xepi';

end

%% determining fixed and adjustable parameters
x = [subendo.x;mid.x;subepi.x];
xmean = mean(x,2);
CoV = std(x./xmean,0,2);
adjustables = find(CoV>0);
fixed = find(CoV<=0);

param_names = {'Cp', 'Ap', 'Bp', 'phi_p', 'phi_m', 'Cm', 'rho', 'C_myo', 'C_met', 'C_HR', 'C0', 'HR0'};

ReadData;

