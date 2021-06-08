function f = dXdT_myocardium(t,X,measurements,P)

% INPUT

P_in = interp1(measurements.t,measurements.AoP,t);
P_LV = interp1(measurements.t,measurements.PLV,t);
dPdT = interp1(measurements.t,measurements.dPLVdt,t);

P_im1 = 1.2*0.167*P_LV;
P_im2 = 1.2*0.500*P_LV;
P_im3 = 1.2*0.833*P_LV;
dPim1_dt = 1.2*0.167*dPdT;
dPim2_dt = 1.2*0.500*dPdT;
dPim3_dt = 1.2*0.833*dPdT;
P_RA = 0; % right atrial pressure (mmHg)

% STATE VARIABLES
P_PA = X(1); % penetrating artery pressure
Q_PA = X(2); % inlet flow penetrating artery
P11  = X(3); 
P21  = X(4);
P12  = X(5); 
P22  = X(6);
P13  = X(7); 
P23  = X(8);
P_PV = X(9); % penetrating vein pressure

% CALCULATIONS 
V11 = max(P.cf1*((P11 - P_im1)*P.C11+P.V01), P.Vc);

V21 = P.cf1*((P21 - P_im1)*P.C2+P.V02);
R11 = P.rf1*P.R01*(P.V01/V11).^2;
R21 = P.rf1*P.R02*(P.V02/V21).^2;
Rm1 = P.R0m*(P.gamma*R11/P.R01 + (1-P.gamma)*R21/P.R02);
Q11 = (P_PA - P11)/R11;
Qm1 = (P11 - P21)/Rm1;
% Q21 = (P21 - P_PV)/R21;

V12 = max(P.cf2*((P12 - P_im2)*P.C12+P.V01), P.Vc);
V22 = P.cf2*((P22 - P_im2)*P.C2+P.V02);
R12 = P.rf2*P.R01*(P.V01/V12).^2;
R22 = P.rf2*P.R02*(P.V02/V22).^2;
Rm2 = P.R0m*(P.gamma*R12/P.R01 + (1-P.gamma)*R22/P.R02);
Q12 = (P_PA - P12)/R12;
Qm2 = (P12 - P22)/Rm2;
% Q22 = (P22 - P_PV)/R22;

V13 = max((P13 - P_im3)*P.C13+P.V01, P.Vc);
V23 = (P23 - P_im3)*P.C2+P.V02;
R13 = P.R01*(P.V01/V13).^2;
R23 = P.R02*(P.V02/V23).^2;
Rm3 = P.R0m*(P.gamma*R13/P.R01 + (1-P.gamma)*R23/P.R02);
Q13 = (P_PA - P13)/R13;
Qm3 = (P13 - P23)/Rm3;
% Q23 = (P23 - P_PV)/R23;

A1 = [(R21+P.R_PV/2), (P.R_PV/2), (P.R_PV/2)];
A2 = [(P.R_PV/2), (R22+P.R_PV/2), (P.R_PV/2)];
A3 = [(P.R_PV/2), (P.R_PV/2), (R23+P.R_PV/2)];

A = [A1;A2;A3];
B = [P21-P_PV; P22-P_PV; P23-P_PV];

X = A\B;

Q21 = double(X(1));
Q22 = double(X(2));
Q23 = double(X(3));

Q21 = max(Q21,0);
Q22 = max(Q22,0);
Q23 = max(Q23,0);


Q_ima = Q11 + Q12 + Q13;
Q_imv = Q21 + Q22 + Q23;


Q_out = (P_PV - P_RA)/(P.R_PV/2);

f(1,:) = (Q_PA - Q_ima)/P.C_PA; % P_PA
f(2,:) = (P_in - P_PA - Q_PA*P.R_PA)/P.L_PA; % Q_PA
f(3,:) = (Q11-Qm1)/(P.cf1*P.C11) + dPim1_dt; % P11
f(4,:) = (Qm1-Q21)/(P.cf1*P.C2) + dPim1_dt; % P21
f(5,:) = (Q12-Qm2)/(P.cf2*P.C12) + dPim2_dt; % P12
f(6,:) = (Qm2-Q22)/(P.cf2*P.C2) + dPim2_dt; % P22
f(7,:) = (Q13-Qm3)/(P.C13) + dPim3_dt; % P13
f(8,:) = (Qm3-Q23)/(P.C2) + dPim3_dt; % P23
f(9,:) = (Q_imv - Q_out)/P.C_PV; % P_PV
