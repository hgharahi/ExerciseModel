%% Data from Kiel et al. read and assiged in MATLAB

SpecimenPairs = [2,2;
    3,1;
    4,3;
    5,4]; % First column Control, Second column Anemia and Anemia+Dobutamine case number.

names = {'Control','Anemia','Anemia+Dobutamine'};
SpecimenIDs = {'#10013','#10011','#10015','#10276'};

CPP = [40 ,60, 80, 100, 120, 140];

BloodGasMeasurementsControl = [
15.2	9.5     171     31      100     61      11.55	33.5
15.2	5.4     171     20      100     35.6	10.7	35
15.8	3.7     174     17      100     24      11.3	35.5
15.8	2.7     174     13      100     17.3	11.3	36
15.1	2.3     179     12      100     14.2	11.45	35
15.1	2.2     180     10      100     14.7	10.6	35
];


BloodGasMeasurementsAnemia = [
9.8     4.2     185     25      100     49.3	6.75	22.5;
9.8     4.5     185     25      100     44.3	7.5     19;
9.7     3.9     174     21      100     40      7.15	19;
9.7     3.3     174     19      100     32      7.3     23;
9.3     2.8     192     17      100     27.3	6.9     23;
8.8     2.2     181     15      100     20.3	6.75	21.5;
];


BloodGasMeasurementsDob = [
13.1	9.3     167     37      100     72.2	9.4     29
13.4	9       163     35      100     68.1	9.55	31
13.4	6.4     163     26      100     48.2	9.7     30
13      4.9     167     23      100     38.1	9.6     29
13.1	2.8     163     17      100     20.5	9.7     29
];


Control.LVweight = 80.34;
Anemia.LVweight = 80.34;
Dob.LVweight    = 80.34;

% Viscosity function from Snyder 1971 - Influence of temperature and hematocriton blood viscosity 
k0 = 0.0322;
k3 = 1.08*1e-4;
k2 = 0.02;
T = 37 ;
Viscosity = @(x) 2.03 * exp( (k0 - k3*T)*x - k2*T );
% VisCorrection = @(x) 14.5583*x.^3 + 3.0897*x.^2 + 3.4796*x + 1.0000; % Curve fitted to curve in Fig. 7 of Pries et al paper.

for j = 1:length(CPP)-1
    
    Control.ArtO2Cnt(j) =   BloodGasMeasurementsControl(6-j+1,1);
    Control.CVO2Cnt(j)  =   BloodGasMeasurementsControl(6-j+1,2);
    Control.ArtPO2(j)   =   BloodGasMeasurementsControl(6-j+1,3);
    Control.CvPO2(j)    =   BloodGasMeasurementsControl(6-j+1,4);
    Control.ArtO2Sat(j) =   BloodGasMeasurementsControl(6-j+1,5);
    Control.CvO2Sat(j)  =   BloodGasMeasurementsControl(6-j+1,6);
    Control.Hgb(j)      =   BloodGasMeasurementsControl(6-j+1,7);
    Control.HCT(j)      =   BloodGasMeasurementsControl(6-j+1,8);
    
    Anemia.ArtO2Cnt(j) =   BloodGasMeasurementsAnemia(6-j+1,1);
    Anemia.CVO2Cnt(j)  =   BloodGasMeasurementsAnemia(6-j+1,2);
    Anemia.ArtPO2(j)   =   BloodGasMeasurementsAnemia(6-j+1,3);
    Anemia.CvPO2(j)    =   BloodGasMeasurementsAnemia(6-j+1,4);
    Anemia.ArtO2Sat(j) =   BloodGasMeasurementsAnemia(6-j+1,5);
    Anemia.CvO2Sat(j)  =   BloodGasMeasurementsAnemia(6-j+1,6);
    Anemia.Hgb(j)      =   BloodGasMeasurementsAnemia(6-j+1,7);
    Anemia.HCT(j)      =   BloodGasMeasurementsAnemia(6-j+1,8);
    
    
    Dob.ArtO2Cnt(j) =   BloodGasMeasurementsDob(5-j+1,1);
    Dob.CVO2Cnt(j)  =   BloodGasMeasurementsDob(5-j+1,2);
    Dob.ArtPO2(j)   =   BloodGasMeasurementsDob(5-j+1,3);
    Dob.CvPO2(j)    =   BloodGasMeasurementsDob(5-j+1,4);
    Dob.ArtO2Sat(j) =   BloodGasMeasurementsDob(5-j+1,5);
    Dob.CvO2Sat(j)  =   BloodGasMeasurementsDob(5-j+1,6);
    Dob.Hgb(j)      =   BloodGasMeasurementsDob(5-j+1,7);
    Dob.HCT(j)      =   BloodGasMeasurementsDob(5-j+1,8);   
    
end


Control.VisRatio = Viscosity(Control.HCT);

Anemia.VisRatio = Viscosity(Anemia.HCT) / (Control.VisRatio(4));

Dob.VisRatio = Viscosity(Dob.HCT) / (Control.VisRatio(4));

Control.VisRatio = Control.VisRatio./(Control.VisRatio(4));


