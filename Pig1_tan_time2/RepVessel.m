function [Control, Anemia, Dob] = RepVessel(Control, Anemia, Dob)

CPP = [40, 60, 80, 100, 120];

h = figure;
Rn = Control.mid.RA(4);

Control.mid.D = 100*(Control.VisRatio.*Rn./Control.mid.RA(1:5)).^(1/4);
Control.endo.D = 100*(Control.VisRatio.*Rn./Control.endo.RA(1:5)).^(1/4);
Control.epi.D = 100*(Control.VisRatio.*Rn./Control.epi.RA(1:5)).^(1/4);

pl(1,1) = plot(Control.mid.Ptm(1:5), Control.mid.D,'o-','linewidth',1.5,'Color',[0    0.4470    0.7410]); hold on
pl(1,2) = plot(Control.endo.Ptm(1:5), Control.endo.D,'o--','linewidth',1.5,'Color',[0    0.4470    0.7410]);
pl(1,3) = plot(Control.epi.Ptm(1:5), Control.epi.D,'o-.','linewidth',1.5,'Color',[0    0.4470    0.7410]);

Anemia.mid.D = 100*(Anemia.VisRatio.*Rn./Anemia.mid.RA(1:5)).^(1/4);
Anemia.endo.D = 100*(Anemia.VisRatio.*Rn./Anemia.endo.RA(1:5)).^(1/4);
Anemia.epi.D = 100*(Anemia.VisRatio.*Rn./Anemia.epi.RA(1:5)).^(1/4);

pl(2,1) = plot(Anemia.mid.Ptm(1:5), Anemia.mid.D,'o-','linewidth',1.5,'Color',[0.8500    0.3250    0.0980]);
pl(2,2) = plot(Anemia.endo.Ptm(1:5), Anemia.endo.D,'o--','linewidth',1.5,'Color',[0.8500    0.3250    0.0980]);
pl(2,3) = plot(Anemia.epi.Ptm(1:5), Anemia.epi.D,'o-.','linewidth',1.5,'Color',[0.8500    0.3250    0.0980]);

Dob.mid.D = 100*(Dob.VisRatio.*Rn./Dob.RAmid(1:5)).^(1/4);
Dob.endo.D = 100*(Dob.VisRatio.*Rn./Dob.RAendo(1:5)).^(1/4);
Dob.epi.D = 100*(Dob.VisRatio.*Rn./Dob.RAepi(1:5)).^(1/4);

pl(3,1) = plot(Dob.mid.Ptm(1:5), Dob.mid.D,'o-','linewidth',1.5,'Color',[0.9290    0.6940    0.1250]);
pl(3,2) = plot(Dob.endo.Ptm(1:5), Dob.endo.D,'o--','linewidth',1.5,'Color',[0.9290    0.6940    0.1250]);
pl(3,3) = plot(Dob.epi.Ptm(1:5), Dob.epi.D,'o-.','linewidth',1.5,'Color',[0.9290    0.6940    0.1250]);

pl = pl';
L = legend(pl(:),{'C-Midwall','C-Subendo','C-Subepi','A-Midwall','A-Subendo','A-Subepi','D-Midwall','D-Subendo','D-Subepi'},'Location','best');
L.NumColumns = 3;
xlabel('CPP (mmHg)','Interpreter','Latex');
ylabel('$\bar{D}$ (-)','Interpreter','Latex');
box on;
