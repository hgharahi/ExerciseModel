function test = ATPconcentration(test, So, MetabolicDrive)


CPP = [40 ,60, 80, 100, 120, 140];

[Q_endo, Q_mid, Q_epi] = CycleAvg(test,'Q1');

% [V_endo, V_mid, V_epi] = CycleAvg(test,'V1');
Q_total = Q_endo + Q_mid + Q_epi;

for j = 1:length(CPP)
    
    R_MVO2 = 1.5; % Endo to Epi MVO2 ratio
    Vc = 0.04;
    J0 = 283.388e3;
    Ta = 28.151;
    C0 = 476;
    nH = 2.7;
    P50 = 26;
    
    q_endo = Q_endo(j)*60 / (test.LVweight); % the last 1/3 is roughly for subendo layer
    q_mid = Q_mid(j)*60 / (test.LVweight); % the last 1/3 is roughly for mid layer
    q_epi = Q_epi(j)*60 / (test.LVweight); % the last 1/3 is roughly for subepi layer
    
    Ht = test.HCT(j)/100;


    PaO2 = test.ArtPO2(j);
    PvO2 = test.CvPO2(j);
    
    Sa = test.ArtO2Sat(j)/100;
    Sv = test.CvO2Sat(j)/100;
    
    Mtotal(j) = Q_total(j)*60/test.LVweight * (test.ArtO2Cnt(j) - test.CVO2Cnt(j))*10;
%         Mtotal(j) = Q_total(j) *  (Sa - Sv); 
        
    % divide the Mtotal to layers
    Mendo = R_MVO2/(3/2*(R_MVO2+1));
    Mmid  = ((R_MVO2+1)/2)/(3/2*(R_MVO2+1));
    Mepi  = 1/(3/2*(R_MVO2+1));
    
    test.endo.MVO2(j) = Mtotal(j)*Mendo;
    test.mid.MVO2(j) = Mtotal(j)*Mmid;
    test.epi.MVO2(j) = Mtotal(j)*Mepi;

    test.endo.Tv(j) = Vc*Ht*J0*So/(q_endo*(Sa-Sv)) * exp(-Sa/So) * ( exp( (Sa-Sv)/So ) - 1) + Ta;
    test.mid.Tv(j)  = Vc*Ht*J0*So/(q_mid*(Sa-Sv)) * exp(-Sa/So) * ( exp( (Sa-Sv)/So ) - 1) + Ta;
    test.epi.Tv(j)  = Vc*Ht*J0*So/(q_epi*(Sa-Sv)) * exp(-Sa/So) * ( exp( (Sa-Sv)/So ) - 1) + Ta;
    
    test.endo.dS(j) = Sv;
    test.mid.dS(j)  = Sv;
    test.epi.dS(j)  = Sv;

    test.endo.Sv(j) = Sa - test.endo.MVO2(j)/(C0*Ht*q_endo);
    test.mid.Sv(j)  = Sa - test.mid.MVO2(j)/(C0*Ht*q_mid);
    test.epi.Sv(j)  = Sa - test.epi.MVO2(j)/(C0*Ht*q_epi);    
    
    switch MetabolicDrive
        case 'QM'
            
            test.endo.MetSignal(j) = test.endo.MVO2(j)*q_endo;
            test.mid.MetSignal(j) = test.mid.MVO2(j)*q_mid;
            test.epi.MetSignal(j) = test.epi.MVO2(j)*q_epi;
            
        case 'ATP'
            
            test.endo.MetSignal(j) = test.endo.Tv(j);
            test.mid.MetSignal(j)  = test.mid.Tv(j);
            test.epi.MetSignal(j)  = test.epi.Tv(j);
            
        case 'VariableSV'
            
            test.endo.MetSignal(j) = max(test.endo.Sv(j),0);
            test.mid.MetSignal(j)  = max(test.mid.Sv(j),0);
            test.epi.MetSignal(j)  = max(test.epi.Sv(j),0);
            
        case 'Generic'
            
            test.endo.MetSignal(j) = test.endo.dS(j);
            test.mid.MetSignal(j)  = test.mid.dS(j);
            test.epi.MetSignal(j)  = test.epi.dS(j);
            
        case 'MVO2'
            
            test.endo.MetSignal(j) = test.endo.MVO2(j);
            test.mid.MetSignal(j) = test.mid.MVO2(j);
            test.epi.MetSignal(j) = test.epi.MVO2(j);
            
        case 'QdS'
            
            test.endo.MetSignal(j) = q_endo*(Sa-Sv);
            test.mid.MetSignal(j) = q_mid*(Sa-Sv);
            test.epi.MetSignal(j) = q_epi*(Sa-Sv);
            
         case 'Q'
            
            test.endo.MetSignal(j) = q_endo;
            test.mid.MetSignal(j) = q_mid;
            test.epi.MetSignal(j) = q_epi; 
            
        case 'M2'
            
            test.endo.MetSignal(j) = test.endo.MVO2(j)^2;
            test.mid.MetSignal(j) = test.mid.MVO2(j)^2;
            test.epi.MetSignal(j) = test.epi.MVO2(j)^2;
            
    end
end
% figure(1);plot(CPP,Mtotal,'LineWidth',2);hold on;ylabel('MVO2 (\muL O2/min/g)');xlabel('CPP (mmHg)');
% figure(2);plot(CPP,test.CvO2Sat/100,'LineWidth',2);hold on;ylabel('Sv (%)');xlabel('CPP (mmHg)');
% figure(3);plot(CPP,Mp,'LineWidth',2);hold on;ylabel('Fx(Sa-Sv)');xlabel('CPP (mmHg)');
% figure(4);plot(CPP,Q_total(1:5).*Mtotal,'LineWidth',2);hold on;ylabel('Q*MVO2');xlabel('CPP (mmHg)');
return
