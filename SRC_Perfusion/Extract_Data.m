function [Testset] = Extract_Data( i, t_off_count, t_off_cutoff, PLV_smoothing_factor)
% clear;clc;close all
% i = 1

load('data_all.mat');
set(groot,'defaultFigureVisible','on');

Names = who;

% i = 5; % Choose which data set you want!

eval(['DSet = ',Names{i},';']);

CPPcase = [140 120 100 80 60 40];
Testset = [];

for j = 1:6
    
    time =  table2array(DSet(:,(j-1)*5+2));
    time = time(~isnan(time));
    Data.t = etime(datevec(time(:)),datevec(time(1)));
    dt = Data.t(end)/length(Data.t);    

    Flow = table2array(DSet(:,(j-1)*5+4));
    Data.Flow = Flow(~isnan(Flow));
%     Data.Flow = Data.Flow(end-tstep_from_end:end);
    
    t1  = 0;
    flg = 0;
    
    while (t1 < Data.t(end) && flg == 0)
        
        count = sum(abs(Data.Flow((Data.t<(t1+1)) & (Data.t>t1)))<t_off_cutoff);
        
        t1 = t1 + dt;
        
        if count > t_off_count
            flg = 1;
            Data.t_off = t1;
            [~, idx_t_off] = min(abs(Data.t-t1));
        end
    end
    
   
    
    
    tstep_start = idx_t_off - ceil(7/dt); %% sets the index of the first point that we want to consider: 7 seconds after clamping the circuit. (7 can be adjusted!)       
    tstep_end = min(idx_t_off + ceil(4/dt),length(Data.t)); %% sets the index of the last point that we want to consider: 4 seconds after clamping the circuit. (4 can be adjusted!)
    
    Data.t_off = Data.t_off - Data.t(tstep_start);
    
    Data.t = Data.t(tstep_start:tstep_end) - Data.t(tstep_start);
        
    Data.Flow = Data.Flow(tstep_start:tstep_end);
    
    AoP = table2array(DSet(:,(j-1)*5+3));
    Data.AoP = AoP(~isnan(AoP));
    Data.AoP = Data.AoP(tstep_start:tstep_end);
    
    CPP = table2array(DSet(:,(j-1)*5+5));
    Data.CPP = CPP(~isnan(CPP));
    Data.CPP = Data.CPP(tstep_start:tstep_end);
         
    
    [PLV, T] = LeftVenPerssure(Data.AoP, Data.t, dt);
    
    figure;
    subplot(2,1,1);pl(1) = plot(Data.t, Data.AoP,'LineWidth',2);
    hold on;
    subplot(2,1,1);pl(2) = plot(Data.t, Data.CPP,'LineWidth',2);

    
    if flg == 1
        
        t_closed = [Data.t_off, Data.t_off];
        P = [0, 170];
        subplot(2,1,1);plot(t_closed, P,'k','LineWidth',2);

    end

    
    title([Names{i},' -- CPP=',num2str(140-(j-1)*20)],'interpreter','latex','fontsize',16);
    ylabel('Pressure (mmHg)','interpreter','latex','fontsize',16);
    xlabel('time (s)','interpreter','latex','fontsize',16);
    ylim([0 170]);
    legend(pl(1:2),{'AoP','CPP'});
    
    subplot(2,1,2);plot(Data.t, Data.Flow,'LineWidth',2); hold on
    
    if flg == 1
        
        t_closed = [Data.t_off, Data.t_off];
        F = [min(Data.Flow), max(Data.Flow)];
        subplot(2,1,2);plot(t_closed, 1.2*F,'k','LineWidth',2);
        
        N = floor(Data.t_off/T);
        if N>0
            Qmean(j) = mean(Data.Flow(Data.t<(N*T)));
        else
            Qmean(j) = mean(Data.Flow(Data.t<Data.t_off));
        end
        
    else
        
        Qmean = mean(Data.Flow);
        
    end
    
    ylabel('Flow (mL/min)','interpreter','latex','fontsize',16);
    xlabel('time (s)','interpreter','latex','fontsize',16);
    
    name = ['CPP',num2str(CPPcase(j))];% erase(dat_files(i).name,'.dat');
    eval([name,'= DataPzf(Data,CPPcase(j), PLV_smoothing_factor);']);
    eval(['Testset = [Testset , ',name,'];']);
    
    clear Data
end
h2 = figure;
plot(CPPcase, Qmean);
clear DSet

