%% TUTORAGGIO NUMERO 3
clear
close all

%%
% Problema 2

A = [7, 1, 3; 1, 8, 2; 3, 2, 9];
x_e = ones(3,1);
b = A*x_e;

A1 = lu2(A);
L1 = tril(A1,-1) + eye(size(A1,1));
U1 = triu(A1);
[L2, U2, P] = lu(A);

y_1=forward(L1,b);                 
x_1=backward(U1,y_1);

err_lu = norm(x_1-x_e)/norm(x_e);
H1 = chol2(A);
H2 = chol(A);

y_2=forward(H1',b);                 
x_2=backward(H1,y_2);
err_chol = norm(x_2-x_e)/norm(x_e);

eps = 1;
B = [1, 1-eps, 3; 2, 2, 2; 3, 6, 4];
d = [5-eps; 6; 13];
B1 = lu2(B);
L3 = tril(B1,-1) + eye(size(B1,1));
U3 = triu(B1);

[L4, U4, P4] = lu(B);

%%
% Problema 3

f = @(x) 1./(1 + 25*x.^2);

x_1 = linspace(-1,1,500);
y_1 = f(x_1);
subplot(1,2,1)
plot(x_1,y_1,'r','linewidth',2);
hold on;
a = -1;
b = 1;

for n = 2:2:20

    x = linspace(a,b,n+1);
    y = f(x);
    p = polyfit(x,y,n);
    y_int = polyval(p,x_1);
    
    err = y_1 - y_int;
    subplot(1,2,1)
    hold on
    plot(x_1,y_int,'--','color',rand(1,3));
    plot(x,f(x),'k.','markersize',30);
    %axis([-1 1 0 1]);
    subplot(1,2,2)
    hold on
    plot(x_1,err,'--','color',rand(1,3))
    grid;
    %pause
end

figure
subplot(1,2,1)
hold on
plot(x_1,y_1,'r','linewidth',2);

for n = 2:2:20
    
    for i=0:n
        x_i = cos(pi*i/n); %Chebyshev-Gauss-Lobatto
        % x_i = cos(pi*(2*i+1)/(2*(n+1))); %Chebyshev-Gauss
        x_c(i+1)=((a+b)/2)-((b-a)/2)*x_i;
    end

    y = f(x_c);
    p = polyfit(x_c,y,n);
    y_che = polyval(p,x_1);
    
    err_che = y_1 - y_che;
    subplot(1,2,1)
    hold on
    plot(x_1,y_che,'--','color',rand(1,3));
    plot(x_c,f(x_c),'k.','markersize',30);
    %axis([-1 1 0 1]);
    subplot(1,2,2)
    hold on
    plot(x_1, err_che,'--','color',rand(1,3))
    grid;
    pause
end

%%
% Problema 5

gamma = [1,2,3];
x = linspace(-3,3);

for g = gamma
    f = @(x) cosh(x)+cos(x)-g;
    plot(x, f(x), 'color', rand(1,3))
    hold on
    grid
end

a = -3; 
b = -1; 
tol = 1.e-10; 
nmax = 200; 
[zero_1,res_1,niter_1] = bisezione(f,a,b,tol,nmax);
a = 1; 
b = 3; 
[zero_2,res_2,niter_2] = bisezione(f,a,b,tol,nmax);

%%
% Problema 1

function [A]=chol2(A)
% CHOL2 fattorizzazione di Cholesky di una matrice A di tipo s.d.p.. 
% A=CHOL2(A) il triangolo superiore H di A è tale che H'*H=A. 
[n,m]=size(A);
if n ~= m
    error('Solo sistemi quadrati');
end
A(1,1)=sqrt(A(1,1));
for j=2:n
    for i=1:j-1
        if A(j,j) <= 0
            error('Elemento pivotale nullo o negativo');
        end
        A(i,j)=(A(i,j)-(A(1:i-1,i))'*A(1:i-1,j))/A(i,i);
    end
    A(j,j)=sqrt(A(j,j)-(A(1:j-1,j))'*A(1:j-1,j));
end
A = triu(A);
end

%%
% Problema 4 

function [zero,res,niter]=bisezione(fun,a,b,tol,kmax)
% Questa funzione implementa il metodo di bisezione per la funzione fun
% nell'intervallo [a,b], con tolleranza tol e numero massimo di iterazioni
% kmax. 
x = [a, (a+b)*0.5, b];
fx = fun(x);

if fx(1)*fx(3) > 0
    error('Il segno della funzione agli estremi dell''intervallo [A,B] deve essere diverso');
elseif fx(1) == 0 
    zero = a; res = 0; niter = 0;
    return
elseif fx(3) == 0 
    zero = b; res= 0; niter = 0;
    return
end

niter = 0;
I = (b - a)*0.5;
while I >= tol && niter < kmax 
    niter = niter + 1;
    if fx(1)*fx(2) < 0 
        x(3) = x(2);
        x(2) = x(1)+(x(3)-x(1))*0.5; 
        fx = fun(x);
        I = (x(3)-x(1))*0.5;
    elseif fx(2)*fx(3) < 0
        x(1) = x(2);
        x(2) = x(1)+(x(3)-x(1))*0.5; 
        fx = fun(x);
        I = (x(3)-x(1))*0.5;
    else
        x(2) = x(find(fx==0)); 
        I = 0;
    end
end

if niter==kmax && I > tol
fprintf('Il metodo di bisezione si e'' arrestato senza soddisfare la tolleranza richiesta avendo raggiunto il numero massimo di iterazioni\n');
end
zero = x(2);
x = x(2);
res = fun(x);
end