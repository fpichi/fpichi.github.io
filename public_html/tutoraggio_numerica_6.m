%% TUTORAGGIO NUMERO 6
clear
close all

%%
%Problema 2

a = 0;
b = 2*pi;
f = @(x) x.*exp(-x).*cos(2*x);
int_e = (3*(exp(-2*pi) - 1) - 10*pi*exp(-2*pi))/25;
int1 = []; int2 = []; int3 = [];
err1 = []; err2 = []; err3 = [];
ord1 = []; ord2 = []; ord3 = [];
H = [];
M = 2.^(4:8);

for m = M
    h=(b-a)/m;
    H = [H, h];
    
    int_pm = puntomedio(a,b,m,f);
    int1 = [int1, int_pm];
    err1 = [err1, abs(int_pm - int_e)];

    
    int_t = trapezi(a,b,m,f);
    int2 = [int2, int_t];
    err2 = [err2, abs(int_t - int_e)];
    
    int_cs = simpson(a,b,m,f);
    int3 = [int3, int_cs];
    err3 = [err3, abs(int_cs - int_e)];
end

loglog(H, err1,'-*')
hold on
grid on
loglog(H, err2,'-o')
loglog(H, err3,'-p')

l = length(M);
for i = 2:l
    ord1 = [ord1, log2(err1(i-1)/err1(i))];
    ord2 = [ord2, log2(err2(i-1)/err2(i))];
    ord3 = [ord3, log2(err3(i-1)/err3(i))];
end

%%
%Problema 3
syms t
tol = 1.e-4;

f1 = 1./(1 + (t-pi).^2);
f_1 = matlabFunction(f1);
a_1 = 0; b_1 = 5; err_1 = []; x = linspace(a_1,b_1);
i_1 = double(int(f1,a_1,b_1));
f1_tt = matlabFunction(diff(f1,2));
f1_tt_max = max(abs(f1_tt(x)));
m_1 = sqrt((b_1 - a_1)^3*f1_tt_max/(24*tol));

f1_tttt = matlabFunction(diff(f1,4));
f1_tttt_max = max(abs(f1_tttt(x)));
m_1_cs = ((b_1 - a_1)^5*f1_tttt_max/(180*16*tol))^(1/4);

f2 = exp(t).*cos(t);
f_2 = matlabFunction(f2);
a_2 = 0; b_2 = pi; err_2 = [];
i_2 = double(int(f2,a_2,b_2)); 

f3 = sqrt(t.*(1-t)); 
f_3 = matlabFunction(f3);
a_3 = 0; b_3 = 1; err_3 = [];
i_3 = double(int(f3,a_3,b_3)); 

for m = 1:25:500
    int_1 = puntomedio(a_1,b_1,m,f_1);
    err_1 = [err_1, abs(int_1 - i_1)];
    
    int_2 = puntomedio(a_2,b_2,m,f_2);
    err_2 = [err_2, abs(int_2 - i_2)];
    
    int_3 = puntomedio(a_3,b_3,m,f_3);
    err_3 = [err_3, abs(int_3 - i_3)];
end

semilogy(err_1,'-o')
grid on
hold on
semilogy(err_2,'-*')
semilogy(err_3,'-p')

%%
%Problema 4

a = 149.60e6; e = 0.0167086; b = a*sqrt(1-e^2); 
a_1 = 0; b_1 = 2*pi;
syms t; 

f = sqrt(a^2*cos(t).^2+b^2*sin(t).^2); 
f2 = matlabFunction(diff(f,2));
tt = linspace(a_1,b_1,10000); 
f2max = max(f2(tt));

h = sqrt(6/(pi*f2max)*1.e4);
m = fix(2*pi/h)+1; 

f1 = matlabFunction(f);
i_1 = trapezi(a_1,b_1,m,f1);

%%
%Problema 1

function int = puntomedio(a,b,m,fun)
% puntomedio formula composita del punto medio.
% INT=PUNTOMEDIO(A,B,M,FUN) calcola un’approssimazione dell’integrale della 
% funzione FUN su (A,B) con il metodo del punto medio su una griglia uniforme 
% di M intervalli. FUN riceve in ingresso un vettore reale x e restituisce un
% vettore della stessa dimensione.
h=(b-a)/m;
x=a+h/2:h:b;
y=fun(x);
if size(y)==1
	dim=length(x);
	y=y.*ones(dim,1); 
end
int=h*sum(y); 
end

function int = trapezi(a,b,m,fun)
% trapezi formula composita del trapezio.
% INT=TRAPEZI(A,B,M,FUN) calcola un’approssimazione dell’integrale della % funzione FUN su (A,B) con il metodo del trapezio su una griglia uniforme
% di M intervalli. FUN riceve in ingresso un vettore reale x e restituisce un
% vettore della stessa dimensione.
h=(b-a)/m;
x=a:h:b;
y=fun(x);
if size(y)==1
    dim=length(x);
    y=y.*ones(dim,1); 
end
int=h*(0.5*y(1)+sum(y(2:m))+0.5*y(m+1)); 
end

function int = simpson(a,b,m,fun)
% simpson formula composita di Simpson.
% INT=SIMPSON(A,B,M,FUN) calcola un’approssimazione dell’integrale della % funzione FUN su (A,B) con il metodo di Simpson su una griglia uniforme
% di M intervalli. FUN riceve in ingresso un vettore reale x e restituisce un
% vettore della stessa dimensione.
h=(b-a)/m;
x=a:h/2:b;
y=fun(x);
if size(y)==1
    dim= length(x);
    y=ones(dim,1).*y; 
end
int=(h/6)*(y(1)+2*sum(y(3:2:2*m-1))+4*sum(y(2:2:2*m))+y(2*m+1)); 
end

