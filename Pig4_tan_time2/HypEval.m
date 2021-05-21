clc;close all;

%%% IMPORTANT NOTE:

addpath('../SRC');

rng('shuffle');

if exist('Data_Ready','var')==1
else
    
    ReadData;
    
end

%% What is the Metabolic Signal?

MetOptions = {'QM','ATP','VariableSV','Generic','MVO2','QdS','Q','M2'};

for k = 1:length(MetOptions)
    
    MetSignal = MetOptions{k};
    
    %% Read from file
    fileID = ['Params_',num2str(i),'_',MetSignal,'.txt'];

    fid = fopen(fileID,'rt');
    tline1 = fgets(fid);
    tline2 = fgets(fid);
    tline3 = fgets(fid);

    eval(tline1);eval(tline2);eval(tline3);

    fclose('all');
    close all;

    PostPlots(Control, Anemia, Dob, 'endo', i, xendo, MetSignal)

    PostPlots(Control, Anemia, Dob, 'mid', i, xmid, MetSignal)

    PostPlots(Control, Anemia, Dob, 'epi', i, xepi, MetSignal)


end
