% Test function 3b (New Schwefel's objective function)
% global optimum: x(i)=567.06 ;  min F(x)=-n*465.07 , n-number of variables
% -800 < x(i) < 800

function[Fit]=testfn3b(Pop)

x0=-150;  
y0=250; 

[lpop,lstring]=size(Pop);
Fit=zeros(1,lpop);

for i=1:lpop
  x=Pop(i,:);
  Fit(i)=0;	
  for j=1:lstring
    Fit(i)=Fit(i)-(x(j)-x0)*sin(sqrt(abs((x(j)-x0))))+y0;
  end    
end
