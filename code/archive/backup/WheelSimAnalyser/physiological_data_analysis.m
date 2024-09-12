%% Desktop Simulator Data Analysis
%
clc;
clear;
close all;
%% Step 1 - Reading Empatica E4 data
%
%
addpath('/Users/deborasalgado/Documents/GitHub/WheelSimPhysio-2023/scripts/WheelSimAnalyzer/functions-versions/');
user_ID=1;
e4_path_file=sprintf('/Users/deborasalgado/Documents/GitHub/WheelSimPhysio-2023/dataset/experiment-1-monitor/monitor-%d/physiological-data/e4/',user_ID);
% cd(e4_path_file);


%%
%Empatica files
BVP_filename='BVP.csv';
EDA_filename='EDA.csv';
HR_filename='HR.csv';
tags_filename='tags.csv';
IBI_filename='IBI.csv';

%% Step 1.2 - Reading BVP data:

BVP_file_path=strcat(e4_path_file,BVP_filename);
BVP_timetable = readingBVP(BVP_file_path,user_ID);


%% Step 1.3 - Reading IBI data:


IBI_file_path=strcat(e4_path_file,IBI_filename);
IBI_timetable=readingIBI(IBI_file_path,user_ID);

% Analysing IBI - HRV
 
% Transforming the signal with FFT of the HRV: The signal divided into
% three intervals:
% VLF - 0-0.4Hz
% LF - 0.04-0.15Hz
% HF- 0.15-0.4 Hz

%% Step 1.4 - Reading HR data:
HR_file_path=strcat(e4_path_file,HR_filename);
HR_timetable=readingHR(HR_file_path,user_ID);

%% Step 1.5 - Reading EDA data:
EDA_file_path=strcat(e4_path_file,EDA_filename);
EDA_timetable=readingEDA(EDA_file_path,user_ID);


%% Step 1.6 - Tags data as:
% 1- Start Baseline
% 2 - End Baseline
% 3- Start Test
% 4 - End Test
% 0 - NA
tags_file_path=strcat(e4_path_file,tags_filename);
tags_timetable=readingTags(tags_file_path,user_ID);
start_test=table2array(tags_timetable(1,2))+hours(1);
end_test=table2array(tags_timetable(1,3)) +hours(1);
test_range=timerange(start_test,end_test);

%% 2. Filtering EDA and IBI timetables:

IBI_timetable=IBI_timetable(test_range,:);
EDA_timetable=EDA_timetable(test_range,:);
 
%% 3. Extracting IBI and EDA features:

[IBI_Features,HR_Features]=extractingIBIFeatures(IBI_timetable); 

%Mean IBI, SDNN, RMSSD, NN50, pNN50
%Mean HR, Max HR, Min HR, HR range, STD HR

% ----------------------
 EDA_Features = extractSCRmetrics(EDA_timetable);
 
%
% Determining all the peaks and valleys with the threshold 0.05 as valid
% [scrAmplitude, scrFrequency, scrCount, meanSCL , stdSCL]

% % Synchronize the tables:
% E4_timetable=synchronize(IBI_timetable,EDA_timetable,'union','linear');
% E4_timetable=E4_timetable(test_range,:);




%% Filtering E4 data:




%% Step 2 - Reading OpenFace Data
%[Eye_Head_timetable]=readingOpenFace(openFace_path_file);
 
%  Load OpenFace eye-gaze data
% Assuming data is loaded in two vectors: gazeX and gazeY
 
% Parameters
% saccade_velocity_threshold = 30; % degrees per second, adjust as needed
% sampling_rate = 60; % Hz, adjust based on your data's sampling rate
% 
% % Calculate gaze direction changes
% gaze_direction_changes = sqrt(diff(gazeX).^2 + diff(gazeY).^2);
% 
% % Convert to angular velocity (degrees per second)
% gaze_angular_velocity = rad2deg(gaze_direction_changes) * sampling_rate;
% 
% % Identify saccades
% saccades = gaze_angular_velocity > saccade_velocity_threshold;
% 
% % Calculate saccade rate
% saccade_rate = sum(saccades) / (length(gazeX) / sampling_rate);
% 
% % Calculate saccade amplitude (example, simplified)
% saccade_amplitudes = gaze_direction_changes(saccades);
% average_saccade_amplitude = mean(saccade_amplitudes);
% 
% % Display results
% fprintf('Saccade Rate: %f saccades per second\n', saccade_rate);
% fprintf('Average Saccade Amplitude: %f degrees\n', average_saccade_amplitude);



%% Step 3 - Reading EEG Data - Attention Levels
% OpenVibe Codes:
% 1081 - Eye_Blink
% 32769 - Experiment_Start
% 32773 - Trial Start
% 898 - Incorrect - Collisions
% 32774 - Trial Stop

%[EEG_timetable]=readingEEG(eeg_path_filename);

%% Step 4 - Reading Blink Data - Blink Rate features


%% Step 5 - Reading Performance Data - Simulator Performance Report

%% Step 6 - Reading Cognitive Load Data - NASA-TLX

%% Step 7 - Reading Emotion Assessment - SAM
