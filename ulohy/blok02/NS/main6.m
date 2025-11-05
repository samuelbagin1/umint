% Load data
load CTGdata.mat

% input
X = NDATA';
T = full(ind2vec(typ_ochorenia'));

% inicializacia
numFolds = 5;
pocet_neuronov = 35;
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
    net.divideParam.valRatio = 0;    
    net.divideParam.testRatio = 0.4;  
    
    net.trainParam.goal = 1e-5;
    net.trainParam.show = 20;
    net.trainParam.epochs = 100;
    net.trainParam.max_fail = 12;
    
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

dataTest = [NDATA(1,:); NDATA(2,:); NDATA(44,:)]'; % 2, 1, 3
outnetsim = sim(best_net, dataTest);

[~, expexted] = max(outnetsim, [], 1);