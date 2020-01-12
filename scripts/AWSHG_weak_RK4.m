%Generacja drugiej harmonicznej w �wiat�owodach krzemionkowych domieszkowanych germanem
%dla modelu z t�umion� wydajn� generacj� drugiej harmonicznej
% Autor: Sylwia Majchrowska
% 15 maja 2017r.

clear all;
clc;
format long e

M = 2^10;
N = 2^10;
L = 5;
time = 100;

s = linspace(0, L, N);
tau = linspace(0, time, M);
dS = s(2) - s(1);
dtau = tau(2) - tau(1);

E0 = zeros(M, N);
E2 = zeros(M, N);
Psi0 = zeros(M, N);
Psi2 = zeros(M, N);

aA2w = 0.000125;
aIR2w = (3.947e10*exp(-42.73/0.532))*1e-3;
aUV2w = (201.3*0.532^-4)*1e-3;

k0 = 1; % 0.01cm^-1 = 1 m^-1
a2w = (aA2w + aIR2w + aUV2w)/4.343/k0;

% warunki poczatkowe
E0(1,:) = 1e-15;  % E0(S,0)
Psi0(1,:) = 0;  % Psi0(S,0)
E2(:,1) = 0.05;  % E2(0,tau)
Psi2(:,1) = 0;  % Psi2(0,tau)
%Psi2(tau>25,1) = pi;  % zmiana fazy dla tau = 25

rhs1 = @(E0,E2,Psi0,Psi2)    E0 * sin(Psi0 - Psi2) - a2w/2*E2;
rhs2 = @(E0,E2,Psi0,Psi2) -E0/E2 * cos(Psi0 - Psi2);
rhs3 = @(E0,E2,Psi0,Psi2) -E2^2 *(E0 - cos(Psi0 - Psi2));
rhs4 = @(E0,E2,Psi0,Psi2) -E2^2/E0 * sin(Psi0 - Psi2);

fprintf(1, '\nStart...       ');
tic
j = 1;
i = 1;
for j = 1:N
    for i = 1:M
        if(j ~= N)
            kE2_1   = dS * rhs1(E0(i,j),E2(i,j),           Psi0(i,j),Psi2(i,j));
            kPsi2_1 = dS * rhs2(E0(i,j),E2(i,j),           Psi0(i,j),Psi2(i,j));
            kE2_2   = dS * rhs1(E0(i,j),E2(i,j) + .5*kE2_1,Psi0(i,j),Psi2(i,j) + .5*kPsi2_1);
            kPsi2_2 = dS * rhs2(E0(i,j),E2(i,j) + .5*kE2_1,Psi0(i,j),Psi2(i,j) + .5*kPsi2_1);
            kE2_3   = dS * rhs1(E0(i,j),E2(i,j) + .5*kE2_2,Psi0(i,j),Psi2(i,j) + .5*kPsi2_2);
            kPsi2_3 = dS * rhs2(E0(i,j),E2(i,j) + .5*kE2_2,Psi0(i,j),Psi2(i,j) + .5*kPsi2_2);
            kE2_4   = dS * rhs1(E0(i,j),E2(i,j) + kE2_3,    Psi0(i,j),Psi2(i,j) + kPsi2_3);
            kPsi2_4 = dS * rhs2(E0(i,j),E2(i,j) + kE2_3,   Psi0(i,j),Psi2(i,j) + kPsi2_3);
            E2(i,j+1)   = E2(i,j)   + (kE2_1   + 2*kE2_2   + 2*kE2_3   + kE2_4   ) / 6;
            Psi2(i,j+1) = Psi2(i,j) + (kPsi2_1 + 2*kPsi2_2 + 2*kPsi2_3 + kPsi2_4 ) / 6;
        end
        if(i ~= M)
            kE0_1   = dtau * rhs3(E0(i,j),           E2(i,j),Psi0(i,j),             Psi2(i,j));
            kPsi0_1 = dtau * rhs4(E0(i,j),           E2(i,j),Psi0(i,j),             Psi2(i,j));
            kE0_2   = dtau * rhs3(E0(i,j) + .5*kE0_1,E2(i,j),Psi0(i,j) + .5*kPsi0_1,Psi2(i,j));
            kPsi0_2 = dtau * rhs4(E0(i,j) + .5*kE0_1,E2(i,j),Psi0(i,j) + .5*kPsi0_1,Psi2(i,j));
            kE0_3   = dtau * rhs3(E0(i,j) + .5*kE0_2,E2(i,j),Psi0(i,j) + .5*kPsi0_2,Psi2(i,j));
            kPsi0_3 = dtau * rhs4(E0(i,j) + .5*kE0_2,E2(i,j),Psi0(i,j) + .5*kPsi0_2,Psi2(i,j));
            kE0_4   = dtau * rhs3(E0(i,j) + kPsi0_3, E2(i,j),Psi0(i,j) + kPsi0_3,   Psi2(i,j));
            kPsi0_4 = dtau * rhs4(E0(i,j) + kE0_3,   E2(i,j),Psi0(i,j) + kPsi0_3,   Psi2(i,j));
            E0(i+1,j)   = E0(i,j)   + (kE0_1   +  2*kE0_2   + 2*kE0_3   + kE0_4   ) / 6;
            Psi0(i+1,j) = Psi0(i,j) + (kPsi0_1 + 2*kPsi0_2 + 2*kPsi0_3 + kPsi0_4 ) / 6;
        end
        fprintf(1, '\b\b\b\b\b\b\b%06.2f%%', (i + M*(j-1)) * 100.0 /M/N );
    end
end

tx = toc;

fprintf(1, '\n\nCzas trwania symulacji (s) = ');
fprintf(1, '%5.2f%', tx );
fprintf(1, '\n\n');

%--------------------------------------------------------------------------
%Wykresy
%--------------------------------------------------------------------------

figure(1)
set(gca, 'fontsize', 18)
plot(s, E0(M,:), 'g', s, E2(M,:), 'r', 'LineWidth',2)  % dla tau = 100
grid on
legend('E_0', 'E_2', 'Location', 'southeast')
xlabel('S'); ylabel('E_i');
print('-f1','Straty_E_week_RK','-dpng')

figure(2)
set(gca, 'fontsize', 18)
plot(s, Psi0(M,:), 'g', s, Psi2(M,:), 'r', 'LineWidth',2)
grid on
legend('\Psi_0', '\Psi_2', 'Location', 'northeast')
xlabel('S'); ylabel('\Psi_i');
print('-f2','Straty_Psi_week_RK','-dpng')

figure(3)
set(gca, 'fontsize', 16)
set(gcf,'renderer','zbuffer');
mesh(s, tau, E2)
set(gca, 'xlim', [0 L], 'ylim', [0 time])
xlabel('S'); ylabel('\tau'); zlabel('E_2');
print('-f3','Straty_E2_week_mesh_RK', '-dpng')