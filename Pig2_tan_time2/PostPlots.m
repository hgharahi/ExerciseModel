function PostPlots(Control, Anemia, Dob, layer, i, x, MetSignal)

clear pl;

y = x;

Control.Color	=	[62 88 166]/255;
Anemia.Color	=	[37 158 49]/255;
Dob.Color       =	[238 31 35]/255;
%% Autoregulation

[Control, Anemia, Dob] = TanModelHR_eval(y, Control, Anemia, Dob, layer,'normal', MetSignal);

h = figure;
[~, idxC] = sort(Control.Ptm);
[~, idxA] = sort(Anemia.Ptm);
% [~, idxD] = sort(Dob.Ptm);

pl(1) = plot(Control.Ptm(idxC), Control.Dexp(idxC)/100,'o','linewidth',2.5,'color',Control.Color);hold on
pl(2) = plot(Control.Ptm(idxC), Control.Dmod(idxC)/100,'--s','linewidth',1.5,'color',Control.Color); 

pl(3) = plot(Anemia.Ptm(idxA), Anemia.Dexp(idxA)/100,'o','linewidth',2.5,'color',Anemia.Color); 
pl(4) = plot(Anemia.Ptm(idxA), Anemia.Dmod(idxA)/100,'--s','linewidth',1.5,'color',Anemia.Color); 

% pl(5) = plot(Dob.Ptm(idxD), Dob.Dexp(idxD)/100,'o','linewidth',2.5,'color',Dob.Color); 
% pl(6) = plot(Dob.Ptm(idxD), Dob.Dmod(idxD)/100,'--s','linewidth',1.5,'color',Dob.Color); 

xlabel('$p_{tm}$ (mmHg)','Interpreter','Latex','FontSize',22);
ylabel('$\bar{D}$ (-)','Interpreter','Latex','FontSize',22);
box off;

%% Passive

[Pp, Dp, ~] = TanModelHR_eval(y, Control , Anemia, Dob, layer,'passive', MetSignal);


pl(7) = plot(Pp, Dp/100,'--k','linewidth',1.5); 

%% Fully active

[Pact, Dm, Pmax] = TanModelHR_eval(y, Control , Anemia, Dob, layer,'constricted', MetSignal);


pl(8) = plot(Pact, Dm/100,':k','linewidth',1.5); 

xlim([-50 100]);

saveas(h,['Dbar_ParamEst',layer,num2str(i),'.png']);


ax1 = gca;
hp = figure;

ax2 = copyobj(ax1,hp);
ax1Chil = ax1.Children; 
copyobj(ax1Chil, ax2)

legend('Control Model 1','Control Model 2','Anemia Model 1','Anemia Model 2','A = 0 (Passive)','A = 1 (Constricted)','Location','southeast','FontSize',14);
set(gcf,'Position',[0,0,1024,1024]);
legend_handle = legend('Orientation','vertical');
set(gcf,'Position',(get(legend_handle,'Position')...
    .*[0, 0, 1, 1].*get(gcf,'Position')));
set(legend_handle,'Position',[0,0,1,1]);
set(gcf, 'Position', get(gcf,'Position') + [500, 400, 0, 0]);

saveas(hp,['Legend',layer,num2str(i),'.png']);
%% Activation and signal plots

h1 = figure; hold on;
plot(Control.Ptm(idxC),Control.Act(idxC),'--s','linewidth',1.5,'Color',Control.Color);
plot(Anemia.Ptm(idxA),Anemia.Act(idxA),'--s','linewidth',1.5,'Color',Anemia.Color);
% plot(Dob.Ptm(idxD),Dob.Act(idxD),'--s','linewidth',1.5,'Color',Dob.Color);
% legend('Control','Anemia','Dob+Anemia','Location','best');
xlabel('$p_{tm}$ (mmHg)','Interpreter','Latex','FontSize',22);
ylabel('A (-)','Interpreter','Latex','FontSize',22);

saveas(h1,['Act_ParamEst',layer,num2str(i),'.png']);


h2 = figure; hold on;
plot(Control.Ptm(idxC),Control.Smeta(idxC),'--s','linewidth',1.5,'Color',Control.Color);
plot(Anemia.Ptm(idxA),Anemia.Smeta(idxA),'--s','linewidth',1.5,'Color',Anemia.Color);
% plot(Dob.Ptm(idxD),Dob.Smeta(idxD),'--s','linewidth',1.5,'Color',Dob.Color);
% legend('Control','Anemia','Dob+Anemia','Location','best');
xlabel('$p_{tm}$ (mmHg)','Interpreter','Latex','FontSize',22);
ylabel('$S_{meta}$ (-)','Interpreter','Latex','FontSize',22);
set(gca,'FontSize',22);

saveas(h2,['Smeta_ParamEst',layer,num2str(i),'.png']);

h3 = figure; hold on;
plot(Control.Ptm(idxC),Control.Smyo(idxC),'--s','linewidth',1.5,'Color',Control.Color);
plot(Anemia.Ptm(idxA),Anemia.Smyo(idxA),'--s','linewidth',1.5,'Color',Anemia.Color);
% plot(Dob.Ptm(idxD),Dob.Smyo(idxD),'--s','linewidth',1.5,'Color',Dob.Color);
% legend('Control','Anemia','Dob+Anemia','Location','best');
xlabel('$p_{tm}$ (mmHg)','Interpreter','Latex','FontSize',22);
ylabel('$S_{myo}$ (-)','Interpreter','Latex','FontSize',22);
set(gca,'FontSize',22);

saveas(h3,['Smyo_ParamEst',layer,num2str(i),'.png']);

h4 = figure; hold on;
plot(Control.Ptm(idxC),Control.SHR(idxC),'--s','linewidth',1.5,'Color',Control.Color);
plot(Anemia.Ptm(idxA),Anemia.SHR(idxA),'--s','linewidth',1.5,'Color',Anemia.Color);
% plot(Dob.Ptm(idxD),Dob.SHR(idxD),'--s','linewidth',1.5,'Color',Dob.Color);
% legend('Control','Anemia','Dob+Anemia','Location','best');
xlabel('$p_{tm}$ (mmHg)','Interpreter','Latex','FontSize',22);
ylabel('$S_{HR}$ (-)','Interpreter','Latex','FontSize',22);
set(gca,'FontSize',22);

saveas(h4,['SHR_ParamEst',layer,num2str(i),'.png']);
% 
% h5 = figure; hold on;
% plot(Control.Ptm,eval(['Control.',layer,'.MVO2']),'linewidth',1.5);
% plot(Anemia.Ptm,eval(['Anemia.',layer,'.MVO2']),'linewidth',1.5);
% plot(Dob.Ptm,eval(['Dob.',layer,'.MVO2']),'linewidth',1.5);
% legend('Control','Anemia','Dob+Anemia','Location','best');
% xlabel('p_{tm} (mmHg)');
% ylabel('MVO2 ()');
% set(gca,'FontSize',12);
% 
% saveas(h5,['MVO2',layer,num2str(i),'.png']);
% 
% h6 = figure; hold on;
% plot(Control.Ptm,eval(['Control.',layer,'.Tv']),'linewidth',1.5);
% plot(Anemia.Ptm,eval(['Anemia.',layer,'.Tv']),'linewidth',1.5);
% plot(Dob.Ptm,eval(['Dob.',layer,'.Tv']),'linewidth',1.5);
% legend('Control','Anemia','Dob+Anemia','Location','best');
% xlabel('p_{tm} (mmHg)');
% ylabel('[ATP] ()');
% set(gca,'FontSize',12);
% 
% saveas(h6,['ATP',layer,num2str(i),'.png']);
%% Move files to Figs folder
movefile('*.png',['./Figs',MetSignal,'/']);


