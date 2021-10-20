%% TUTORAGGIO NUMERO 5
clear
close all

%%
% Problema 1

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
k_min_1 = log2((b-a)/tol)-1;
a = 1; 
b = 3; 
[zero_2,res_2,niter_2] = bisezione(f,a,b,tol,nmax);
k_min_2 = log2((b-a)/tol)-1;

%%
% Problema 2

f=@(x) x.^3-3.*x.^2.*2.^(-x)+3.*x.*4.^(-x)-8.^(-x); 
df=@(x) 3.*x.^2-6.*x.*2.^(-x)+3.*x.^2.*2.^(-x).*log(2)...
    +3.*4.^(-x)-3.*x.*4.^(-x).*log(4)+8.^(-x).*log(8); 
[zero,iter,xvect,xdif,fx]=newton(f,df,0,eps,100); 
semilogy(xdif,'r','Linewidth',2); 
grid on, hold on
f=@(x)(x-2^(-x)).^3; 
df=@(x)(1+2^(-x)*log(2))*3.*(x-2^(-x)).^2; 
[zero1,iter1,xvect1,xdif1,fx1]=newton(f,df,1,eps,100);
semilogy(xdif1,'b','Linewidth',2); 

%%
% Problema 4

r = 3;
K = 1;
tol = 1.e-10;
nmax = 100;
id = @(x) x;
phi_v = @(x) r*x./(1 + K*x);
f_v = @(x) r./(1 + K*x);
phi_p = @(x) r*x.^2./(1 + (x/K).^2);
f_p = @(x) r*x./(1 + (x/K).^2);
fplot(id, [-10,10], 'LineWidth', 2)
hold on
fplot(phi_p, [-10,10])
fplot(phi_v, [-10,10])

x_0 = 1;
a = - 0.5;
b = 4;
[zero_v,iter_v,xvect_v,xdif_v,fx_v]=puntofisso(f_v,phi_v,x_0,tol,nmax);
[zero_p,iter_p,xvect_p,xdif_p,fx_p]=puntofisso(f_p,phi_p,x_0,tol,nmax);

%%
% Problema 3

function [zero,iter,xvect,xdif,fx]=puntofisso(fun,phi,x0,tol,nmax)
% FIXPOINT iterazione di punto fisso.
% [ZERO,ITER,XVECT,XDIF,FX]=FIXPOINT(FUN,PHI,X0,TOL,NMAX) cerca lo 
% zero di una funzione continua FUN usando il metodo di punto fisso X=PHI(X), 
% partendo dal dato iniziale X0. FUN riceve in ingresso lo scalare x e restituisce un 
% valore scalare reale. TOL specifica la tolleranza del metodo. ZERO è
% l’approssimazione della radice. ITER è il numero di iterate svolte, XVECT è
% il vettore delle iterate, XDIF il vettore delle differenze tra iterate successive, FX il 
% vettore dei residui.
err=tol+1; 
iter=0;
fx0=fun(x0); xdif=[]; xvect=x0; fx=fx0;
while iter < nmax && err > tol
    x=phi(x0);
    err=abs(x-x0); xdif=[xdif; err]; xvect=[xvect;x]; 
    x0=x; fx0=fun(x0); fx=[fx;fx0];
    iter=iter+1;
end
zero=xvect(end);
end

