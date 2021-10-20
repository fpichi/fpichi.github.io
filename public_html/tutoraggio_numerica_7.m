%% TUTORAGGIO NUMERO 7
clear
close all

%%
%Problema 2

s=menu('Scegli ode da risolvere','D(y(t))=sin(t).*(1+cos(t)-y(t))',...
        'D(y(t))=(2t+y(t)).^2','D(y(t))=y(t).*(1-y(t))');

t0=0;
tf=1;
h=0.01;
tol=1.e-8;
itmax=20;

switch s
    case 1
       fun=inline('sin(t).*(1+cos(t)-y)','t','y');
       dfun=inline('-sin(t)','t','y'); 
       u0=3;
       
       %EULERO 
       a=1;
       b=[0;1];
       [te,ue]=multistep(a,b,tf,t0,u0,h,fun,dfun,tol,itmax);
       subplot(1,5,1)
       plot(te,ue,'r')
       hold on
       plot(te,2+cos(te),'b')
       hold off
       title('Eulero')
       ee=norm(ue-2-cos(te),inf);
       
       %EULERO IMPLICITO
       a=1;
       b=[1;0];
       [tei,uei]=multistep(a,b,tf,t0,u0,h,fun,dfun,tol,itmax);
       subplot(1,5,2)
       plot(tei,uei,'r')
       hold on
       plot(tei,2+cos(tei),'b')
       hold off
       title('Eulero implicito')
       eei=norm(uei-2-cos(tei),inf);
       
       %CRANK-NICOLSON
       a=1;
       b=[0.5;0.5];
       [tcn,ucn]=multistep(a,b,tf,t0,u0,h,fun,dfun,tol,itmax);
       subplot(1,5,3)
       plot(tcn,ucn,'r') 
       hold on
       plot(tcn,2+cos(tcn),'b')
       hold off
       title('Crank-Nicolson')
       ecn=norm(ucn-2-cos(tcn),inf);

       %PUNTO MEDIO
       f0=fun(t0,u0);
       u1=u0+(h/2)*(f0+fun(h,u0+h*f0));
       a=[0;1];
       b=[0;2;0];
       [tpm,upm]=multistep(a,b,tf,[t0;t0+h],[u0;u1],h,fun,dfun,tol,itmax);
       subplot(1,5,4)
       plot(tpm,upm,'r')
       hold on
       plot(tpm,2+cos(tpm),'b')
       hold off
       title('Punto medio')
       epm=norm(upm-2-cos(tpm),inf);
       
       %SIMPSON
       f0=fun(t0,u0);
       u1=u0+(h/2)*(f0+fun(h,u0+h*f0));   %Dovrei utilizzare RK4
       a=[0;1];
       b=[1/3;4/3;1/3];
       [ts,us]=multistep(a,b,tf,[t0;t0+h],[u0;u1],h,fun,dfun,tol,itmax);
       subplot(1,5,5)
       plot(ts,us,'r')
       hold on
       plot(ts,2+cos(ts),'b')
       hold off
       title('Simpson')
       es=norm(us-2-cos(ts),inf);
       
       figure
       plot(te,abs(ue-2-cos(te)),tei,abs(uei-2-cos(tei)))
       title('Grafico del valore assoluto dell''errore di approssimazione')
       legend('Eulero esplicito','Eulero implicito','Location','NorthEastOutside')
       
       figure
       plot(tcn,abs(ucn-2-cos(tcn)),tpm,abs(upm-2-cos(tpm)),ts,abs(us-2-cos(ts)))
       title('Grafico del valore assoluto dell''errore di approssimazione')
       legend('Crank-Nicolson','Punto medio','Simpson','Location','NorthEastOutside')      
       
       
    case 2
       fun=inline('(2*t+y).^2','t','y');
       dfun=inline('2*(2*t+y)','t','y');
       u0=0;
       
       %EULERO 
       a=1;
       b=[0;1];
       [te,ue]=multistep(a,b,tf,t0,u0,h,fun,dfun,tol,itmax);
       subplot(1,5,1)
       plot(te,ue,'r')
       hold on
       plot(te,sqrt(2)*tan(sqrt(2)*te)-2*te,'b')
       hold off
       title('Eulero')
       ee=norm(ue-(sqrt(2)*tan(sqrt(2)*te)-2*te),inf);
       
       %EULERO IMPLICITO
       a=1;
       b=[1;0];
       [tei,uei]=multistep(a,b,tf,t0,u0,h,fun,dfun,tol,itmax);
       subplot(1,5,2)
       plot(tei,uei,'r')
       hold on
       plot(tei,sqrt(2)*tan(sqrt(2)*tei)-2*tei,'b')
       hold off
       title('Eulero implicito')
       eei=norm(uei-(sqrt(2)*tan(sqrt(2)*tei)-2*tei),inf);
       
       %CRANK-NICOLSON
       a=1;
       b=[0.5;0.5];
       [tcn,ucn]=multistep(a,b,tf,t0,u0,h,fun,dfun,tol,itmax);
       subplot(1,5,3)
       plot(tcn,ucn,'r') 
       hold on
       plot(tcn,sqrt(2)*tan(sqrt(2)*tcn)-2*tcn,'b')
       hold off
       title('Crank-Nicolson')
       ecn=norm(ucn-(sqrt(2)*tan(sqrt(2)*tcn)-2*tcn),inf);

       %PUNTO MEDIO
       f0=fun(t0,u0);
       u1=u0+(h/2)*(f0+fun(h,u0+h*f0));
       a=[0;1];
       b=[0;2;0];
       [tpm,upm]=multistep(a,b,tf,[t0;t0+h],[u0;u1],h,fun,dfun,tol,itmax);
       subplot(1,5,4)
       plot(tpm,upm,'r')
       hold on
       plot(tpm,sqrt(2)*tan(sqrt(2)*tpm)-2*tpm,'b')
       hold off
       title('Punto medio')
       epm=norm(upm-(sqrt(2)*tan(sqrt(2)*tpm)-2*tpm),inf);
       
       %SIMPSON
       f0=fun(t0,u0);
       u1=u0+(h/2)*(f0+fun(h,u0+h*f0));
       a=[0;1];
       b=[1/3;4/3;1/3];
       [ts,us]=multistep(a,b,tf,[t0;t0+h],[u0;u1],h,fun,dfun,tol,itmax);
       subplot(1,5,5)
       plot(ts,us,'r')
       hold on
       plot(ts,sqrt(2)*tan(sqrt(2)*ts)-2*ts,'b')
       hold off
       title('Simpson')
       es=norm(us-(sqrt(2)*tan(sqrt(2)*ts)-2*ts),inf);
       
       figure
       plot(te,abs(ue-2-cos(te)),tei,abs(uei-2-cos(tei)))
       title('Grafico del valore assoluto dell''errore di approssimazione')
       legend('Eulero esplicito','Eulero implicito','Location','NorthEastOutside')
       
       figure
       plot(tcn,abs(ucn-2-cos(tcn)),tpm,abs(upm-2-cos(tpm)),ts,abs(us-2-cos(ts)))
       title('Grafico del valore assoluto dell''errore di approssimazione')
       legend('Crank-Nicolson','Punto medio','Simpson','Location','NorthEastOutside')      
        
       
    case 3
       fun=inline('y.*(1-y)','t','y');
       dfun=inline('1-2*y','t','y');
       u0=0.5;
       
       %EULERO 
       a=1;
       b=[0;1];
       [te,ue]=multistep(a,b,tf,t0,u0,h,fun,dfun,tol,itmax);
       subplot(1,5,1)
       plot(te,ue,'r')
       hold on
       plot(te,(exp(te)./(1+exp(te))),'b')
       hold off
       title('Eulero')
       ee=norm(ue-(exp(te)./(1+exp(te))),inf);
       
       %EULERO IMPLICITO
       a=1;
       b=[1;0];
       [tei,uei]=multistep(a,b,tf,t0,u0,h,fun,dfun,tol,itmax);
       subplot(1,5,2)
       plot(tei,uei,'r')
       hold on
       plot(tei,(exp(tei)./(1+exp(tei))),'b')
       hold off
       title('Eulero implicito')
       eei=norm(uei-(exp(tei)./(1+exp(tei))),inf);
       
       %CRANK-NICOLSON
       a=1;
       b=[0.5;0.5];
       [tcn,ucn]=multistep(a,b,tf,t0,u0,h,fun,dfun,tol,itmax);
       subplot(1,5,3)
       plot(tcn,ucn,'r') 
       hold on
       plot(tcn,(exp(tcn)./(1+exp(tcn))),'b')
       hold off
       title('Crank-Nicolson')
       ecn=norm(ucn-(exp(tcn)./(1+exp(tcn))),inf);

       %PUNTO MEDIO
       f0=fun(t0,u0);
       u1=u0+(h/2)*(f0+fun(h,u0+h*f0));
       a=[0;1];
       b=[0;2;0];
       [tpm,upm]=multistep(a,b,tf,[t0;t0+h],[u0;u1],h,fun,dfun,tol,itmax);
       subplot(1,5,4)
       plot(tpm,upm,'r')
       hold on
       plot(tpm,(exp(tpm)./(1+exp(tpm))),'b')
       hold off
       title('Punto medio')
       epm=norm(upm-(exp(tpm)./(1+exp(tpm))),inf);
       
       %SIMPSON
       f0=fun(t0,u0);
       u1=u0+(h/2)*(f0+fun(h,u0+h*f0));
       a=[0;1];
       b=[1/3;4/3;1/3];
       [ts,us]=multistep(a,b,tf,[t0;t0+h],[u0;u1],h,fun,dfun,tol,itmax);
       subplot(1,5,5)
       plot(ts,us,'r')
       hold on
       plot(ts,(exp(ts)./(1+exp(ts))),'b')
       hold off
       title('Simpson')
       es=norm(us-(exp(ts)./(1+exp(ts))),inf);
       
       figure
       plot(te,abs(ue-2-cos(te)),tei,abs(uei-2-cos(tei)))
       title('Grafico del valore assoluto dell''errore di approssimazione')
       legend('Eulero esplicito','Eulero implicito','Location','NorthEastOutside')
       
       figure
       plot(tcn,abs(ucn-2-cos(tcn)),tpm,abs(upm-2-cos(tpm)),ts,abs(us-2-cos(ts)))
       title('Grafico del valore assoluto dell''errore di approssimazione')
       legend('Crank-Nicolson','Punto medio','Simpson','Location','NorthEastOutside')       
        
end

%%
%Problema 3

s=menu('Scegli ode da risolvere','D(y(t))=sin(t).*(1+cos(t)-y(t))',...
        'D(y(t))=(2t+y(t)).^2','D(y(t))=y(t).*(1-y(t))');
t0=0;
tf=1;
t0f=[t0 tf];
h=0.01;
tol=1.e-8;
itmax=20;

switch s
    case 1
         fun=inline('sin(t).*(1+cos(t)-y)','t','y'); 
         u0=3;
         [t,y]=ode15s(fun,t0f,u0);
         [t1,y1]=ode45(fun,t0f,u0);
         e15=norm(y-(2+cos(t)),inf);
         e45=norm(y1-(2+cos(t1)),inf);
 
         plot(t,y,'r')
         hold on
         plot(t,2+cos(t),'b')
         hold off
         title('ode15s')
         
         figure
         plot(t1,y1,'r')
         hold on
         plot(t1,2+cos(t1),'b')
         hold off 
         title('ode45')
         
         figure
         plot(t,abs(y-(2+cos(t))),'m')
         title('Errore ode15s')
         
         figure
         plot(t1,abs(y1-(2+cos(t1))),'g')        
         title('Errore ode45')
          
    case 2
         fun=inline('(2*t+y).^2','t','y');
         u0=0;
         [t,y]=ode15s(fun,t0f,u0);
         [t1,y1]=ode45(fun,t0f,u0);
         e15=norm(y-(sqrt(2)*tan(sqrt(2)*t)-2*t),inf);
         e45=norm(y1-(sqrt(2)*tan(sqrt(2)*t1)-2*t1),inf);
 
         plot(t,y,'r')
         hold on
         plot(t,sqrt(2)*tan(sqrt(2)*t)-2*t,'b')
         hold off
         title('ode15s')
         
         figure
         plot(t1,y1,'r')
         hold on
         plot(t1,sqrt(2)*tan(sqrt(2)*t1)-2*t1,'b')
         hold off 
         title('ode45')
         
         figure
         plot(t,abs(y-(sqrt(2)*tan(sqrt(2)*t)-2*t)),'m')
         title('Errore ode15s')
         
         figure
         plot(t1,abs(y1-(sqrt(2)*tan(sqrt(2)*t1)-2*t1)),'g')        
         title('Errore ode45')
        
    case 3
         fun=inline('y.*(1-y)','t','y');
         u0=0.5;
         [t,y]=ode15s(fun,t0f,u0);
         [t1,y1]=ode45(fun,t0f,u0);
         e15=norm(y-(exp(t)./(1+exp(t))),inf);
         e45=norm(y1-(exp(t1)./(1+exp(t1))),inf);
         
         plot(t,y,'r')
         hold on
         plot(t,(exp(t)./(1+exp(t))),'b')
         hold off
         title('ode15s')
         
         figure
         plot(t1,y1,'r')
         hold on
         plot(t1,(exp(t1)./(1+exp(t1))),'b')
         hold off 
         title('ode45')
         
         figure
         plot(t,abs(y-(exp(t)./(1+exp(t)))),'m')
         title('Errore ode15s')
         figure
         plot(t1,abs(y1-(exp(t1)./(1+exp(t1)))),'g')        
         title('Errore ode45')
        
end

%%
%Problema 1

function [ t,u ] = multistep( a,b,tf,t0,u0,h,fun,dfun,tol,itmax )
%Risolve il problema di Cauchy y'=f(t,y) e dati iniziali u0, per t in 
%(t0,tf) con passo h e con il metodo multistep avente per coefficienti a e b
%In output restituisce i valori della soluzione calcolati nei vari istanti
%temporali

f=fun(t0,u0);
p=length(a)-1;
u=u0;
nt=fix((tf-t0(1))/h);

for k=1:nt-p
    lu=length(u);
    G=a'*u(lu:-1:lu-p)+h*b(2:p+2)'*f(lu:-1:lu-p);
    t0=[t0;t0(lu)+h];   
    %{
    if b(1)==0
       disp('Il metodo è esplicito');
       unew=G; fnew=fun(t0(end),unew);
    else
       disp('Il metodo è implicito');
    %}
    unew=u(lu);
    t=t0(lu+1);
    it=0;
    err=tol+1;
    while err>tol && it<itmax
        y=unew;
        den=1-h*b(1)*dfun(t,y);
        fnew=fun(t,y);
        if den==0
            it=itmax+1;
        else
            it=it+1;
            unew=unew-(unew-h*b(1)*fnew-G)/den;
            err=abs(y-unew);
        end
    %end
    end
    u=[u;unew];
    f=[f;fnew];
end
t=t0;
end