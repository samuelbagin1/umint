% load
load datapiscisla_all.mat
X = reshape(XDataall,28,28,1,[]); 
Y = categorical(repelem(0:9,494)');

rng(42); 
[trainInd,~,testInd] = dividerand(size(X,4),0.6,0,0.4);
XTrain = X(:,:,:,trainInd); YTrain = Y(trainInd);
XTest = X(:,:,:,testInd); YTest = Y(testInd);

% CNN definicia, architektura 2
layers = [
    imageInputLayer([28 28 1])  % vstupna vrstva - obraz 28x28x1
    convolution2dLayer(5,6,'Padding','same') % 2D konvolucia, 6 filtrov, rozmer 5x5
    batchNormalizationLayer % normalizacna aktivacia
    reluLayer % ReLU funkcia
    maxPooling2dLayer(2,'Stride',2) % maxpooling 2x2 - maximum z matice, krok 2
    convolution2dLayer(5,12,'Padding','same') % 12 filtrov, 5x5
    batchNormalizationLayer % aktivacia normalizacie
    reluLayer
   % maxPooling2dLayer(2,'Stride',2) % max 2x2
    fullyConnectedLayer(32) % plne prepojena vrstva, 32 neuronov
    dropoutLayer(0.5) % regularizacia
    fullyConnectedLayer(10) % 10 outputovych neuronov
    softmaxLayer % distribucia pravdepodobnosti
    classificationLayer]; % finalna klasifikacia

% trenovanie CNN
%                        tren. algo, 20 epoch,         goal 10^-2
options = trainingOptions('sgdm','MaxEpochs',20,'InitialLearnRate',1e-2,...
    'ValidationData',{XTest,YTest},'ValidationFrequency',60,... % pouzitie val. dat, pri kolkej iteracii sa vykona validacia
    'ValidationPatience',5,'MiniBatchSize',256,'Plots','training-progress');
%  stop ak sa 5 validacii zhorsi,  velkost davky obrazov, zobrazi sa proces  trenovania v grafe
net = trainNetwork(XTrain,YTrain,layers,options);

% evaluacia CNN
[YPredTrain,~] = classify(net,XTrain);
[YPredTest,~] = classify(net,XTest);
cnn_train_acc = mean(YPredTrain == YTrain)*100;
cnn_test_acc = mean(YPredTest == YTest)*100;

% confusion matice
figure
subplot(1,2,1), confusionchart(YTrain,YPredTrain), title('CNN Train')
subplot(1,2,2), confusionchart(YTest,YPredTest), title('CNN Test')

% 5-fold cross-validation
accs = zeros(1,5);
for fold = 1:5
    rng(fold);
    [tInd,~,vInd] = dividerand(size(X,4),0.6,0.2,0.2);
    netCV = trainNetwork(X(:,:,:,tInd),Y(tInd),layers,options);
    accs(fold) = mean(classify(netCV,X(:,:,:,vInd)) == Y(vInd))*100;
end

% MLP compare
mlp = patternnet(100);
mlp.trainParam.epochs = 100;
T_train = ind2vec(double(YTrain)'); 
mlp = train(mlp,XDataall(:,trainInd),T_train);

% evaluacia MLP
mlp_pred = vec2ind(mlp(XDataall(:,testInd)));  
mlp_test_acc = mean(mlp_pred' == double(YTest))*100; 

% result
fprintf('CNN test: %.2f%%, MLP test: %.2f%%, 5-fold: %.2f%%\n',...
    cnn_test_acc,mlp_test_acc,mean(accs));