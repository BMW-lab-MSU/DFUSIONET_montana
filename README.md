# DFUSIONET_montana
Data Fusion Using Satellite and Infield Observations for Neural-network-based prediction of spatiotemporal plant EvapoTranspiration (DFUSIONET). Implemented in Montana potato farms.

This repository contains a MATLAB script for predicting irrigation requirements using sensor and spatial data. The script preprocesses data, trains a neural network model, and makes predictions for spatial evapotranspiration (ET).

## Table of Contents
- [Usage](#usage)
- [User Inputs](#user-inputs)
- [Script Workflow](#script-workflow)
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

This repository includes MATLAB scripts for processing sensor and spatial data to estimate evapotranspiration (ET) and generate machine learning datasets. Below is an overview of each script and its workflow.

### POI_preprocessing.m
- **Input**: 
  - Arable sensor data
  - Spatial data
- **Details**:
  - Merges sensor and spatial data.
  - Identifies intersection dates when both sensor and spatial data are available.
- **Output**: 
  - `merged_sensor_data_table`
  - `merged_spatial_data_table`
  - Intersection dates (`ETdata_POI_input.mat`)

### ET_POI.m
- **Input**: 
  - Output from `POI_preprocessing.m` (`ETdata_POI_input.mat`)
- **Details**: 
  - Selects a specific Arable sensor as a reference.
  - Performs interpolation to compute daily spatial ET.
  - Detects and removes outliers.
- **Output**: 
  - Daily ETc from the reference sensor.
  - Daily spatial data table.
  - Satellite imagery dates (`ET_interpolated.mat`)

### ET_ML_dataset_generation.m
- **Input**: 
  - Output from `ET_POI.m` (`ET_interpolated.mat`)
- **Details**: 
  - Prepares the dataset for machine learning by merging and slicing daily sensor data and ET timeseries for each pixel.
- **Output**: 
  - `Xdata` and `Ydata` (combined training and testing sets)
  - Satellite imagery dates
  - All dates of the season
  - Miscellaneous (`ET_ML_dataset.mat`)

### ET_ML_temporalpartition.m
- **Input**: 
  - Output from `ET_ML_dataset_generation.m` (`ET_ML_dataset.mat`)
- **Details**: 
  - Calls `ETtemporalpartitiondataset.m` to split the dataset into training and testing sets, merging pixels in a specific order.
- **Output**: 
  - Four files containing training and testing data in datastore format.

### main_ET_pred_1step.m
- **Input**: 
  - Output from `ET_ML_temporalpartition.m` (2 training files, 2 testing files)
- **Details**: 
  - Calls the training script (`ET_pred_1step_train.m`) and testing script (`ET_pred_1step_test_kd_box.m`) using a fixed random number generator for reproducibility.
- **Output**: 
  - Prediction RMSE (for both training and testing sets)
  - Comparison against a baseline model (Last Observation Carried Forward, LOCF)
  - Kernel density distribution and box plot for model evaluation


## Dependencies
- MATLAB R2021b or later
- Deep Learning Toolbox
## Publication
For detailed documentation, please read the paper (and cite when necessary)

F. N. Shimim et al., "Integrating Satellite Imagery and Infield Sensors for Daily Spatial Plant Evapotranspiration Prediction: A Machine Learning-Driven Approach," 2024 Intermountain Engineering, Technology and Computing (IETC), Logan, UT, USA, 2024, pp. 162-167, doi: 10.1109/IETC61393.2024.10564271.

## Contact

For any questions or issues, please contact Farshina at farshin.nazrulshimim@student.montana.edu
