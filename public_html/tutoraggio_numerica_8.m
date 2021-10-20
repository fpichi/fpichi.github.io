%% TUTORAGGIO NUMERO 8
clear
close all

%%
% Problema 1

t0f=[0 10];
h=5.e-4;
u0=[2;2];
u0n=[1.5;1.5];
fun= @(t,y) [y(1).*(1-y(2));-y(2).*(1-y(1))];
[t,u]=ode45(fun,t0f,u0);
[tn,un]=ode45(fun,t0f,u0n);

plot(t,u(:,1),tn,un(:,1),tn,un(:,2),t,u(:,2))
legend('y1 con dato iniCiale [2;2]','y2 con dato iniCiale [2;2]',...
 'y1 con dato iniCiale [1.5;1.5]','y2 con dato iniCiale [1.5;1.5]','Location','NorthEastOutside')
title('Lotka-Volterra con ode45')

figure
plot(u(:,1),u(:,2),un(:,1),un(:,2))
legend('Dato iniCiale [2;2]','Dato iniCiale [1.5;1.5]','Location','NorthEastOutside')
title('Piano delle fasi')

%%
% Problema 2

m=16;
A = zeros(2*m);

for k = 1:m
    A(k, :) = k;
    A(m+k, :) = m-k+1;
end


imagesc(A)
axis equal
axis off
colormap gray
print -dpdf plot1.pdf

B=A+2*(rand(2*m,2*m)-.5);
figure
imagesc(B)
axis equal 
axis off 
colormap gray
print -dpdf plot2.pdf


C(1,1)=(B(1,1)+B(1,2)+B(2,1))/3;
C(1,2*m)=(B(1,2*m-1)+B(1,2*m)+B(2,2*m))/3;
C(2*m,2*m)=(B(2*m,2*m)+B(2*m,2*m-1)+B(2*m-1,2*m))/3;
C(2*m,1)=(B(2*m,1)+B(2*m,2)+B(2*m-1,1))/3;

for s=2:2*m-1
    C(1,s)=(B(1,s)+B(1,s-1)+B(1,s+1)+B(2,s))/4;

    C(2*m,s)=(B(2*m,s)+B(2*m,s-1)+B(2*m,s+1)+B(2*m-1,s))/4;

    C(s,1)=(B(s,1)+B(s-1,1)+B(s+1,1)+B(s,2))/4;

    C(s,2*m)=(B(s,2*m)+B(s-1,2*m)+B(s+1,2*m)+B(s,2*m-1))/4;
end

for s=2:2*m-1
    for t=2:2*m-1
        C(s,t)=(B(s,t)+B(s,t+1)+B(s,t-1)+B(s+1,t)+B(s-1,t))/5;
    end
end

figure
imagesc(C)
axis equal
axis off
colormap gray
print -dpdf plot3.pdf
sqrt(sum(sum((B-A).*(B-A))))
sqrt(sum(sum((C-A).*(C-A))))

%%
%Problema 3

a=5;
b=4;

x=linspace(-a,a,100);
y1=b*sqrt(1-x.^2/(a)^2);
y2=-b*sqrt(1-x.^2/(a)^2);
plot(x,y1,'k')
hold on
plot(x,y2,'k')

c=sqrt(a^2-b^2);
F1=[-c,0];
F2=[c,0];
plot([-c c],[0 0],'*')

teta=pi*(3/4);
dt=0.1;
xold=[c,0];

while 2>1

xa=xold+[cos(teta)*dt, sin(teta)*dt];
if (xa(1).^2)/a^2+(xa(2).^2)/b^2 < 1
    xnew=xa;
    plot([xold(1),xnew(1)],[xold(2),xnew(2)],'r')
    xold=xnew;
else
    if xold(2)>=0 
        segno=1;
    else
        segno=-1;
    end
    
    for i=1:10
        xn=(xa+xold)/2;
        if (xn(1).^2)/a^2+(xn(2).^2)/b^2 < 1
            xold=xn;
        else
            xa=xn;
        end
    end
    xnew=xn;
    plot([xold(1),xnew(1)],[xold(2),xnew(2)],'r')
    xold=xnew;
    
    tan1=-segno*((b/a^2)*xnew(1))/sqrt(1-((xnew(1)^2)/a^2));
    tnor=-1/tan1;
    teta=2*atan(tnor)-teta;
    dt=-dt;
end
pause
end