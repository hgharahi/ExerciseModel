function Pressures_AoPPLV(Testset)

for j = 1:6
    figure;
    plot(Testset(j).t,Testset(j).AoP,'LineWidth',2);
    hold on;
    plot(Testset(j).t,Testset(j).PLV,'LineWidth',2);
    xlabel('time (s)','Interpreter','latex','fontsize',16);
    ylabel('Pressure (mmHg)','Interpreter','latex','fontsize',16);
    legend('AoP','PLV','fontsize',16);
end
