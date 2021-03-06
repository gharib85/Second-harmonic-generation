function result = diff_fitting(param, xdata)

% dane = importdata('dane.txt');
% x = lsqcurvefit(@diff_fitting, [2.2, 0.05, 0, 10], dane(:, 1), dane(:, 2), [0,0,0,0])
% x = [2.4259, 0.0951, -0.0407, 13.0523] % without lower bonds
%  [2.4344,    0.0938,   0.0000, 12.8816] % with lower bonds
L = 1; % dlugosc wlokna
a_scale = 5.; % min
higher = 2.;

dtau = (xdata(2) - xdata(1))/a_scale/higher;
N = 2^10;
M = length(xdata) * higher;
s = linspace(0, L, N);
dS = s(2) - s(1);
% tau = xdata/a_scale;
% tau = linspace(0, max(xdata)/a_scale, M);
% dtau = tau(2) - tau(1);
% M = length(xdata);

nw = 1.456047;
n2w = 1.473859;

aAw = 1.859386E-09; % [db/m]
aA2w = 0.000125;

aUVw = ((154.2*0.12)/(46.6*0.12+60)*1e-2*exp(4.63/1.064^(-4)))*1e-3;
aUV2w = ((154.2*0.12)/(46.6*0.12+60)*1e-2*exp(4.63/0.532^(-4)))*1e-3;
aIRw = (7.81e11*exp(-48.48/1.064))*1e-3;
aIR2w = (7.81e11*exp(-48.48/0.532))*1e-3;

k0 = 1; % 0.01 cm^-1 = 1 m^-1
aw = (aAw + aIRw + aUVw)/4.343/k0;
a2w = (aA2w + aIR2w + aUV2w)/4.343/k0;
%aw = param(3)/4.343/k0;
%a2w = param(4)/4.343/k0;

E0 = zeros(M, N);
E1 = zeros(M, N);
E2 = zeros(M, N);
Psi0 = zeros(M, N);
Psi1 = zeros(M, N);
Psi2 = zeros(M, N);

% warunki poczatkowe
E0(1,:) = 1e-15;  % E0(S,0)
Psi0(1,:) = 0;  % Psi0(S,0)
E2(:,1) = param(2);  % E2(0,tau)
Psi2(:,1) = 0;  % Psi2(0,tau)
E1(:,1) = param(1);  % E1(0,tau)
Psi1(:,1) = 0;  % Psi1(0,tau)

rhs1 = @(E0,E1,E2,Psi0,Psi1,Psi2)   1./n2w * E0 * E1^2 * sin(Psi0 + 2 * Psi1 - Psi2) - a2w/2*E2;
rhs2 = @(E0,E1,E2,Psi0,Psi1,Psi2) - 1./n2w * E0 * E1^2/E2 * cos(Psi0 + 2 * Psi1 - Psi2);
rhs3 = @(E0,E1,E2,Psi0,Psi1,Psi2) - 1./nw * E0 * E1 * E2 * sin(Psi0 + 2 * Psi1 - Psi2) - aw/2*E1;
rhs4 = @(E0,E2,Psi0,Psi1,Psi2)    - 1./nw * E0 * E2 * cos(Psi0 + 2 * Psi1 - Psi2);
rhs5 = @(E0,E2,Psi0,Psi1,Psi2)    - E2^2 *(E0 - cos(Psi0 + 2 * Psi1 - Psi2));
rhs6 = @(E0,E2,Psi0,Psi1,Psi2)    - E2^2/E0 * sin(Psi0 + 2 * Psi1 - Psi2);

for j = 1:N
    for i = 1:M
        if(j ~= N)
            kE2_1   = dS * rhs1(E0(i,j),E1(i,j),E2(i,j),           Psi0(i,j),Psi1(i,j),Psi2(i,j));
            kPsi2_1 = dS * rhs2(E0(i,j),E1(i,j),E2(i,j),           Psi0(i,j),Psi1(i,j),Psi2(i,j));
            kE1_1   = dS * rhs3(E0(i,j),E1(i,j),E2(i,j),           Psi0(i,j),Psi1(i,j),Psi2(i,j));
            kPsi1_1 = dS * rhs4(E0(i,j),        E2(i,j),           Psi0(i,j),Psi1(i,j),Psi2(i,j));
            
            kE2_2   = dS * rhs1(E0(i,j),E1(i,j) + .5*kE1_1,E2(i,j) + .5*kE2_1,Psi0(i,j),Psi1(i,j) + .5*kPsi1_1,Psi2(i,j) + .5*kPsi2_1);
            kPsi2_2 = dS * rhs2(E0(i,j),E1(i,j) + .5*kE1_1,E2(i,j) + .5*kE2_1,Psi0(i,j),Psi1(i,j) + .5*kPsi1_1,Psi2(i,j) + .5*kPsi2_1);
            kE1_2   = dS * rhs3(E0(i,j),E1(i,j) + .5*kE1_1,E2(i,j) + .5*kE2_1,Psi0(i,j),Psi1(i,j) + .5*kPsi1_1,Psi2(i,j) + .5*kPsi2_1);
            kPsi1_2 = dS * rhs4(E0(i,j),                   E2(i,j) + .5*kE2_1,Psi0(i,j),Psi1(i,j) + .5*kPsi1_1,Psi2(i,j) + .5*kPsi2_1);
            
            kE2_3   = dS * rhs1(E0(i,j),E1(i,j) + .5*kE1_2,E2(i,j) + .5*kE2_2,Psi0(i,j),Psi1(i,j) + .5*kPsi1_2,Psi2(i,j) + .5*kPsi2_2);
            kPsi2_3 = dS * rhs2(E0(i,j),E1(i,j) + .5*kE1_2,E2(i,j) + .5*kE2_2,Psi0(i,j),Psi1(i,j) + .5*kPsi1_2,Psi2(i,j) + .5*kPsi2_2);
            kE1_3   = dS * rhs3(E0(i,j),E1(i,j) + .5*kE1_2,E2(i,j) + .5*kE2_2,Psi0(i,j),Psi1(i,j) + .5*kPsi1_2,Psi2(i,j) + .5*kPsi2_2);
            kPsi1_3 = dS * rhs4(E0(i,j),                   E2(i,j) + .5*kE2_2,Psi0(i,j),Psi1(i,j) + .5*kPsi1_2,Psi2(i,j) + .5*kPsi2_2);           
            
            kE2_4   = dS * rhs1(E0(i,j),E1(i,j) + kE1_3,E2(i,j) + kE2_3,Psi0(i,j),Psi1(i,j) + kPsi1_3,Psi2(i,j) + kPsi2_3);
            kPsi2_4 = dS * rhs2(E0(i,j),E1(i,j) + kE1_3,E2(i,j) + kE2_3,Psi0(i,j),Psi1(i,j) + kPsi1_3,Psi2(i,j) + kPsi2_3);
            kE1_4   = dS * rhs3(E0(i,j),E1(i,j) + kE1_3,E2(i,j) + kE2_3,Psi0(i,j),Psi1(i,j) + kPsi1_3,Psi2(i,j) + kPsi2_3);
            kPsi1_4 = dS * rhs4(E0(i,j),                E2(i,j) + kE2_3,Psi0(i,j),Psi1(i,j) + kPsi1_3,Psi2(i,j) + kPsi2_3);
            
            E2(i,j+1)   = E2(i,j)   + (kE2_1   + 2*kE2_2   + 2*kE2_3   + kE2_4   ) / 6;
            Psi2(i,j+1) = Psi2(i,j) + (kPsi2_1 + 2*kPsi2_2 + 2*kPsi2_3 + kPsi2_4 ) / 6;
            E1(i,j+1)   = E1(i,j)   + (kE1_1   + 2*kE1_2   + 2*kE1_3   + kE1_4   ) / 6;
            Psi1(i,j+1) = Psi1(i,j) + (kPsi1_1 + 2*kPsi1_2 + 2*kPsi1_3 + kPsi1_4 ) / 6;
            
        end
        if(i ~= M)
            kE0_1   = dtau * rhs5(E0(i,j),           E2(i,j),Psi0(i,j),             Psi1(i,j),Psi2(i,j));
            kPsi0_1 = dtau * rhs6(E0(i,j),           E2(i,j),Psi0(i,j),             Psi1(i,j),Psi2(i,j));
            kE0_2   = dtau * rhs5(E0(i,j) + .5*kE0_1,E2(i,j),Psi0(i,j) + .5*kPsi0_1,Psi1(i,j),Psi2(i,j));
            kPsi0_2 = dtau * rhs6(E0(i,j) + .5*kE0_1,E2(i,j),Psi0(i,j) + .5*kPsi0_1,Psi1(i,j),Psi2(i,j));
            kE0_3   = dtau * rhs5(E0(i,j) + .5*kE0_2,E2(i,j),Psi0(i,j) + .5*kPsi0_2,Psi1(i,j),Psi2(i,j));
            kPsi0_3 = dtau * rhs6(E0(i,j) + .5*kE0_2,E2(i,j),Psi0(i,j) + .5*kPsi0_2,Psi1(i,j),Psi2(i,j));
            kE0_4   = dtau * rhs5(E0(i,j) + kPsi0_3, E2(i,j),Psi0(i,j) + kPsi0_3,   Psi1(i,j),Psi2(i,j));
            kPsi0_4 = dtau * rhs6(E0(i,j) + kE0_3,   E2(i,j),Psi0(i,j) + kPsi0_3,   Psi1(i,j),Psi2(i,j));
            E0(i+1,j)   = E0(i,j)   + (kE0_1   + 2*kE0_2   + 2*kE0_3   + kE0_4   ) / 6;
            Psi0(i+1,j) = Psi0(i,j) + (kPsi0_1 + 2*kPsi0_2 + 2*kPsi0_3 + kPsi0_4 ) / 6;
        end
    end
end

result = E2(:, N).^2./E1(:, 1).^2 * 100;
result = result(higher:higher:length(result));

end