%% TUTORAGGIO NUMERO 1
clear
close all

% Problema 1

r = 1i^1i;

% Problema 2

x = 1.e-15;
y = ((1 + x) -1)/x;

% Problema 3

n_max = 100;
n = 0 ; 
my_eps = 0.5; 
eps_1 = my_eps+1;
while (eps_1 > 1 && n < n_max)
	n = n+1;
	my_eps = 0.5*my_eps;
	eps_1 = my_eps+1;
end


% Problema 4

a = 10;
b = 2;
n = 1 + floor(log(a)/log(b));
q = a;
a_vec = zeros(1,n);

for i = n:-1:1
% a_vec(n-i+1) = mod(q, b);
a_vec(n-i+1) = q - b.*floor(q/b);
q = floor(q/b);
end

% Problema 5

z_n = 2;
n_it = 30;
err_rel = zeros(1, n_it);
n_vec = 2:n_it+1;

for n = 2:n_it
    z_np = 2^(n-1/2)*sqrt(1 - sqrt(1 - 4^(1-n)*z_n^2));
    z_n = z_np;
    err_rel(n) = abs(pi - z_n)/pi;
end

semilogy(n_vec, err_rel)
title('Errore relativo')
xlabel('n')
ylabel('err')

% Problema 6

n_it_1 = 1000;
pi_vec = zeros(1, n_it_1);
err_rel_1 = zeros(1, n_it_1);
n_vec = 2:n_it_1+1;

for n = 2:n_it_1
    pi_vec(n) = pi_montecarlo(n); 
    err_rel_1(n) = abs(pi - pi_vec(n))/pi;
end

figure()
semilogy(n_vec, err_rel_1)
title('Errore relativo')
xlabel('n')
ylabel('err')


% Problema 7

L=2*eye(10)-3*diag(ones(8,1),-2);
U=2*eye(10)-3*diag(ones(8,1),2);
r=1:10; 
r(3)=7;  
r(7)=3; 
Lr=L(r,:);
c=1:10;
c(8)=4;
c(4)=8;
Lc=L(:,c);

function my_pi = pi_montecarlo(n)
	x = rand(n,1);
	y = rand(n,1);
	z = x.^2+y.^2;
	v = (z <= 1);
	m=sum(v);
	my_pi=4*m/n; 
end


