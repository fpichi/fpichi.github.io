%% TUTORAGGIO NUMERO 2
clear
close all

%%
%Problema 1

f_1 = @(x) (1-x).^5;
g_1 = @(x) 1-5*x+10*x.^2-10*x.^3+5*x.^4-x.^5;
x = 0.998 : 5e-5 : 1.002;
figure;
plot(x, f_1(x), 'r', x, g_1(x), 'b+'); grid;
x = 1.998 : 5e-5 : 2.002;
figure;
plot(x, f_1(x), 'r', x, g_1(x), 'b+'); grid;

%%
%Problema 2

K_2 = zeros(1,10); 
err = zeros(1,10); 
nn = 1:10;

for n = 1:10
A = hilb(n);
K_2(n) = cond(A);
x_e = ones(n,1);
b = A*x_e;
x = A\b;
err(n) = norm(x-x_e)/norm(x_e);
end

figure
semilogy(nn, K_2, 'r');
grid;
xlabel('n');
ylabel('K_2(n)');

figure
semilogy(nn, K_2, 'r--o', nn, err, 'b-s');
grid; xlabel('n'); legend('K_2(n)', 'err(n)');

%%
%Problema 3

n=10;
A = 2*diag(ones(1,n)) - diag(ones(1,n-1), 1) - diag(ones(1,n-1), -1);
d = det(A);
norm_1 = norm(A,1);
norm_2 = norm(A,2);
norm_inf = norm(A,inf);

K_1 = cond(A,1);
K_2 = cond(A,2);
K_inf = cond(A,inf);

%%
%Problema 5

A=rand(10);                    
B=lu2(A);                      
L=tril(B,-1)+(eye(10));         
U=triu(B);                      
M=L*U;                          
norma=norm(A-M);                

b=sum(A,2);                      

y=forward(L,b);                 
x_r=backward(U,y);                

H=hilb(10);                     
b=sum(H,2);                     
A=lu2(H);                       

L=tril(A,-1)+eye(10);           
U=triu(A);

y=forward(L,b);                 
x_h=backward(U,y);  

%%
%Problema 6

A = [2 -0.5 0 -0.5; 0 4 0 2; -0.5 0 6 0.5; 0 0 1 9];
gershdisc(A)  
B = [-5 0 0.5 0.5; 0.5 2 0.5 0; 0 1 0 0.5; 0 0.25 0.5 3];
gershdisc(B)  
C=[1 0 -1; 0 -2+2i 2*sqrt(2); 0.25 2 -5.75i];  
gershdisc(C)                                   

function gershdisc( A )
%La funzione gersdisc prende in input una matrice A e da in output un 
%grafico con i dischi di gershgorin.
n=256;
d=2*pi/n;
t=0:d:2*pi;
m=size(A,1);
r=sum(abs(A),2)-diag(abs(A));
rt=(sum(abs(A),1).')-diag(abs(A));
for i=1:m  
plot(real(A(i,i))+r(i)*cos(t),imag(A(i,i))+r(i)*sin(t),'b');
hold on
plot(real(A(i,i))+rt(i)*cos(t),imag(A(i,i))+rt(i)*sin(t),'r');
end
aut=eig(A);
plot(real(aut),imag(aut),'*');
grid 
axis equal
end

%%
%Problema 4

function [ A ] = lu2( A )
%Questo programma fattorizza una matrice A con lu e la restituisce come somma di matrice
%triangolare superiore U e di una matrice strettamente triangolare inferiore L
[n,m]=size(A);
if n~=m 
    error('la matrice non e'' quadrata')
end
for k=1:n-1
    if A(k,k)==0 
        error('elemento pivoting nullo')
    end
    A(k+1:n,k)=A(k+1:n,k)/A(k,k);
    for i=k+1:n
        for j=k+1:n
            A(i,j)=A(i,j)-A(i,k)*A(k,j);
        end 
    end
end

end

function [ b ] = forward(L,b)
%Questo programma risolve un sistema lineare triangolare inferiore
[n,m]=size(L);
if(n~=m) 
    error('matrice non quadrata')
end
if(prod(diag(L))==0) 
    error('matrice singolare')
end
b(1)=b(1)/L(1,1);
for i=2:n
    b(i)=(b(i)-L(i,1:i-1)*b(1:i-1))/L(i,i);
end
end

function [ b ] = backward(U,b)
%Questo programma risolve un sistema lineare triangolare superiore
[n,m]=size(U);
if(n~=m) 
    error('matrice non quadrata')
end
if(prod(diag(U))==0) 
    error('matrice singolare')
end
b(n)=b(n)/U(n,n);
for i=n-1:-1:1
    b(i)=(b(i)-U(i,i+1:n)*b(i+1:n))/U(i,i);
end
end