%% TUTORAGGIO NUMERO 4
clear
close all

%%
% Problema 1

f = @(x)0.0039+0.0058./(1+exp(x));
a = -5; b = 5;
x_1 = linspace(xa,xb,1000);
y_1 = f(x_1);
nn = 4:4:70;
m = length(nn);
err_c = [];
err_p = [];
for n=nn
    for i=0:n
		x_cgl = cos(pi*i/n); % Chebyshev-Gauss-Lobatto
		x_cg = cos(pi*(2*i+1)/(2*(n+1))); % Chebyshev-Gauss 
		x_c(i+1) = ((a+b)/2)-((b-a)/2)*x_cgl;
    end
    
    y_c = f(x_c);
	p_che = polyfit(x_c,y_c,n); 
	y_che = polyval(p_che,x_1);
	e_che = norm(y_1-y_che,inf); 
	err_c = [err_c; e_che];
    
    x_p = linspace(a,b,n);
    
    y_p = f(x_p);
    p_p = polyfit(x_p,y_p,n); 
	y_p = polyval(p_p,x_1);
	e_p = norm(y_1-y_p,inf); 
	err_p = [err_p; e_p];
end
semilogy(nn, err_c, 'r-')
hold on
semilogy(nn, err_p, 'b-')

%%
% Problema 1

f = @(x) 35000000*x+401000./x-17122.7./x.^2-1494500;
[zero,res,niter] = bisezione(f,0.01,0.06,1.e-12,100);

%%
% Problema 3

function [zero,iter,xvect,xdif,fx]=newton(fun,dfun,x0,tol,nmax)
% NEWTON metodo di Newton.
% [ZERO,ITER,XVECT,XDIF,FX]=NEWTON(FUN,DFUN,X0,TOL,NMAX) cerca lo 
% zero di una funzione continua FUN nell’intervallo [A,B] usando il metodo di
% Newton e partendo da X0. TOL e NMAX specificano la tolleranza ed il massimo
% numero di iterazioni. FUN e DFUN ricevono in ingresso lo scalare x e restituiscono 
% un valore scalare reale. DFUN è la funzione derivata di FUN.
% ZERO è l’approssimazione della radice, ITER è il numero di iterate svolte.
% XVECT è il vettore delle iterate, XDIF il vettore delle differenze tra iterate
% successive, FX il vettore dei residui.
err=tol+1; iter=0; xdif=[];
fx0=fun(x0); xvect=x0; fx=fx0;
while iter < nmax && err> tol
    dfx0=dfun(x0); 
    if dfx0==0
        fprintf('Arresto causa annullamento derivata\n'); zero=[];return
    end
x=x0-fx0/dfx0;
err=abs(x-x0); x0=x; fx0=fun(x0); iter=iter+1; 
xvect=[xvect;x0]; fx=[fx;fx0]; xdif=[xdif; err];
end
zero=xvect(end); 
end