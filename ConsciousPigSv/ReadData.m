%% Reads data from files

load AllResults.mat
load DoBResults.mat
load HDResults.mat
%% Reading data / modeling / analysis based on Pzf data from John Tune:

SpecimenPairs = [2,2;
    3,1;
    4,3;
    5,4]; % First column Control, Second column Anemia and Anemia+Dobutamine case number.


Control = (Control);
Dob = (Dob);
Anemia = (HD);

i = 4;

%% Parameter initialization and estimation
names = {'Control','Anemia','Anemia+Dobutamine'};
SpecimenIDs = {'#10013','#10011','#10015','#10276'};
CPP = [40 ,60, 80, 100, 120, 140];

Control = Control{SpecimenPairs(i,1)};
Anemia = Anemia{SpecimenPairs(i,2)};
Dob = Dob{SpecimenPairs(i,2)};

BloodGasMeasurementReading;

Control =   Calculations(Control);

Anemia  =   Calculations(Anemia);

Dob  =   Calculations(Dob);

[Control, Anemia, Dob] = RepVessel(Control, Anemia, Dob);


%% Read RepVessel Model Parameters
% xendo = mean(subendo.x,2);
% xmid = mean(mid.x,2);
% xepi = mean(subepi.x,2);
xendo = subendo.x(:,i);
xmid = mid.x(:,i);
xepi = subepi.x(:,i);

%% Read aortic and left venctricular pressure from the
data_rest = xlsread('TuneExercisePig','2713 Resting','B9:D5005');
data_exercise = xlsread('TuneExercisePig','2713 Exercise Level 2','B9:D5005');

[tdata_R,AoP_R,PLV_R,Flow_R] = ReadExerciseInput(data_rest);
[tdata_E,AoP_E,PLV_E,Flow_E] = ReadExerciseInput(data_exercise);
%%
Data_Ready = 1;
