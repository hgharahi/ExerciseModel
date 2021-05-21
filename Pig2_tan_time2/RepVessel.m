function [Control, Anemia] = RepVessel(Control, Anemia)

CPP = [40, 60, 80, 100, 120, 140];

h = figure;
Rn = Control.mid.RA(4);

Control.mid.D = 100*(Control.VisRatio.*Rn./Control.mid.RA).^(1/4);
Control.endo.D = 100*(Control.VisRatio.*Rn./Control.endo.RA).^(1/4);
Control.epi.D = 100*(Control.VisRatio.*Rn./Control.epi.RA).^(1/4);

pl(1,1) = plot(Control.mid.Ptm, Control.mid.D,'o-','linewidth',1.5,'Color',[0    0.4470    0.7410]); hold on
pl(1,2) = plot(Control.endo.Ptm, Control.endo.D,'o--','linewidth',1.5,'Color',[0    0.4470    0.7410]);
pl(1,3) = plot(Control.epi.Ptm, Control.epi.D,'o-.','linewidth',1.5,'Color',[0    0.4470    0.7410]);

Anemia.mid.D = 100*(Anemia.VisRatio.*Rn./Anemia.mid.RA).^(1/4);
Anemia.endo.D = 100*(Anemia.VisRatio.*Rn./Anemia.endo.RA).^(1/4);
Anemia.epi.D = 100*(Anemia.VisRatio.*Rn./Anemia.epi.RA).^(1/4);

pl(2,1) = plot(Anemia.mid.Ptm, Anemia.mid.D,'o-','linewidth',1.5,'Color',[0.8500    0.3250    0.0980]);
pl(2,2) = plot(Anemia.endo.Ptm, Anemia.endo.D,'o--','linewidth',1.5,'Color',[0.8500    0.3250    0.0980]);
pl(2,3) = plot(Anemia.epi.Ptm, Anemia.epi.D,'o-.','linewidth',1.5,'Color',[0.8500    0.3250    0.0980]);

pl = pl';
L = legend(pl(:),{'C-Midwall','C-Subendo','C-Subepi','A-Midwall','A-Subendo','A-Subepi'},'Location','best');
L.NumColumns = 3;
xlabel('CPP (mmHg)','Interpreter','Latex');
ylabel('$\bar{D}$ (-)','Interpreter','Latex');
box on;
