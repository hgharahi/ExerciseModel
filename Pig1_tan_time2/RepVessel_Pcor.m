function [Control, Anemia, Dob] = RepVessel_Pcor(Control, Anemia, Dob)

% CPP = [40, 60, 80, 100, 120];

h = figure; hold on;
Rn = Control.mid.RA(4);


pl(1,1) = plot(Control.mid.Ptm(1:5), Control.mid.D,'o-','linewidth',1.5,'Color',[0    0.4470    0.7410]); hold on
pl(1,2) = plot(Control.endo.Ptm(1:5), Control.endo.D,'o--','linewidth',1.5,'Color',[0    0.4470    0.7410]);
pl(1,3) = plot(Control.epi.Ptm(1:5), Control.epi.D,'o-.','linewidth',1.5,'Color',[0    0.4470    0.7410]);


pl(2,1) = plot(Anemia.mid.Ptm(1:5), Anemia.mid.D(1:5),'o-','linewidth',1.5,'Color',[0.8500    0.3250    0.0980]);
pl(2,2) = plot(Anemia.endo.Ptm(1:5), Anemia.endo.D(1:5),'o--','linewidth',1.5,'Color',[0.8500    0.3250    0.0980]);
pl(2,3) = plot(Anemia.epi.Ptm(1:5), Anemia.epi.D(1:5),'o-.','linewidth',1.5,'Color',[0.8500    0.3250    0.0980]);


pl(3,1) = plot(Dob.mid.Ptm(1:5), Dob.mid.D(1:5),'o-','linewidth',1.5,'Color',[0.9290    0.6940    0.1250]);
pl(3,2) = plot(Dob.endo.Ptm(1:5), Dob.endo.D(1:5),'o--','linewidth',1.5,'Color',[0.9290    0.6940    0.1250]);
pl(3,3) = plot(Dob.epi.Ptm(1:5), Dob.epi.D(1:5),'o-.','linewidth',1.5,'Color',[0.9290    0.6940    0.1250]);

pl = pl';
L = legend(pl(:),{'C-Midwall','C-Subendo','C-Subepi','A-Midwall','A-Subendo','A-Subepi','D-Midwall','D-Subendo','D-Subepi'},'Location','best');
L.NumColumns = 3;
L.FontSize = 8;
ylim([90 190]);
xlabel('p_{tm} (mmHg)');
ylabel('$\bar{D}$ (-)','Interpreter','Latex');
box on;

% figure;
% 
Cp = 2.4;
Ap = 89;
Bp = 45;
phi_p = -20.0;
rho_m = 1.0e2;
Cm = 100;
phi_m = 70.44;

x = [Cp, Ap, Bp, phi_p, phi_m, Cm, rho_m];

R = (Bp+1):0.1:(Ap-1);
D = R*2;

P = (phi_p + Cp * (tan(pi*(R - Bp)./(Ap - Bp) - pi/2)));
Pact = rho_m .* exp( -Cm * ((R - phi_m)/phi_m).^2 );

[T_pass, T_act] = Tension(R, x);

Ppas = T_pass./R;
Pact = T_act./R;

plot(Ppas, D,'r','linewidth',1.5);
plot((Pact+Ppas), D,'b','linewidth',1.5);
