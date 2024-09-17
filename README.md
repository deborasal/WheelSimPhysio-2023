# Dataset Title: WheelSimPhysio Project

This is a repository that contains:
- WheelSimPhysio-2023 Dataset: A multimodal dataset of Wheelchair training simulator.
- WheelSimAnalyser Tool: MATALAB-based tool for analysing data from the WheelSimPhysio-2023 dataset.


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
- Technological University of the Shannon Midlands Midwest - Athlone Campus, Athlone Ireland
- Federal University of Uberlândia, Faculty of Electrical Engineering, Uberlândia, Brazil
- ** Contact**: d.psalgado@research.ait.ie,a00257244@student.tus.ie or deborapsalgado@ufu.br

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
- **Version 1.0** (September 10, 2024)

## Access and Use Conditions
- No commercial use without permission.

## Suggested Citation

Here's how you can add a suggested citation for the GitHub repository:

---

## Suggested Citation

[To be added upon publication]

<!--
If you use the WheelSimPhysio-2023 dataset or WheelSimAnalyser tool in your work, please cite the following GitHub repository:

**Debora Salgado.** (2024). *WheelSimPhysio-2023 and WheelSimAnalyser: A multimodal dataset and analysis tool for wheelchair training simulations*. GitHub. Available at: [https://github.com/deborasal/WheelSimPhysio-2023](https://github.com/deborasal/WheelSimPhysio-2023)

**Citation Format (BibTeX):**
```bibtex
@misc{Salgado2024WheelSimPhysio,
  author = {Debora Salgado},
  title = {WheelSimPhysio-2023: A multimodal dataset and analysis tool for wheelchair training simulations},
  year = {2024},
  publisher = {GitHub},
  journal = {GitHub repository},
  howpublished = {\url{[https://github.com/deborasal/WheelSimPhysio-2023](https://github.com/deborasal/WheelSimPhysio-2023)}},
  version = {1.0}
}
```
-->
---

## Related Publication

The content presented in this project has been used in the following publications:

1. D. P. Salgado, S. Fallon, Y. Qiao, and E. L. M. Naves, “WheelSimPhysio-2023 dataset: Physiological and questionnaire-based dataset of immersive multisensory wheelchair simulator from 58 participants,” *Data Brief*, vol. 54, p. 110535, Jun. 2024. DOI: [10.1016/J.DIB.2024.110535](https://doi.org/10.1016/J.DIB.2024.110535)
   
2. D. P. Salgado et al., “A QoE assessment method based on EDA, heart rate and EEG of a virtual reality assistive technology system,” in *Proceedings of the 9th ACM Multimedia Systems Conference*, MMSys 2018. DOI: [10.1145/3204949.3208118](https://doi.org/10.1145/3204949.3208118)

3. D. P. Salgado, T. B. Rodrigues, F. R. Martins, E. L. M. Naves, R. Flynn, and N. Murray, “The effect of cybersickness of an immersive wheelchair simulator,” *Procedia Computer Science*, 2019. DOI: [10.1016/j.procs.2019.11.030](https://doi.org/10.1016/j.procs.2019.11.030)

4. D. P. Salgado, R. Flynn, E. L. M. Naves, and N. Murray, “The Impact of Jerk on Quality of Experience and Cybersickness in an Immersive Wheelchair Application,” *2020 12th International Conference on Quality of Multimedia Experience, QoMEX 2020*. DOI: [10.1109/QoMEX48832.2020.9123086](https://doi.org/10.1109/QoMEX48832.2020.9123086)

5. D. P. Salgado, R. Flynn, E. L. M. Naves, and N. Murray, “A questionnaire-based and physiology-inspired quality of experience evaluation of an immersive multisensory wheelchair simulator,” *MMSys 2022 - Proceedings of the 13th ACM Multimedia Systems Conference*, 2022. DOI: [10.1145/3524273.3528175](https://doi.org/10.1145/3524273.3528175)

6. D. Pereira Salgado, S. Fallon, Y. Qiao, and E. Naves, “WheelSimPhysio-2023,” vol. 2, 2024. DOI: [10.17632/Z6DFJH596R.2](https://doi.org/10.17632/Z6DFJH596R.2)

7. T. B. Rodrigues, C. O. Cathain, N. E. O. Connor, and N. Murray, “A QoE Evaluation of Haptic and Augmented Reality Gait Applications via Time and Frequency-Domain Electrodermal Activity (EDA) Analysis,” *Proceedings - 2022 IEEE International Symposium on Mixed and Augmented Reality Adjunct, ISMAR-Adjunct 2022*, 2022. DOI: [10.1109/ISMAR-ADJUNCT57072.2022.00067](https://doi.org/10.1109/ISMAR-ADJUNCT57072.2022.00067)

---

 




