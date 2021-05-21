function [PLV, T] = LeftVenPerssure(AoP, t, dt)

AOP1   = smoothdata(AoP,'gaussian','smoothingfactor',0.2);
[pks, locs] = findpeaks(AOP1);
T = mean(diff(locs))*dt;
YY = zeros(size(pks,1),length(t));

for i = 1:length(pks)
    
    idx = t< (t(locs(i)) - T/4) | t > (t(locs(i))+ T/4);
    y = (pks(i)-5)*cos(2*pi/(2*T)*(t - t(locs(i))));
    y(idx) = 0;
    
    YY(i,:) = y ;
    
end

PLV = sum(YY,1)'+5;
PLV   = smoothdata(PLV,'gaussian','smoothingfactor',0.1);
end