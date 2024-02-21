clear all
close all
clc

%% collect all data
files = dir('.\datafiles\*.xlsx');
foldername = files.folder;
sensordata= {};
spatialdata = {};
for i = 1:length(files)
    filename = files(i).name;
    fullfilename = fullfile(foldername,filename);
    if contains(filename,'arable')
        opts = detectImportOptions(fullfilename);
        opts.SelectedVariableNames = {'local_time','site','ETc'};
        Ttemp = readtable(fullfilename,opts);
        sensordata{end+1} = Ttemp;
        clear Ttemp
    elseif contains(filename,'spatial')
        Ttemp = readtable(fullfilename);
        spatialdata{end+1} = Ttemp;
        vars = Ttemp.Properties.VariableNames;
        for k = 1:length(vars)
            % extract dates
            pat = digitsPattern(2) + '_' + digitsPattern(2) + '_' + digitsPattern(4);
            % check if the current column name is a date
            check_date = contains(vars{k},pat);
            if check_date
                dateinfo = extract(vars{k},pat);
                dateinfo = replace(dateinfo,'_','-');
                tempdate = datetime(dateinfo,"InputFormat","MM-dd-uuuu");
                % check if the variable named "dates" exist
                if exist('dates','var')
                    % check if the current date already exists
                    flag = find(dates == tempdate);
                    if isempty(flag)
                        dates(end+1,1) = tempdate;
                    end
                else
                    dates(1,1) = tempdate;
                end
            end
        end
        clear Ttemp
    end
end

% accumulate all the arable sensor data in one table
Tsensor = vertcat(sensordata{:});
spatialdata = spatialdata{1,1};

%% Extract the necessary data only
startdate = min(Tsensor.local_time);
enddate = max(Tsensor.local_time);
xvals = startdate:enddate;

% mark satellite image dates
spatialdates = dates;
required_satellite_dates = intersect(xvals,spatialdates);
required_dates = min(required_satellite_dates):max(required_satellite_dates);
xvals = required_dates;

% extract the specific dates
row_idx = [];
for i = 1:length(required_dates)
    row_idx = [row_idx; find(strcmpi(string(Tsensor.local_time),string(required_dates(i))))];
end
Tsensor = Tsensor(row_idx,:);

% extract the specific sensor
sensorname = "Bill_Upper";
sensor_row_idx = find(strcmpi(string(Tsensor.site),sensorname));
Tsensor = Tsensor(sensor_row_idx,:);

tempY = Tsensor.ETc;

% save
save("ETdata_POI_input.mat","Tsensor","dates","spatialdata")
%% plot

% initialize figure
figure("Units","normalized","OuterPosition",[0,0,1,1])

% plot respective arable data
nexttile
plot(xvals,tempY,'-o')
lgnd{1,1} = "Daily ETc (Arable)";
hold on
xline(spatialdates,'--k')
lgnd{1,2} = "satellite image dates";
xlabel("dates of 2023 season")
xvals_new = [];
for j = 1:3:length(xvals)
    xvals_new = [xvals_new; xvals(j)];
end
tickvals = extractBefore(string(xvals_new),"-2023");
xticks(xvals_new)
xticklabels(tickvals)
ylabel("ET (mm d^{-1})")
xlim([min(xvals)-0.5 max(xvals)+0.5])
ylim([0 10])
grid minor
legend(lgnd,'NumColumns',2)
xtickangle(90)

