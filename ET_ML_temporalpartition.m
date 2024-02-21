clear all
close all
clc

filename = "ET_ML_dataset.mat"; % selected sensor data
load(filename)

mydir = pwd;
filename = "ET_interpolated.mat";
load(fullfile(mydir,filename))

S_feature = n_feature * window_size;
ET_feature = size(Xdata{1},1) - S_feature;
numFeatures =[S_feature,ET_feature]; % depends on window size and met param for each day
numResposes = 1;
num_data = size(Xdata,1);

% Temporal Partition
[~,col] = size(Xdata{1,1});

% The partitions that I want are:
% last 3 satellite data for testing, all day before is for training
% 08/08/2023 is the first test day, so 08/07/2023 is the last trainday
n_train_window = flightday(4) - window_size; % remember each train/test instance has all the information of "window_size" days
n_test_window = col - n_train_window;
% dataset is created and saved in separate mat files inside this function
ETtemporalpartitiondataset(n_train_window,n_test_window,col,Xdata,Ydata,S_feature,numFeatures,numResposes,num_data,window_size,flightday,ETmaps_daily);
