function ETtemporalpartitiondataset(n_train_window,n_test_window,col,Xdata,Ydata,S_feature,numFeatures,numResposes,num_data,window_size,flightday,ETmaps_daily)
%% Temporal Partition
% % up until traindays days, input is the window size, and output is just the
% % prediction of the required day. It is going to be a one-step prediction
partition_day = n_train_window + (window_size - 1); % remember each train/test instance has all the information of "window_size" days

pixelDataTest = [];
pixelDataTrain = [];

tempXTrain1 = [];
tempXTrain2 = [];
tempYTrain = [];

tempXTest1 = [];
tempXTest2 = [];
tempYTest = [];

for i = 1:length(Xdata)
    tempX = Xdata{i,1};
    tempY = Ydata{i,1};

    % Train data
    tempXTrain1 = [tempXTrain1, tempX(1:S_feature,1:n_train_window)];
    tempXTrain2 = [tempXTrain2, tempX(S_feature+1:end,1:n_train_window)];
    tempYTrain = [tempYTrain, tempY(1:n_train_window)];

    % Testdata
    tempXTest1 = [tempXTest1, tempX(1:S_feature,n_train_window+1:end)];
    tempXTest2 = [tempXTest2, tempX(S_feature+1:end,n_train_window+1:end)];
    tempYTest = [tempYTest, tempY(n_train_window+1:end)];

    % pixelinfo
    trPixel = [i*ones(n_train_window,1), (window_size: partition_day).']; % the first pixel of the training instance/NN input, the last pixel of training instance/NN input
    pixelDataTrain = [pixelDataTrain; trPixel];

    tsPixel = [i*ones(n_test_window,1), (partition_day + 1: (col + (window_size-1))).'];  % the last pixel/NN output
    pixelDataTest = [pixelDataTest; tsPixel];

end

dsXTr1 = arrayDatastore(tempXTrain1, IterationDimension=2);
dsXTr2 = arrayDatastore(tempXTrain2, IterationDimension=2);
dsYTr = arrayDatastore(tempYTrain, IterationDimension=2);
Traindata = combine(dsXTr1,dsXTr2,dsYTr);

dsXTs1 = arrayDatastore(tempXTest1, IterationDimension=2);
dsXTs2 = arrayDatastore(tempXTest2, IterationDimension=2);
dsYTs = arrayDatastore(tempYTest, IterationDimension=2);
TestXdata =  combine(dsXTs1,dsXTs2);
TestYdata = dsYTs;

filename_traindata = "traindata_ds_day_1_to_" + string(partition_day) + ".mat";
save(filename_traindata,'Traindata')
filename_othertraindata = "traindata_others_day_1_to_" + string(partition_day) + ".mat";
save(filename_othertraindata,'pixelDataTrain','n_train_window','numFeatures','numResposes','num_data')

filename_testdata = "testdata_ds_day_" + string(partition_day+1) + "_to_end" + ".mat";
save(filename_testdata,'TestXdata','TestYdata')
filename_othertestdata = "testdata_others_day_" + string(partition_day+1) + "_to_end" + ".mat";
save(filename_othertestdata,'pixelDataTest','n_train_window','numFeatures','numResposes','num_data','flightday','ETmaps_daily')

end