%   warmpopx - zohreje populáciu, 
%
%	Description: nasobi populaciu nahodnymi cislami s max. amplit. alfa a
%	pravdepodobnostou wr
%	
%	Syntax: 
%
%	Newpop=warmpopx(Oldpop,wr,alfa,minimum,maximum)
%
%	       Newpop - new warmed population
%	       Oldpop - old population
%	       alfa   - warm-up amplitude, 0<alfa<1
%          wr - warm-up rate (probability),  0<wr<1
%          minimum, maximum - boundaries 
%

% I.Sekaj, 1/2023

function[Newpop]=warmpopx(Oldpop,wr,alfa,minimum,maximum)

[lpop,lstring]=size(Oldpop);

% M=(2*rand(lpop,lstring)-1)*alfa;  %+ones(lpop,lstring);
% Newpop=Oldpop+M;

for r=1:lpop
    for s=1:lstring
        if rand<wr
            Newpop(r,s)=Oldpop(r,s)*(1+alfa*(rand*2-1));
            if Newpop(r,s)>maximum
                Newpop(r,s)=maximum;
            elseif Newpop(r,s)<minimum
                Newpop(r,s)=minimum;
            end
        else
            Newpop(r,s)=Oldpop(r,s);
        end
    end
end
            

