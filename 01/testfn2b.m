% Test function 2 (Rastigin's objective function)
% It is a multimodal function with optional number of input variables.
% The global optimum is:  x(i)=0; i=1...n ;  Fit(x)=0;
% -5 < x(i) < 5
% Other local minimas are located in a grid with the step=1

function[Fit]=testfn2b(Pop)

g0=1.27;
f0=0;
a=0.5;

[lpop,lstring]=size(Pop);

for i=1:lpop
  G=Pop(i,:);
  Fit(i)=0; %lstring*10;	
  for j=1:lstring
    Fit(i)=Fit(i)+((a*(G(j))-g0)^2-10*cos(2*pi*((a*G(j))-g0)))+f0;
  end   
end
