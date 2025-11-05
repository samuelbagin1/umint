% Load data
load datapiscisla_all.mat


layers = [imageInputLayer([28 28 1]); % vstupná vrstva – obraz 28x28x1
convolution2dLayer(5,6); % 2D konvolúcia – 6 filtrov, rozmer 5x5
batchNormalizationLayer % dávková normalizácia
reluLayer(); % relu funkcia
maxPooling2dLayer(2,'Stride',2); % max pooling – 2x2, krok 2
convolution2dLayer(5,12); % 2D konvolúcia – 12 filtrov, rozmer 5x5
batchNormalizationLayer % dávková normalizácia
reluLayer(); % relu funkcia
maxPooling2dLayer(2,'Stride',2); % max pooling – 2x2, krok 2
fullyConnectedLayer(32); % plne prepojená vrstva – 32 neurónov
dropoutLayer(0.5); % dropout vrstva
fullyConnectedLayer(10); % plne prepojená vrstva – 10 neurónov
softmaxLayer(); % softmax aktivačná funkcia
classificationLayer()]; % klasifikačná vrstva – 10 tried

options = trainingOptions('sgdm',... % trénovací algoritmus sgdm alebo adam
'MaxEpochs',20, ... % počet trénovacích epoch
'InitialLearnRate',1e-2,... % počiat. krok učenia
'ValidationData', {XTest,YTest}, ... % použitie validačných dát
'ValidationFrequency',60, ... % pri koľkej iterácii sa vykoná validácia
'ValidationPatience' ,5, ... % automatický stop na validácii pri náraste chyby
'MiniBatchSize', 256, ... % veľkosť dávky obrazov pri trénovaní
'ExecutionEnvironment', 'gpu', ... % trénovanie na cpu alebo gpu
'Plots','training-progress'); % zobrazí sa proces trénovania v grafe

% input
X = XDataall; 
T = YDataall; 

% inicializacia
numFolds = 5;
pocet_neuronov = 100;
trainAccuracies = zeros(1, numFolds);
testAccuracies = zeros(1, numFolds);
overallAccuracies = zeros(1, numFolds);

best_net = [];
best_accuracy = 0;

% 5-fold dividerand
for fold = 1:numFolds
    fprintf('fold %d\n', fold);
    
    % net
    net = patternnet(pocet_neuronov);
    net.divideFcn = 'dividerand';
    net.divideParam.trainRatio = 0.6; 
    net.divideParam.valRatio = 0.2;    % validacia pre skorsie stopnutie
    net.divideParam.testRatio = 0.2;  
    
    net.trainParam.goal = 1e-6;
    net.trainParam.show = 20;
    net.trainParam.epochs = 100; % 200 good
    net.trainParam.max_fail = 10;
    
    % train
    [net, tr] = train(net, X, T);
    outputs = net(X);
    
    % accuracy
    [~, predicted] = max(outputs);
    [~, actual] = max(T);
    
    
    trainAcc = sum(predicted(tr.trainInd) == actual(tr.trainInd)) / numel(tr.trainInd) * 100;
    testAcc = sum(predicted(tr.testInd) == actual(tr.testInd)) / numel(tr.testInd) * 100;
    overallAcc = 100 * sum(predicted == actual) / length(predicted);
    
    trainAccuracies(fold) = trainAcc;
    testAccuracies(fold) = testAcc;
    overallAccuracies(fold) = overallAcc;
    
    % fold run confusion
    figure;
    plotconfusion(T(:, tr.testInd), outputs(:, tr.testInd));
    title(sprintf('fold %d', fold));
    fprintf(' train: %f%%, test: %f%%, overall: %f%%\n', trainAcc, testAcc, overallAcc);


     if testAcc > best_accuracy
        best_accuracy = testAcc;
        best_net = net;
        best_fold = fold;
    end
end



overall_accuracy = mean(overallAccuracies);
test_accuracy = mean(testAccuracies);
train_accuracy = mean(trainAccuracies);

fprintf('\nmean\n train: %f%%, test: %f%%, overall: %f%%\n', train_accuracy, test_accuracy, overall_accuracy);

dataTest = XDataall(:, [1, 495, 989, 1483, 1977, 2471, 2965, 3459, 3953, 4447]); % vzorky 0-9
outnetsim = sim(best_net,dataTest);

[~, expexted] = max(outnetsim, [], 1);

fprintf('\n predicted: %d', expexted-1);


%figure;
%for i = 1:10
    %subplot(1, 10, i);
    %dispznak(XDataall(:, i), 28, 28);
    %title(sprintf('sample %d: predicted %d', i, expexted(i)-1));
%end