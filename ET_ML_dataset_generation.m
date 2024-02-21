clear all
close all
clc

% load spatial ET
load("ET_interpolated.mat")
% extract dates
vars = ETmaps_daily.Properties.VariableNames;
dates = datetime(vars(3:end),"InputFormat","dd-MMM-uuuu");
% load sensordata
T = readtable(".\datafiles\arable_Bill_Upper.xlsx");
% select sensordata only on the required dates
T_row_idx = find(contains(string(T.local_time),string(dates)));
% keep only the selected features
selectedvars = ["ET","ETc","NDVI",...
    "min_rh","rh_at_max_temp","rh_at_min_temp",...
    "max_temp","mean_temp","min_temp",...
    "vapor_pressure_deficit","sunshine_duration",...
    "wind_speed"];
Tvars = T.Properties.VariableNames;
idx = 1;
for j = 1:length(Tvars)
    for i = 1:length(selectedvars)
        if strcmpi(Tvars(j),selectedvars(i))
            T_col_idx(idx) = j;
            idx = idx+1;
        end
    end
end
sensordata = T{T_row_idx,T_col_idx};
sensortable = array2table(sensordata,"VariableNames",selectedvars);
% Normalize for each column
sensordata_normalized = single(normc(sensordata)); % not super happy about it but will work for now
n_feature = length(selectedvars);
ETspatial = single(ETmaps_daily{:,3:end});
n_pixels = height(ETmaps_daily);
n_days = length(dates);
% 10 days window cause that is the satellite visit interval
window_size = 10; % 10 days window
Xdata = {};
Ydata = {};
index = 1;
for i = 1:n_pixels
    temp_seq = [];
    ET_seq = [];
    ET_pixel = ETspatial(i,:); % total timeseries of that pixel
    for k = 1: n_days - window_size + 1
        start_index = k;
        end_index = start_index + window_size - 1;
        temp_S = [sensordata_normalized(start_index:end_index,:)]; % those specific rows (days) from sensordata_normalized
        % Data append structure:
        % each row in temp_S is the different arable features for a particular day. 
        % To make the time-series, we want all rows append one-after another. 
        % For example, at first, we want features 1:n of day 1. 
        % The n+1 th element should be feature 1 of day 2. 
        % The n+2 th element feature 2 of day 2 and so on...  
        temp_S = reshape(temp_S',[],1); % reshape to column vector
        temp_ET = [ET_pixel(start_index:end_index)]; % those specific days from ET_pixel
        temp_ET = reshape(temp_ET,[],1); % reshape to column vector
        temp_seq = [temp_seq, temp_S];
        ET_seq = [ET_seq, temp_ET];
    end
    actual_seq = [temp_seq;ET_seq];
    Xdata{index,1} = actual_seq(1:end-1,:); % Xtrain is everything except the last row
    Ydata{index,1} = actual_seq(end,:); % Ytrain is the last row only
    index = index + 1;
end
%% save data
save("ET_ML_dataset.mat","Xdata","Ydata","n_feature","window_size","dates","flightday")