# DFUSIONET_montana
Data Fusion Using Satellite and Infield Observations for Neural-network-based prediction of spatiotemporal plant EvapoTranspiration (DFUSIONET). Implemented in Montana potato farms.

This repository contains a MATLAB script for predicting irrigation requirements using sensor and spatial data. The script preprocesses data, trains a neural network model, and makes predictions for spatial evapotranspiration (ET).

## Table of Contents
- [Usage](#usage)
- [User Inputs](#user-inputs)
- [Script Workflow](#Script Workflow)
- [Dependencies](#dependencies)
- [Publication](#Publication)
- [Contact](#contact)

## Usage

1. Clone the repository:
   ```bash
   git clone https://github.com/BMW-lab-MSU/DFUSIONET_montana/
   cd DFUSIONET_montana

2. Place the required data files in the 'datafiles' directory.

3. Open the main_ET_pred_1step.m MATLAB script and set the user inputs as needed.

4. Run the script in MATLAB.

## User Inputs
- `filename_traindata`: Filename of the input data required to train the neural network.
- `filename_othertraindata`: Filename of the other data associated with the input training data.
- `filename_testdata`: Filename of the input data required to test or evaluate the performance of the neural network.
- `filename_othertestdata`: Filename of the other data associated with the input test data.
- `xval`: Hidden layer sizes for the neural network.
- `a`: RNG array for initializing neural network predictors.
- `NN_param`: Parameters for the neural network (batch size, learning rate, dropout probability, epochs).

## Script Workflow
### POI_preprocessing.m 
input and details: all arable sensor and spatial data
output: merged sensor data table, merged spatial data table, intersection dates when both sensor and spatial data available (ETdata_POI_input.mat)
### ET_POI.m
input and details: takes the output of POI_preprocessing.m (ETdata_POI_input.mat), selects which specific Arable sensor to use as reference, performs interpolation to find daily spatial ET, throws outliers.
output: daily reference sensor's ETc, daily spatial data table, date of satellite imagery (ET_interpolated.mat)
### ET_ML_dataset_generation.m
input and details: takes the output of ET_POI.m (ET_interpolated.mat), prepares the dataset for temporal partition by slicing and merging (in a very specific order) the daily sensor data timeseries and ET timeseries for each pixel individually.
output: Xdata, Ydata (train-test unseparated), date of satellite imagery, all dates of the season, misc. (ET_ML_dataset.mat)
### ET_ML_temporalpartition.m
input and details: takes the output of ET_ML_dataset_generation.m (ET_ML_dataset.mat), calls the function ETtemporalpartitiondataset.m split train-test data and merges all pixels together in a very specific order.
output: 4 files containing training data and testing data (in datastore format).
### main_ET_pred_1step.m
input and details: takes the output of ET_ML_temporalpartition.m (2 train and 2 test files), calls the training (ET_pred_1step_train.m) and testing (ET_pred_1step_test_kd_box.m) functions for a fixed rng (for reproducibility).
output: prediction RMSE (both test and train), compare against a baseline model (LOCF: Last Observation Carried Forward). Kernel density distribution and box plot.
## Dependencies
- MATLAB R2021b or later
- Deep Learning Toolbox
## Publication
For detailed documentation, please read the paper (and cite when necessary)

F. N. Shimim et al., "Integrating Satellite Imagery and Infield Sensors for Daily Spatial Plant Evapotranspiration Prediction: A Machine Learning-Driven Approach," 2024 Intermountain Engineering, Technology and Computing (IETC), Logan, UT, USA, 2024, pp. 162-167, doi: 10.1109/IETC61393.2024.10564271.

## Contact

For any questions or issues, please contact Farshina at farshin.nazrulshimim@student.montana.edu
