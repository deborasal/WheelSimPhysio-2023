# Dataset Title: WheelSimPhysio‐2023 dataset

This is a repository that contains a multimodal dataset of Wheelchair training simulator.

# Description
This dataset comprises 58 participants data while using a wheelchair training simulator. It includes:
* performance metrics
* physiological response
* qualitative assessment

The primary purpose of this dataset is to facilitate quality of experience research around virtual training for wheelchair users.

# WIKI
For instructions on how to use dataset and install/compile/use sample analysis scripts, please see [WIKI](https://github.com/deborasal/wheelchair-simulator/wiki/WheelSimPhysio%E2%80%902023/)

# Creator
- ** Name**: Debora Salgado
- ** Affiliation**:
- ** Contact**: d.psalgado@research.ait.ie

## Keywords
Wheelchair Simulator, Physiological response, EEG, EDA,BVP,IBI, Head movements, eye-tracking

## Metholodology
Data collected using Empatica Wristband E4, OpenFace, Mindwave and simulator was developed using Unity3d platform.

## Data Quality
Quality checks include sensor calibration, data validation, and error checking. Known limitations include missing EEG data for 3 participants

## Data Format
Raw files:
- CSV files
- JSON files for metadata
  
Post-processed files:
-  CSV files
-  JSON files for metadata
-  TXT files for metadata

## Data Structure
### E4 Data 
- `ACC.csv`: Accelerometer records
- `BVP.csv`: Blood Volume Pressure records
- `EDA.csv`: Electrodermal Activity records
- `HR.csv`: Heart Rate records
- `IBI.csv`: Interbeat Interval records
- `TEMP.csv`: Temperature records
- `tags.csv`: Event mark time records
- `info.txt`: Details of csv files (metadata)
### LSL Data (LabStreamingData)
- `baseline.xdf`: EEG baseline records 
- `trial.xdf`: EEG and Simulator event marks records
### OpenFace Data 
- `Baseline.csv`: Facial Landmark and head pose and eye tracking baseline records
- `OpenFace.csv`: Facial Landmark and head pose and eye tracking trial records
- `details.txt`: summary openFace record
### OpenVibe Data 
- `Baseline.csv`: EEG baseline records
- `EEG.csv`: EEG trial records
### Unity Data 
- `Performance.csv`: Simulator Task Performance records





## Version
- **Current Version 2.0** (November 30, 2024)
- **Previous Version 1.0** (January 10, 2024)

## Access and Use Conditions
- No commercial use without permission.

## Suggested Citation

## Related Publication


