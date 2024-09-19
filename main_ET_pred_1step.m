clear all
close all
clc

%% Load Train-Test data

% in future the loaddata can be done in a for loop, using string patterns
filename_traindata = "traindata_ds_day_1_to_30.mat";
filename_othertraindata = "traindata_others_day_1_to_30.mat";

filename_testdata = "testdata_ds_day_31_to_end.mat";
filename_othertestdata = "testdata_others_day_31_to_end.mat";

mydir = pwd; % set up the modified directory

load(fullfile(mydir,filename_traindata))
load(fullfile(mydir,filename_othertraindata))

load(fullfile(mydir,filename_testdata))
load(fullfile(mydir,filename_othertestdata))

%% NN selected architecure
% this is a "fixed" architecture 
xval = [100; 300; 400]; % row 1 = sensor; row 2 = ET; row 3 = combined; %%%%%%%%%%% best so far is [100;300;400]

% rng parameters
t = rng(10); % set your rng number

%% Define parameters
NN_param.numResponses = numResposes;
NN_param.numFeatures = numFeatures;
NN_param.miniBatchSize_train = 512; % [16 2048] power of 2
NN_param.initial_LR = 0.005; % [1e-5, 1e-1] log
NN_param.gradient_thr = 1; % [0.1 100] log
NN_param.dropput_prob = 0.2; % [0.1 0.9] linear
NN_param.maxEpochs = 25; % [10 50] linear
NN_param.miniBatchSize_test = 256; % [16 2048] power of 2
NN_param.numHiddenUnits = xval; % row 1 = sensor; row 2 = ET; row 3 = combined;

%% Model training and testing
% Train
[net,traininfo,options] = ET_pred_1step_train(NN_param,Traindata,t);
save("trained_net.mat","net","traininfo","options");

% Test
load("trained_net.mat");
[error] =  ET_pred_1step_test_kd_box(NN_param,net,TestXdata,TestYdata,pixelDataTest,pixelDataTrain,flightday,ETmaps_daily);

% errors
temperror = traininfo.TrainingRMSE;
trainrmse = temperror(end);
testrmse = error.rmse;

% save
filename_date = datestr(now, 'dd_mm_yy_HH_MM');
save_filename = "ET_ML_results_" + join(string(NN_param.numHiddenUnits(1,:))) + "_" + join(string(NN_param.numHiddenUnits(2,:))) + "_" + join(string(NN_param.numHiddenUnits(3,:))) + "_datetime_" + filename_date + ".mat";
save(save_filename,"NN_param","error","testrmse","trainrmse","t")
