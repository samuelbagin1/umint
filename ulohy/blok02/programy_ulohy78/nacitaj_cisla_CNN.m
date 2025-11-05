% načítanie a príprava dát pre - rozpoznavanie cislic 0-9, MNIST dataset
% data - XDataall - 784 x 4940 (vstupne data x vzorky)
clear

% nacitanie dat
load('datapiscisla_all.mat');

% Nulovanie premennych pre data
XTrain = [];
YTrain = [];
YTr = [];
XvalDat = [];
YvalDat = [];

trainLen = 1;        % index vzorky trenovacie data
valLen = 1;         % index vzorky testovacie data
imgSize = 28;       % vstupny rozmer obrazu
percento=60;        % percento trenovacich dat
len = length(YDataall); % dlzka dat

Train_idx = randperm(len,len/100*percento);   % nahodne vygenerovanie indexov dat pre trenovanie

for i = 1:10
    YTr = [YTr, i*ones(1,494)];
end

for i = 1:len
    xhelp = [];
    yhelp = [];
    y = 1;
    
    % rozbytie vektora do obrazu 28x28 po riadkoch
    for x = 1:784
        yhelp = [yhelp, XDataall(x, i)];
        if y == 28
            xhelp = [xhelp; yhelp];
            yhelp = [];
            y = 0;
        end
        y = y + 1;
    end
    
    % ak index vzorky je medzi trenovacimi datami
    if ismember(i, Train_idx)
        XTrain(:,:,1,trainLen) = xhelp;
        YTrain = [YTrain, YTr(i)];
        trainLen = trainLen + 1;
    else
        XvalDat(:,:,1,valLen) = xhelp;
        YvalDat = [YvalDat, YTr(i)];
        valLen = valLen + 1;
    end
end

% zmena na typ categorical
YTrain = categorical(YTr');
YvalDat = categorical(YvalDat');


figure
idx = randperm(length(YvalDat),10);       % nahodne vygenerovanych 10 vzoriek

for i = 1:numel(idx)
    subplot(2,5,i)    
    imshow(XvalDat(:,:,:,idx(i)))
    title(char(YvalDat(idx(i))))
    drawnow
end


