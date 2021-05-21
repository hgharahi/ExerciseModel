%% Data from Kiel et al. read and assiged in MATLAB

SpecimenPairs = [2,2;
    3,1;
    4,3;
    5,4]; % First column Control, Second column Anemia and Anemia+Dobutamine case number.

names = {'Control','Anemia','Anemia+Dobutamine'};
SpecimenIDs = {'#10013','#10011','#10015','#10276'};

CPP = [40 ,60, 80, 100, 120, 140];

i = 4;

BloodGasMeasurementsControl = [
15.6	6	173     22	100     41.5	10.65	34.5;
15.6	3.6	173     16	100     23.7	10.9	36;
14.2	2.4	180     13	100     18.1	10.1	36;
14.2	1.8	180     11	100     12.1	10.4	36;
15.8	1.4	162     10	100     8.5     11      36;
16.1	1.2	178     9	100     7.2     11.5	38;
];


BloodGasMeasurementsAnemia = [
7       2	181     18	100     25.7	5.1     16;		
7       2	181     20	100     29.4	4.5     15;		
5.7     1.7	187     17	100     31.7	3.55	15.5;    
5.7     1.2	187     17	100     26.3	3.5     15;		
6.3     1	187     14	100     15      3.2     15;		
6.7     0.7	193     12	100     10.3	4.95	15;		
];


BloodGasMeasurementsDob = [
8.6     3.7	163     26	100     44      5.65	17;
8.6     2.7	163     24	100     31.8	6.2     17;
8.2     2.2	176     19	100     23.8	5.8     18;
8.2     2	176     16	100     28.2	5       15;
6.3     2.4	164     13	100     22.4	4.2     15;
5.5     1	189     14	100     15.1	4.1     15;    
];


Control.LVweight = 51.13;
Anemia.LVweight = 51.13;
Dob.LVweight = 51.13;

% Viscosity function from Snyder 1971 - Influence of temperature and hematocriton blood viscosity 
k0 = 0.0322;
k3 = 1.08*1e-4;
k2 = 0.02;
T = 37 ;
Viscosity = @(x) 2.03 * exp( (k0 - k3*T)*x - k2*T );
% VisCorrection = @(x) 14.5583*x.^3 + 3.0897*x.^2 + 3.4796*x + 1.0000; % Curve fitted to curve in Fig. 7 of Pries et al paper.

for j = 1:length(CPP)
    
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
    
    
    Dob.ArtO2Cnt(j) =   BloodGasMeasurementsDob(6-j+1,1);
    Dob.CVO2Cnt(j)  =   BloodGasMeasurementsDob(6-j+1,2);
    Dob.ArtPO2(j)   =   BloodGasMeasurementsDob(6-j+1,3);
    Dob.CvPO2(j)    =   BloodGasMeasurementsDob(6-j+1,4);
    Dob.ArtO2Sat(j) =   BloodGasMeasurementsDob(6-j+1,5);
    Dob.CvO2Sat(j)  =   BloodGasMeasurementsDob(6-j+1,6);
    Dob.Hgb(j)      =   BloodGasMeasurementsDob(6-j+1,7);
    Dob.HCT(j)      =   BloodGasMeasurementsDob(6-j+1,8);   
    
end


Control.VisRatio = Viscosity(Control.HCT);

Anemia.VisRatio = Viscosity(Anemia.HCT) / mean(Control.VisRatio);

Dob.VisRatio = Viscosity(Dob.HCT) / mean(Control.VisRatio);

Control.VisRatio = Control.VisRatio./mean(Control.VisRatio);



