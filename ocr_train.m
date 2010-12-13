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

numHiddenNeurons = 20;  % Adjust as desired
net = newpr(sample_inputs,sample_outputs,numHiddenNeurons);
net.divideParam.trainRatio = 70/100;  % Adjust as desired
net.divideParam.valRatio = 15/100;  % Adjust as desired
net.divideParam.testRatio = 15/100;  % Adjust as desired

% Train and Apply Network
[net,tr] = train(net,sample_inputs,sample_outputs);
outputs = sim(net,sample_inputs);

% Plot
plotperf(tr)
plotconfusion(sample_outputs,outputs)

save('ocr_neural_network', 'net');



end