% Demo program na klasifikaciu predmetov skupiny A a B na základe vlastností V1 a V2 
% NS má 2 vstupy veliciny V1,V2 o rozsahu 0-1 (0-100%) a 2 výstupy o rozsahu 0-1, 
% kde hodnota 1.výstup prislúcha skupine A a  2. výstup skupine B

echo on
% Príklad na klasifikáciu skupín A a B pomocou NS
% data pre skupinu A
%xA =0.75 + 0.4*rand(1,10)-0.2;
%yA =0.3 + 0.4*rand(1,10)-0.2;
h=figure;
title('Zadaj body skupiny A')
axis([0 1 0 1])
[xA,yA]=ginput;
xA=xA'; yA=yA';

figure(h);
plot(xA,yA,'or')
hold on

% data pre skupinu B
% xB =0.4 + 0.4*rand(1,10)-0.2;
% yB =0.7 + 0.3*rand(1,10)-0.15;
figure(h);
axis([0 1 0 1])
title('Zadaj body skupiny B')
[xB,yB]=ginput;
xB=xB'; yB=yB';

figure(h);
plot(xB,yB,'*b')

% data pre skupinu C
% xC =0.4 + 0.4*rand(1,10)-0.2;
% yC =0.7 + 0.3*rand(1,10)-0.15;
figure(h);
axis([0 1 0 1])
title('Zadaj body skupiny C')
[xC,yC]=ginput;
xC=xC'; yC=yC';

figure(h);
plot(xC,yC,'+g')

% vstupné data pre NS
V1=[xA xB xC];
V2=[yA yB yC];
X=[V1;V2]

nA=length(xA);
nB=length(xB);
nC=length(xC);

% výstupne data pre NS
P=[ones(1,nA) zeros(1,nB) zeros(1,nC);zeros(1,nA) ones(1,nB) zeros(1,nC);zeros(1,nA) zeros(1,nB) ones(1,nC)];

disp('---- stlac klavesu ----')
pause

% vytvorenie struktury NS na klasifikaciu
net = patternnet(10);

% vsetky data pouzite na trenovanie
net.divideFcn='dividetrain';
% net.divideParam.trainRatio=1;
% net.divideParam.valRatio=0;
% net.divideParam.testRatio=0;

net.trainParam.goal = 0.000001;	    % Ukoncovacia podmienka na chybu SSE.
net.trainParam.epochs = 300;  	    % Max. pocet trénovacích cyklov.
net.trainParam.min_grad=1e-10;      % Ukoncovacia podmienka na min. gradient

% trenovanie siete
net = train(net,X,P);


% simulacia vystupu NS
y = net(X);
% vypocet chyby siete
perf = perform(net,P,y)

% priradenie vstupov do tried
classes = vec2ind(y)

disp('---- stlac klavesu ----')
pause


% testovacie data 5 skupina B a 5 skupina A
%X2=rand(2,20);
figure(h);
axis([0 1 0 1])
title('Zadaj testovacie body ')
[xT,yT]=ginput;
X2=[xT';yT'];

% simulacia vystupu NS
y2 = net(X2)
retcolor='rbg';
% priradenie vstupov do tried
classes2 = vec2ind(y2)
echo off
figure(h);
for k=1:size(X2,2),
   plot(X2(1,k),X2(2,k),[retcolor(classes2(k)) 'x'])  
end