classdef DataPzf
    
    properties
        filename;
        t;
        T;
        AoP;
        CPP;
        PLV;
        dPLV;
        Flow;
        t_off;
        name;
        Ppump;
    end
    
    methods
        function measurements = DataPzf(Data,Pin, smoothingfactor)
            
            measurements.AoP =  Data.AoP;
            measurements.Flow =  Data.Flow;
            measurements.CPP =  Data.CPP;
            measurements.t = Data.t;
            measurements.t_off = Data.t_off;
            [measurements.PLV, measurements.T] = LeftVenPerssure(measurements, smoothingfactor);
            measurements.Ppump = PumpPerssure(measurements,Pin);
            measurements.name = ['CPP',num2str(Pin)];
        end
        
        function DT = dt(measurements)
            
            DT = mean(diff(measurements.t));
            
        end
        
       
        function dataplots(measurements)
            
            figure;
            subplot(2,1,1);
            plot(measurements.t, measurements.AoP); hold on;
            plot(measurements.t, measurements.CPP);
            xlabel('time (s)'); grid on;
            ylabel('Pressure (mmHg)');
            legend(['AoP'; 'CPP']);
            axis([0 11 0 180]);
            subplot(2,1,2);
            plot(measurements.t, measurements.Flow);
            xlabel('time (s)'); grid on;
            ylabel('Flow rate (mL/min)');
            legend('LAD flow');
            xlim([0 11])
            sgtitle(measurements.name);
            
        end
        
        function Qmean = FlowAverage(measurements)
            
            Q1   = smoothdata(measurements.Flow,'gaussian','smoothingfactor',0.5);
            [~, locs] = findpeaks(-Q1);
            Qmean = mean(measurements.Flow(locs(2):locs(7))); 
            % 2:5 are based on the data, the peak indices that will not extend to the zero flow part,
            %yet, there is an offset with the beginning of measurements
            
        end
    end
end

function t = ExpTime(a)


[b, ~] = size(a.textdata) ;
str1 = string(a.textdata(3,1));
k1 = strfind(char(a.textdata(3,1)),':');

str2 = string(a.textdata(b,1));
k2 = strfind(char(a.textdata(b,1)),':');

time1 = str2double(str1{1}(1:k1-1)) * 60 + str2double(str1{1}(k1+1:end));
time2 = str2double(str2{1}(1:k2-1)) * 60 + str2double(str2{1}(k2+1:end));
duration = time2 - time1;

[b, ~] = size(a.data) ;
dt  =  duration/b;
t = [0:(b-1)]'*dt;

end

function [PLV, T] = LeftVenPerssure(measurements, smoothingfactor)

AOP1   = smoothdata(measurements.AoP,'gaussian','smoothingfactor', smoothingfactor);
[~, locs] = findpeaks(AOP1);
pks = measurements.AoP(locs);
T = mean(diff(locs))*measurements.dt;
YY = zeros(size(pks,1),length(measurements.t));

for i = 1:length(pks)
    
    idx = measurements.t< (measurements.t(locs(i)) - T/4) | measurements.t > (measurements.t(locs(i))+ T/4);
    y = (pks(i)-5)*cos(2*pi/(2*T)*(measurements.t - measurements.t(locs(i))));
    y(idx) = 0;
    
    YY(i,:) = y ;
    
end

PLV = sum(YY,1)'+5;

end

function Ppump = PumpPerssure(measurements, Pin)

Ppump = [Pin + 0*sin(2*pi*1.5*(measurements.t))]';

end

