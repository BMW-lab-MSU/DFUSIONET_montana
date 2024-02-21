POI_preprocessing.m 

input and details: all arable sensor and spatial data
output: merged sensor data table, merged spatial data table, intersection dates when both sensor and spatial data available (ETdata_POI_input.mat)


ET_POI.m

input and details: takes the output of POI_preprocessing.m (ETdata_POI_input.mat), selects which specific Arable sensor to use as reference, performs interpolation to find daily spatial ET, throws outliers.
output: daily reference sensor's ETc, daily spatial data table, date of satellite imagery (ET_interpolated.mat)


ET_ML_dataset_generation.m

input and details: takes the output of ET_POI.m (ET_interpolated.mat), prepares the dataset for temporal partition by slicing and merging (in a very specific order) the daily sensor data timeseries and ET timeseries for each pixel individually.
output: Xdata, Ydata (train-test unseparated), date of satellite imagery, all dates of the season, misc. (ET_ML_dataset.mat)


ET_ML_temporalpartition.m

input and details: takes the output of ET_ML_dataset_generation.m (ET_ML_dataset.mat), calls the function ETtemporalpartitiondataset.m split train-test data and merges all pixels together in a very specific order.
output: 4 files containing training data and testing data (in datastore format).


main_ET_pred_1step.m

input and details: takes the output of ET_ML_temporalpartition.m (2 train and 2 test files), calls the training (ET_pred_1step_train.m) and testing (ET_pred_1step_test_kd_box.m) functions for a fixed rng (for reproducibility).
output: prediction RMSE (both test and train), compare against a baseline model (LOCF: Last Observation Carried Forward). Kernel density distribution and box plot.