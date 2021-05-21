function [tdata,AoP,PLV,Flow] = ReadExerciseInput(data)

dt    = 1/500;
AoP   = data(:,2);
PLV   = 0.85*(data(:,3)-17);
% Plv   = data(:,3);
PLV   = smoothdata(PLV,'gaussian','smoothingfactor',0.015); %smoothing makes the numerics easier
Flow = data(:,1);
tdata = (0:(length(AoP)-1)).*dt;

% figure; clf; axes('position',[0.15 0.15 0.75 0.75]); hold on;
% plot(tdata,PLV,'k-','linewidth',1.5,'color',0.5*[1 1 1]);
% plot(tdata,AoP,'k-','linewidth',1.5);
% set(gca,'Fontsize',14); box on
% xlabel('time (sec)','interpreter','latex','fontsize',16);
% ylabel('Pressure (mmHg)','interpreter','latex','fontsize',16);

end