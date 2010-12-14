% This will work, but if you want to test a neural network you're better
% off using nprtool (built in matlab wizard). Manually run produce_data()
% prior to data, then in nprtool get data from the file 'nndata.' 

% Trains a neural network to classify characters. The resulting network is
% saved to disk using save(). ocr_classify() will load it back to operate.
%
% Inputs: both stored in file nndata.mat (created in produce_data())
%   -data_sample_inputs: columns of data corresponding to training set
%   -data_sample_outputs: corresponding outputs of training set through target
%   function
function ocr_train()
load('nndata')
sample_inputs = data_sample_inputs;
sample_outputs = data_sample_outputs;

best_performance = 1;
for ttt=1:100

numHiddenNeurons = 10;  % Adjust as desired
net = newpr(sample_inputs,sample_outputs,numHiddenNeurons);
net.trainParam.max_fail = 100;
net.divideParam.trainRatio = 80/100;  % Adjust as desired
net.divideParam.valRatio = 20/100;  % Adjust as desired
net.divideParam.testRatio = 0/100;  % Adjust as desired

% Train and Apply Network
[net,tr] = train(net,sample_inputs,sample_outputs);
%outputs = sim(net,sample_inputs);

performance = tr.perf(end);
if performance < best_performance
    best_performance = performance;
    best_net = net;
    best_tr = tr;
    
    sprintf('Iteration %d: %f', ttt, best_performance)
    save('ocr_neural_network', 'best_net','best_tr');
end

if mod(ttt,10) == 0
    sprintf('Iteration %d: %f', ttt, best_performance)
    
end

% Plot
%plotperf(tr)
%plotconfusion(sample_outputs,outputs)

end
%compet(sim(best_net, sample_inputs(:,1)))





end