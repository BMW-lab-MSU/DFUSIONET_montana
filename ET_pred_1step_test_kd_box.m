function [error] = ET_pred_1step_test_kd_box(NN_param,net,TestXdata,TestYdata,pixelDataTest,pixelDataTrain,flightday,ETmaps_daily)
%% Test
miniBatchSize_test = NN_param.miniBatchSize_test;
% predict for test dataset
YPred = predict(net,TestXdata,'MiniBatchSize',miniBatchSize_test);

% grab actual values
parpool('Processes')
Yactual = cell2mat(readall(TestYdata,UseParallel=true));
poolobj = gcp('nocreate');
delete(poolobj);

% test day of all flights for spatial comparison
testdays = unique(pixelDataTest(:,2));
testflightdays = intersect(flightday,testdays);

% extract spatiotemporal ET information (interpolated only)
ETmaps_vals = ETmaps_daily{:,3:end};
dates = ETmaps_daily.Properties.VariableNames(3:end);
npixels = height(ETmaps_vals);

% implement baseline model ("sample and hold" per pixel in timeseries)
ET_baseline = zeros(size(ETmaps_vals));
for i = 1:length(flightday) - 1
    if i ==1
        numdays = flightday(i) : flightday(i+1);
    else
        numdays = flightday(i) + 1 : flightday(i+1);
    end
    ET_baseline(:,numdays) = ETmaps_vals(:,flightday(i)).* ones(npixels,length(numdays));
end

% extract row_idx of the test flight days
for i = 1:length(testflightdays)
    % grab only the pixels for a specific day based on pixelDataTest
    pixel_idx = find(pixelDataTest(:,2) == testflightdays(i));

    % append all the pixels for a single into a column vector
    Yactual_vals(:,i) = Yactual(pixel_idx);
    Ypred_vals(:,i) = YPred(pixel_idx);

    % get baseline model generated values
    Ybaseline_vals(:,i) = ET_baseline(:,testflightdays(i));

end

[bs_rmse,ML_rmse] = kd_box(NN_param,Yactual_vals,Ybaseline_vals,Ypred_vals,ETmaps_daily,testflightdays);
error.bs_rmse = bs_rmse;
error.rmse = ML_rmse;
end

% spatial plot
function [bs_rmse,ML_rmse] = kd_box(NN_param,Yactual_vals,Ybaseline_vals,Ypred_vals,ETmaps_daily_Bill,testflightdays)
numHiddenUnits = NN_param.numHiddenUnits;
dates = ETmaps_daily_Bill.Properties.VariableNames(3:end);
npixels = height(ETmaps_daily_Bill);

% init RMSE
bs_rmse = [];
ML_rmse = [];

% performance plots
figure('units','inches','OuterPosition',[0 0 8 4]) %[left bottom width height]
tiledlayout(2,length(testflightdays))

for i = 1:length(testflightdays)
% spatial plot per day
Yactual_vals_1day = Yactual_vals(:,i);
Ybaseline_vals_1day = Ybaseline_vals(:,i);
Ypred_vals_1day = Ypred_vals(:,i);
currentdate = dates{testflightdays(i)};

% get RMSE
temp_bs_rmse = sqrt(mean((Yactual_vals_1day - Ybaseline_vals_1day).^2,"all"));
temp_ML_rmse = sqrt(mean((Yactual_vals_1day - Ypred_vals_1day).^2,"all"));
bs_rmse = [bs_rmse; temp_bs_rmse];
ML_rmse = [ML_rmse; temp_ML_rmse];

% ksdensity (probability density estimate by kernel smoothing) of  of all 3 images
pts = linspace(-.5,10.5,(length(Yactual_vals_1day)*10));
[Yactual_pd,x_actual_pd] = ksdensity(Yactual_vals_1day,pts,'Support','positive','BoundaryCorrection','reflection');
[Ybaseline_pd,x_baseline_pd] = ksdensity(Ybaseline_vals_1day,pts,'Support','positive','BoundaryCorrection','reflection');
[Ypred_pd,x_pred_pd] = ksdensity(Ypred_vals_1day,pts,'Support','positive','BoundaryCorrection','reflection');

nexttile
plot(x_actual_pd,Yactual_pd,'Color',[0 0.4470 0.7410],'LineWidth',2);
hold on
plot(x_baseline_pd,Ybaseline_pd,'Color',[0.4660 0.6740 0.1880],'LineStyle','--','LineWidth',2)
hold on
plot(x_pred_pd,Ypred_pd,'Color',[0.6350 0.0780 0.1840],'LineStyle',':','LineWidth',2)
% legend(["Actual", "baseline", "ML"],'NumColumns',3,'Location','northeast')
hold off
xlim([-0.5 10]); ylim([0 0.5])
xlabel("ET (mm d^{-1})"); ylabel("PDF"); 
grid minor
title(string(currentdate))
end

leg = legend(["Actual", "LOCF", "DFUSIONET"],'Orientation', 'Horizontal','NumColumns',1);
leg.Layout.Tile = 'west';

for i = 1:length(testflightdays)
% spatial plot per day
Yactual_vals_1day = Yactual_vals(:,i);
Ybaseline_vals_1day = Ybaseline_vals(:,i);
Ypred_vals_1day = Ypred_vals(:,i);
currentdate = dates{testflightdays(i)};

% boxplot of all 3 images
nexttile
bplot_x = [nonzeros(Yactual_vals_1day);nonzeros(Ybaseline_vals_1day);nonzeros(Ypred_vals_1day)];
bplot_g = [repmat({'Actual'},nnz(Yactual_vals_1day),1); repmat({'LOCF'},nnz(Ybaseline_vals_1day),1); repmat({'DFUSIONET'},nnz(Ypred_vals_1day),1)];
boxplot(bplot_x,bplot_g)
ylim([0 10])
ylabel("ET (mm d^{-1})");
xtickangle(45)
grid minor
end


%saveplot
filename_date = datestr(now, 'dd_mm_yy_HH_MM');
filename = "kd_pdf_boxplot_" + join(string(numHiddenUnits(1,:))) + "_" + join(string(numHiddenUnits(2,:))) + "_" + join(string(numHiddenUnits(3,:))) + "_datetime_" + filename_date;
saveas(gcf,[filename + ".png"])
savefig(filename)
% close(gcf)
end
