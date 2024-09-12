%% WheelSimAnalyzer
% This MATLAB Live Script is designed to analyze and visualize data from two different experiments:
% - Experiment 1: Monitor-based experiment
% - Experiment 2: VR-based experiment
%
% Author: Debora P.S.
% Date: 22 Jul 2024
% Version: 1.0
% MATLAB Version: 2024.a

% Clear the command window to remove any previous outputs
clc;
% Clear all variables from the workspace to avoid conflicts with existing variables
clear;
% Close all figure windows to start with a clean slate
close all;

%% 1. Setup and Directory Selection

% Prompt the user to select the root directory for the experiments
% uigetdir opens a dialog box for the user to choose a directory
rootDir = uigetdir('', 'Select Root Directory');

% Verify that a directory was selected
% If the user cancels the selection, uigetdir returns 0
if rootDir == 0
    error('No directory selected.');
end

% Display the path of the selected root directory
% This provides feedback to the user about their selection
disp(['Selected directory: ', rootDir]);

% Define paths for specific experiment subdirectories within the root directory
% These paths are constructed using the root directory and specific subdirectory names
experiment1Dir = fullfile(rootDir, 'experiment-1-monitor');
experiment2Dir = fullfile(rootDir, 'experiment-2-vr');

% Define the path for the directory where processed tables will be stored
% Construct the path using the root directory and a specific folder name
processedTablesDir = fullfile(rootDir, 'processed-tables');

% Check if the 'processed-tables' directory exists
% If it does not exist, create it
if ~isfolder(processedTablesDir)
    mkdir(processedTablesDir);
end

%% 2. Data Loading and Processing

% Initialize the physiologicalData structure
physiologicalData = struct();
questionnaireData = struct();
systemData = struct();

% Function to create a valid field name
function validFieldName = makeValidFieldName(name)
    validFieldName = matlab.lang.makeValidName(name);
end

% Function to recursively process files in a directory and save their paths to a structure
%
% This function scans a directory for files, processes each file based on its extension,
% and saves the file paths to a nested structure. It also recursively processes subdirectories.
%
% Inputs:
%   - directoryPath: The path to the directory to be processed.
%   - data: The structure where the file paths will be stored.
%   - experiment: The name of the experiment for organizing data.
%   - participantId: The unique identifier for the participant.
%   - dataType: The type of data being processed (used for organizing).
%   - dataTypeField: The specific field within the dataType for storing file paths (can be empty).
%
% Outputs:
%   - data: The updated structure containing the paths of the processed files.
function data = processDirectory(directoryPath, data, experiment, participantId, dataType, dataTypeField)
    % Get all items (files and directories) in the specified directory
    items = dir(fullfile(directoryPath, '*'));
    % Filter out directories, keeping only files
    items = items(~[items.isdir]);

    % Convert experiment and participant ID to valid field names for the structure
    experimentField = makeValidFieldName(experiment);
    participantField = makeValidFieldName(participantId);

    % Initialize the structure fields if they do not exist
    if ~isfield(data, experimentField)
        data.(experimentField) = struct();
    end
    if ~isfield(data.(experimentField), participantField)
        data.(experimentField).(participantField) = struct();
    end
    
    % Handle the case where dataTypeField is empty (e.g., for questionnaire-data)
    if isempty(dataTypeField)
        dataTypeField = makeValidFieldName(dataType);
    end
    
    % Initialize the dataTypeField if it does not exist
    if ~isfield(data.(experimentField).(participantField), dataTypeField)
        data.(experimentField).(participantField).(dataTypeField) = struct();
    end
    
    % Loop through each item in the directory
    for k = 1:numel(items)
        % Get the full path to the current file
        filePath = fullfile(directoryPath, items(k).name);
        disp(['Found file: ', filePath]);

        % Convert the file name to a valid field name
        fileFieldName = makeValidFieldName(items(k).name);
        
        % Get the file extension
        [~, ~, ext] = fileparts(items(k).name);
        
        % Process the file based on its extension
        switch ext
            case '.csv'
                % For CSV files, save the file path to the structure
                data.(experimentField).(participantField).(dataTypeField).(fileFieldName) = filePath;
                disp(['Saved file path for CSV file: ', items(k).name]);
            case '.xdf'
                % For XDF files, save the file path to the structure
                disp(['Processing XDF file: ', items(k).name]);
                data.(experimentField).(participantField).(dataTypeField).(fileFieldName) = filePath;
            case '.txt'
                % For TXT files, save the file path to the structure
                disp(['Processing .txt file: ', items(k).name]);
                data.(experimentField).(participantField).(dataTypeField).(fileFieldName) = filePath;
            case '.xlsx'
               % For XLSX files, save the file path to the structure
               disp(['Processing .xlsx file: ', items(k).name]);
               data.(experimentField).(participantField).(dataTypeField).(fileFieldName) = filePath;
        end
    end

    % Get all subdirectories in the current directory
    subdirs = dir(fullfile(directoryPath, '*'));
    subdirs = subdirs([subdirs.isdir] & ~ismember({subdirs.name}, {'.', '..'}));

    % Recursively process each subdirectory
    for k = 1:numel(subdirs)
        % Get the full path to the subdirectory
        subdirPath = fullfile(directoryPath, subdirs(k).name);
        disp(['Entering directory: ', subdirPath]);
        % Recursive call to processDirectory for the subdirectory
        data = processDirectory(subdirPath, data, experiment, participantId, dataType, subdirs(k).name);
    end
end

% Function to process physiological data for each participant
% This function iterates through specific subfolders within the participant's data directory
% and processes each one by calling the processDirectory function.
%
% Inputs:
%   - participantFolder: The path to the participant's main data folder.
%   - physiologicalData: The structure to store the processed physiological data.
%   - experiment: The name of the experiment being processed.
%   - participantId: The unique identifier for the participant.
%
% Outputs:
%   - physiologicalData: The updated structure containing processed data.
function physiologicalData = processPhysiologicalData(participantFolder, physiologicalData, experiment, participantId)
    % List of subfolders to process within the 'physiological-data' directory
    subfolders = {'e4', 'LSL', 'OpenFace', 'OpenVibe'};
    
    % Loop through each subfolder specified in the list
    for k = 1:numel(subfolders)
        % Construct the full path to the current subfolder
        subfolderPath = fullfile(participantFolder, 'physiological-data', subfolders{k});
        
        % Check if the current subfolder exists
        if isfolder(subfolderPath)
            % Display the path of the folder being processed
            disp(['Processing folder: ', subfolderPath]);
            
            % Call the processDirectory function to process the files in the subfolder
            % This function will update the physiologicalData structure with paths and details
            physiologicalData = processDirectory(subfolderPath, physiologicalData, experiment, participantId, 'physiological-data', subfolders{k});
        end
    end
end

% Function to process questionnaire data for each participant
%
% This function processes the questionnaire data for a given participant by calling the 
% processDirectory function. It looks for the 'questionnaire-data' subfolder within 
% the participant's folder and updates the questionnaireData structure with paths to 
% relevant files.
%
% Inputs:
%   - participantFolder: The path to the participant's main folder.
%   - questionnaireData: The structure where the questionnaire data paths will be stored.
%   - experiment: The name of the experiment being processed.
%   - participantId: The unique identifier for the participant.
%
% Outputs:
%   - questionnaireData: The updated structure containing the paths of the processed 
%     questionnaire files.
function questionnaireData = processQuestionnaireData(participantFolder, questionnaireData, experiment, participantId)
    % Construct the path to the 'questionnaire-data' subfolder within the participant's folder
    questionnaireFolderPath = fullfile(participantFolder, 'questionnaire-data');
    
    % Check if the 'questionnaire-data' subfolder exists
    if isfolder(questionnaireFolderPath)
        % Display the path of the folder being processed
        disp(['Processing questionnaire folder: ', questionnaireFolderPath]);
        
        % Call the processDirectory function to process the files in the 'questionnaire-data' subfolder
        % Pass an empty string for the dataTypeField since it's not used for questionnaire data
        questionnaireData = processDirectory(questionnaireFolderPath, questionnaireData, experiment, participantId, 'questionnaire-data', '');
    end
end

% Function to process system data for each participant
%
% This function processes system data for a given participant by scanning specific subfolders
% within the 'system-data' directory. It calls the processDirectory function to handle 
% each subfolder and update the systemData structure with file paths.
%
% Inputs:
%   - participantFolder: The path to the participant's main folder.
%   - systemData: The structure where the system data paths will be stored.
%   - experiment: The name of the experiment being processed.
%   - participantId: The unique identifier for the participant.
%
% Outputs:
%   - systemData: The updated structure containing the paths of the processed system files.
function systemData = processSystemData(participantFolder, systemData, experiment, participantId)
    % Define subfolders within the 'system-data' directory to process
    subfolders = {'Unity'};
    
    % Loop through each subfolder specified in the list
    for k = 1:numel(subfolders)
        % Construct the path to the current subfolder within 'system-data'
        subfolderPath = fullfile(participantFolder, 'system-data', subfolders{k});
        
        % Check if the current subfolder exists
        if isfolder(subfolderPath)
            % Display the path of the folder being processed
            disp(['Processing folder: ', subfolderPath]);
            
            % Call the processDirectory function to process the files in the subfolder
            % The field name for system data is set to the name of the subfolder
            systemData = processDirectory(subfolderPath, systemData, experiment, participantId, 'system-data', subfolders{k});
        end
    end
end

%% 2.1 Processing the Experiment 1 Group Folder

% Initialize data structures
physiologicalData = struct();
questionnaireData = struct();
systemData = struct();

% Loop through each participant in Experiment 1 (24 participants)
for i = 1:24
    % Construct the path to the participant's folder
    % Participant folders are named 'monitor-1', 'monitor-2', ..., 'monitor-24'
    participantFolder = fullfile(experiment1Dir, ['monitor-', num2str(i)]);
    % Construct the participant ID
    participantId = ['monitor-', num2str(i)];
    
    % Check if the participant's folder exists
    if isfolder(participantFolder)
        % Display a message indicating the folder being processed
        disp(['Processing participant: ', participantFolder]);
        
        % Process physiological data for the current participant
        % Calls the processPhysiologicalData function to update the physiologicalData structure
        physiologicalData = processPhysiologicalData(participantFolder, physiologicalData, 'experiment1', participantId);
        
        % Process questionnaire data for the current participant
        % Calls the processQuestionnaireData function to update the questionnaireData structure
        questionnaireData = processQuestionnaireData(participantFolder, questionnaireData, 'experiment1', participantId);

        % Process system data for the current participant
        % Calls the processSystemData function to update the systemData structure
        systemData = processSystemData(participantFolder, systemData, 'experiment1', participantId);
    end
end

%% 2.2 Processing each participant in Experiment 2

% Define the groups and corresponding IDs and participant counts for Experiment 2
vrGroups = {'vr-high-jerk', 'vr-low-jerk'};
vrGroupsID = {'vr-highjerk', 'vr-lowjerk'};
vrCounts = [18, 16];  % Number of participants in each group

% Loop through each group in Experiment 2
for g = 1:numel(vrGroups)
    % Construct the path to the group's folder
    groupFolder = fullfile(experiment2Dir, vrGroups{g});
    
    % Display a message indicating the group folder being checked
    disp(['Checking group folder: ', groupFolder]);
    
    % Check if the group folder exists
    if isfolder(groupFolder)
        % Display a message indicating the group folder being processed
        disp(['Processing group folder: ', groupFolder]);
        
        % Loop through each participant in the current group
        for i = 1:vrCounts(g)
            % Construct the participant ID
            participantId = sprintf('%s-%d', vrGroupsID{g}, i);
            % Construct the path to the participant's folder
            participantFolder = fullfile(groupFolder, participantId);
            
            % Display a message indicating the constructed participant folder path
            disp(['Constructed participant folder path: ', participantFolder]);
            
            % Check if the participant's folder exists
            if isfolder(participantFolder)
                % Display a message indicating the participant being processed
                disp(['Processing participant: ', participantFolder]);
                
                % Process physiological data for the current participant
                physiologicalData = processPhysiologicalData(participantFolder, physiologicalData, 'experiment2', participantId);
                
                % Process questionnaire data for the current participant
                questionnaireData = processQuestionnaireData(participantFolder, questionnaireData, 'experiment2', participantId);
                
                % Process system data for the current participant
                systemData = processSystemData(participantFolder, systemData, 'experiment2', participantId);
            else
                % Display a message if the participant folder is not found
                disp(['Participant folder not found: ', participantFolder]);
            end
        end
    else
        % Display a message if the group folder is not found
        disp(['Group folder not found: ', groupFolder]);
    end
end

%% 3. Feature Extraction - Data Analysis for:
%
%  - Physiological Data - E4 wristband physiological metrics:
%    a. Heart Rate (HR)
%    b. Inter Beat Interval (IBI)
%    c. Electrodermal Activity (EDA) or Skin Conductance Response (SCR)
%
% - Questionnaire Data - Post-Experience Questionnaire:
%    a. Usability (SUS)
%    b. Emotion (Self-Assessment Manikin SAM)
%    c. Immersion (IQP)
%    d. Cognitive Task Load (NASA-TLX)
%
% - System Data - User performance metrics captured via a training simulator platform designed in Unity:
%    a. Number of Collisions
%    b. Number of Commands
%    c. Total Time of the Task
%

% Define the path to the functions
% Get the full path to the current script
scriptPath = mfilename('fullpath');

% Navigate up to the project root by going up three directory levels
projectRoot = fileparts(fileparts(fileparts(scriptPath)));

% Construct the path to the folder containing the required functions
functionsPath = fullfile(projectRoot, 'scripts', 'WheelSimAnalyzer');

% Add the functions folder to MATLAB's search path
addpath(functionsPath);


% Helper function to get the file path matching a pattern
% This function searches for a file name in the participantData structure 
% that matches the provided pattern and returns the corresponding file path.
function filePath = getFilePath(participantData, filePattern)
    % Get all field names from the participantData structure
    fileNames = fieldnames(participantData);
    % Initialize the filePath as an empty string
    filePath = '';
    % Loop through each field name
    for i = 1:numel(fileNames)
        % Check if the current field name contains the specified pattern
        if contains(fileNames{i}, filePattern)
            % If a match is found, set filePath to the corresponding value and exit loop
            filePath = participantData.(fileNames{i});
            break;
        end
    end
end

% Function to calculate differences between two feature structures
% This function computes the differences between corresponding fields in 
% the test_features and baseline_features structures and returns a new 
% structure with the differences.
function feature_diffs = calculateFeatureDifferences(test_features, baseline_features)
    % Extract field names from the test_features structure
    fields = fieldnames(test_features);
    
    % Initialize a new structure to store the differences
    feature_diffs = struct();
    
    % Iterate over each field in the structures
    for i = 1:numel(fields)
        field = fields{i};
        % Check if the field exists in both test_features and baseline_features
        if isfield(test_features, field) && isfield(baseline_features, field)
            % Get the values from both structures for the current field
            test_value = test_features.(field);
            baseline_value = baseline_features.(field);
            % Special handling for 'participantID' and 'experimentID' fields
            if strcmp(field, 'participantID') || strcmp(field, 'experimentID')
                % Keep the values unchanged for these fields
                feature_diffs.(field) = test_value;
            elseif isnumeric(test_value) && isnumeric(baseline_value)
                % Calculate the difference for numeric fields, handling NaNs
                feature_diffs.(field) = test_value - baseline_value;
            else
                % For non-numeric or missing fields, set the difference to NaN
                feature_diffs.(field) = NaN;
            end
        else
            % If the field is missing in either structure, set the difference to NaN
            feature_diffs.(field) = NaN;
        end
    end
end

% Function ANALYZEPHYSIOLOGICALDATA Processes and analyzes physiological data for a given participant.
    % 
    % INPUTS:
    %   physiologicalData - A structure containing physiological data for multiple participants and experiments.
    %                       It should include fields for each experiment and participant, with further details for devices.
    %   experiment        - A string specifying the experiment identifier within physiologicalData.
    %   participant       - A string specifying the participant identifier within the experiment.
    %   processedTablesDir - A string specifying the directory path where processed tables will be saved.
    % 
    % OUTPUTS:
    %   Saves a .mat file in the specified directory containing:
    %     - Test_PhysiologicalFeatures_struct: Struct with extracted features from the test period.
    %     - Baseline_PhysiologicalFeatures_struct: Struct with extracted features from the baseline period.
    %     - Difference_PhysiologicalFeatures_struct: Struct with differences between test and baseline features.
    %     - synchronizedTestTable: Timetable with synchronized data for the test period.
    %     - synchronizedBaselineTable: Timetable with synchronized data for the baseline period.
    % 
    % FUNCTIONALITY:
    % 1. Retrieves the physiological data for the specified participant and experiment.
    % 2. Reads and processes various physiological data files (BVP, IBI, HR, EDA).
    % 3. Extracts and synchronizes features for the test and baseline periods.
    % 4. Calculates differences in features between test and baseline periods.
    % 5. Saves the processed data and features into a .mat file in the specified directory.
    % 6. Displays debug messages to indicate progress and paths of processed files.
    % 7. Includes placeholders for future integration with OpenFace and OpenVibe data.
function analyzePhysiologicalData(physiologicalData, experiment, participant, processedTablesDir)
    disp(['Processing data for ', experiment, ' - ', participant]); % Debug statement
    
    % Retrieve participant data
    if isfield(physiologicalData, makeValidFieldName(experiment)) && ...
       isfield(physiologicalData.(makeValidFieldName(experiment)), makeValidFieldName(participant)) && ...
       isfield(physiologicalData.(makeValidFieldName(experiment)).(makeValidFieldName(participant)), 'e4')
       
        participantData = physiologicalData.(makeValidFieldName(experiment)).(makeValidFieldName(participant)).e4;
        
        % Debug: Print available files
        disp('Available files:');
        disp(participantData);

        % Initialize empty timetables
        IBI_timetable = [];
        HR_timetable = [];
        EDA_timetable = [];

        % Check for BVP data
        if isfield(participantData, 'BVP_csv')
            BVP_file_path = participantData.BVP_csv;
            disp(['BVP file path: ', BVP_file_path]); % Debug statement
            BVP_timetable = readingBVP(BVP_file_path, participant);
        end

        % Check for IBI data
        if isfield(participantData, 'IBI_csv')
            IBI_file_path = participantData.IBI_csv;
            disp(['IBI file path: ', IBI_file_path]); % Debug statement
            IBI_timetable = readingIBI(IBI_file_path, participant);
        end

        % Check for HR data
        if isfield(participantData, 'HR_csv')
            HR_file_path = participantData.HR_csv;
            disp(['HR file path: ', HR_file_path]); % Debug statement
            HR_timetable = readingHR(HR_file_path, participant);
        end

        % Check for EDA data
        if isfield(participantData, 'EDA_csv')
            EDA_file_path = participantData.EDA_csv;
            disp(['EDA file path: ', EDA_file_path]); % Debug statement
            EDA_timetable = readingEDA(EDA_file_path, participant);
        end

         % Check for Tags data
        if isfield(participantData, 'tags_csv')
            tags_file_path = participantData.tags_csv;
            disp(['Tags file path: ', tags_file_path]); % Debug statement
            tags_timetable = readingTags(tags_file_path, participant);
            
            % Ensure tags_timetable is not empty and contains necessary columns
            if ~isempty(tags_timetable) && width(tags_timetable) >= 4
                start_test = table2array(tags_timetable(1, 2)) + hours(1);
                end_test = table2array(tags_timetable(1, 3)) + hours(1);
                start_baseline = table2array(tags_timetable(1, 4)) + hours(1);
                end_baseline = table2array(tags_timetable(1, 5)) + hours(1);
              
                test_range = timerange(start_test, end_test);
                baseline_range = timerange(start_baseline, end_baseline);

                
             % Synchronize and trim timetables
             if ~isempty(IBI_timetable)
                    IBI_timetable = sortrows(IBI_timetable, 'Time'); % Sort the timetables by time
                    IBI_test_timetable = IBI_timetable(test_range, :);
                    IBI_baseline_timetable = IBI_timetable(baseline_range, :);
             end
             if ~isempty(EDA_timetable)
                    EDA_timetable = sortrows(EDA_timetable, 'Time');
                    EDA_test_timetable = EDA_timetable(test_range, :);
                    EDA_baseline_timetable = EDA_timetable(baseline_range, :);
             end
             if ~isempty(HR_timetable)
                    HR_timetable = sortrows(HR_timetable, 'Time');
                    HR_test_timetable = HR_timetable(test_range, :);
                    HR_baseline_timetable = HR_timetable(baseline_range, :);
             end
                % Debug: Display time ranges of the test and baseline periods
                disp('IBI_test_timetable Time Range:');
                disp([min(IBI_test_timetable.Time), max(IBI_test_timetable.Time)]);
                disp('HR_test_timetable Time Range:');
                disp([min(HR_test_timetable.Time), max(HR_test_timetable.Time)]);
                disp('EDA_test_timetable Time Range:');
                disp([min(EDA_test_timetable.Time), max(EDA_test_timetable.Time)]);

                disp('IBI_baseline_timetable Time Range:');
                disp([min(IBI_baseline_timetable.Time), max(IBI_baseline_timetable.Time)]);
                disp('HR_baseline_timetable Time Range:');
                disp([min(HR_baseline_timetable.Time), max(HR_baseline_timetable.Time)]);
                disp('EDA_baseline_timetable Time Range:');
                disp([min(EDA_baseline_timetable.Time), max(EDA_baseline_timetable.Time)]);

                % Convert times to datetime with millisecond precision
                IBI_test_timetable.Time = datetime(IBI_test_timetable.Time, 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');
                HR_test_timetable.Time = datetime(HR_test_timetable.Time, 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');
                EDA_test_timetable.Time = datetime(EDA_test_timetable.Time, 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');

                IBI_baseline_timetable.Time = datetime(IBI_baseline_timetable.Time, 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');
                HR_baseline_timetable.Time = datetime(HR_baseline_timetable.Time, 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');
                EDA_baseline_timetable.Time = datetime(EDA_baseline_timetable.Time, 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');

                % Synchronize numeric variables for test and baseline periods
                synchronizedNumericTestTable = synchronize(IBI_test_timetable(:, setdiff(IBI_test_timetable.Properties.VariableNames, {'Sample_ID'})), ...
                                                           HR_test_timetable(:, setdiff(HR_test_timetable.Properties.VariableNames, {'Sample_ID'})), ...
                                                           EDA_test_timetable(:, setdiff(EDA_test_timetable.Properties.VariableNames, {'Sample_ID'})), ...
                                                           'union', 'mean');

                synchronizedNumericBaselineTable = synchronize(IBI_baseline_timetable(:, setdiff(IBI_baseline_timetable.Properties.VariableNames, {'Sample_ID'})), ...
                                                               HR_baseline_timetable(:, setdiff(HR_baseline_timetable.Properties.VariableNames, {'Sample_ID'})), ...
                                                               EDA_baseline_timetable(:, setdiff(EDA_baseline_timetable.Properties.VariableNames, {'Sample_ID'})), ...
                                                               'union', 'mean');

                % Extract non-numeric variables from each timetable for test and baseline periods
                IBI_test_nonNumeric = IBI_test_timetable(:, ~varfun(@(x) isnumeric(x) || isdatetime(x) || isduration(x), IBI_test_timetable, 'OutputFormat', 'uniform'));
                HR_test_nonNumeric = HR_test_timetable(:, ~varfun(@(x) isnumeric(x) || isdatetime(x) || isduration(x), HR_test_timetable, 'OutputFormat', 'uniform'));
                EDA_test_nonNumeric = EDA_test_timetable(:, ~varfun(@(x) isnumeric(x) || isdatetime(x) || isduration(x), EDA_test_timetable, 'OutputFormat', 'uniform'));

                IBI_baseline_nonNumeric = IBI_baseline_timetable(:, ~varfun(@(x) isnumeric(x) || isdatetime(x) || isduration(x), IBI_baseline_timetable, 'OutputFormat', 'uniform'));
                HR_baseline_nonNumeric = HR_baseline_timetable(:, ~varfun(@(x) isnumeric(x) || isdatetime(x) || isduration(x), HR_baseline_timetable, 'OutputFormat', 'uniform'));
                EDA_baseline_nonNumeric = EDA_baseline_timetable(:, ~varfun(@(x) isnumeric(x) || isdatetime(x) || isduration(x), EDA_baseline_timetable, 'OutputFormat', 'uniform'));

                % Synchronize the non-numeric variables using 'previous' method for missing data
                synchronizedNonNumericTestTable = synchronize(IBI_test_nonNumeric, HR_test_nonNumeric, EDA_test_nonNumeric, 'union', 'previous');
                synchronizedNonNumericBaselineTable = synchronize(IBI_baseline_nonNumeric, HR_baseline_nonNumeric, EDA_baseline_nonNumeric, 'union', 'previous');

                % Combine synchronized tables for test and baseline periods
                synchronizedTestTable = [synchronizedNonNumericTestTable, synchronizedNumericTestTable(:, 2:end)];
                synchronizedBaselineTable = [synchronizedNonNumericBaselineTable, synchronizedNumericBaselineTable(:, 2:end)];

                % Extract features for test and baseline periods
                [IBI_Test_Features, HR_Test_Features] = extractingIBIFeatures(IBI_test_timetable);
                EDA_Test_Features = extractEDAFeatures(EDA_test_timetable);

                [IBI_Baseline_Features, HR_Baseline_Features] = extractingIBIFeatures(IBI_baseline_timetable);
                EDA_Baseline_Features = extractEDAFeatures(EDA_baseline_timetable);

                 % Convert extracted features to structures for easier handling
                IBI_Test_Features_struct = struct('participantID', participant, 'experimentID', experiment, 'meanIBI', IBI_Test_Features(1), 'sdnn', IBI_Test_Features(2), 'rmssd', IBI_Test_Features(3), 'nn50', IBI_Test_Features(4), 'pnn50', IBI_Test_Features(5));
                HR_Test_Features_struct = struct('participantID', participant, 'experimentID', experiment, 'meanHR', HR_Test_Features(1), 'maxHR', HR_Test_Features(2), 'minHR', HR_Test_Features(3), 'hrRange', HR_Test_Features(4), 'sdHR', HR_Test_Features(5));
                EDA_Test_Features_struct = struct('participantID', participant, 'experimentID', experiment, 'meanSCRAmplitude', EDA_Test_Features(1), 'scrCount', EDA_Test_Features(2), 'meanSCL', EDA_Test_Features(3), 'meanSCRRiseTime', EDA_Test_Features(4), 'meanSCRRecoveryTime', EDA_Test_Features(5), 'F0SC', EDA_Test_Features(6), 'F1SC', EDA_Test_Features(7), 'F2SC', EDA_Test_Features(8), 'F3SC', EDA_Test_Features(9), 'meanFirstDerivative', EDA_Test_Features(10), 'meanSecondDerivative', EDA_Test_Features(11));

                IBI_Baseline_Features_struct = struct('participantID', participant, 'experimentID', experiment, 'meanIBI', IBI_Baseline_Features(1), 'sdnn', IBI_Baseline_Features(2), 'rmssd', IBI_Baseline_Features(3), 'nn50', IBI_Baseline_Features(4), 'pnn50', IBI_Baseline_Features(5));
                HR_Baseline_Features_struct = struct('participantID', participant, 'experimentID', experiment, 'meanHR', HR_Baseline_Features(1), 'maxHR', HR_Baseline_Features(2), 'minHR', HR_Baseline_Features(3), 'hrRange', HR_Baseline_Features(4), 'sdHR', HR_Baseline_Features(5));
                EDA_Baseline_Features_struct = struct('participantID', participant, 'experimentID', experiment, 'meanSCRAmplitude', EDA_Baseline_Features(1), 'scrCount', EDA_Baseline_Features(2), 'meanSCL', EDA_Baseline_Features(3), 'meanSCRRiseTime', EDA_Baseline_Features(4), 'meanSCRRecoveryTime', EDA_Baseline_Features(5), 'F0SC', EDA_Baseline_Features(6), 'F1SC', EDA_Baseline_Features(7), 'F2SC', EDA_Baseline_Features(8), 'F3SC', EDA_Baseline_Features(9), 'meanFirstDerivative', EDA_Baseline_Features(10), 'meanSecondDerivative', EDA_Baseline_Features(11));

                % Calculate differences between test and baseline features
                IBI_Feature_Diffs = calculateFeatureDifferences(IBI_Test_Features_struct, IBI_Baseline_Features_struct);
                HR_Feature_Diffs = calculateFeatureDifferences(HR_Test_Features_struct, HR_Baseline_Features_struct);
                EDA_Feature_Diffs = calculateFeatureDifferences(EDA_Test_Features_struct, EDA_Baseline_Features_struct);

                % Prepare structures with labels for test, baseline, and difference data
                Test_PhysiologicalFeatures_struct = struct('metrics_type', 'test', 'IBI', IBI_Test_Features, 'HR', HR_Test_Features, 'EDA', EDA_Test_Features);
                Baseline_PhysiologicalFeatures_struct = struct('metrics_type', 'baseline', 'IBI', IBI_Baseline_Features, 'HR', HR_Baseline_Features, 'EDA', EDA_Baseline_Features);
                Difference_PhysiologicalFeatures_struct = struct('metrics_type', 'difference', 'IBI', IBI_Feature_Diffs, 'HR', HR_Feature_Diffs, 'EDA', EDA_Feature_Diffs);

                 % Save the features and synchronized tables to a .mat file
                save(fullfile(processedTablesDir, sprintf('%s_%s_PhysiologicalFeatures.mat', experiment, participant)), ...
                     'Test_PhysiologicalFeatures_struct', 'Baseline_PhysiologicalFeatures_struct', 'Difference_PhysiologicalFeatures_struct', ...
                     'synchronizedTestTable', 'synchronizedBaselineTable');
            else
                 % If tags_timetable is empty or does not contain the required columns
                disp('Tags timetable is empty or does not contain required columns.');
            end
        else
            % If tags data is not found for the participant
            disp(['Tags data not found for ', experiment, ' - ', participant']); % Debug statement
        end
    else
        % If data for the specified experiment or participant is not found
        disp(['Data not found for ', experiment, ' - ', participant']); % Debug statement
    end
        
    % Check for OpenFace and OpenVibe data (not implemented yet)
    if isfield(physiologicalData, makeValidFieldName(experiment)) && ...
       isfield(physiologicalData.(makeValidFieldName(experiment)), makeValidFieldName(participant)) && ...
       isfield(physiologicalData.(makeValidFieldName(experiment)).(makeValidFieldName(participant)), 'OpenFace')
        % ToDO -- It will be implemented in the next wheelSimAnalyzer
        % Version
        % disp(['OpenFace Data for ', experiment, ' - ', participant']); % Debug statement
    end
    if isfield(physiologicalData, makeValidFieldName(experiment)) && ...
       isfield(physiologicalData.(makeValidFieldName(experiment)), makeValidFieldName(participant)) && ...
       isfield(physiologicalData.(makeValidFieldName(experiment)).(makeValidFieldName(participant)), 'OpenVibe')
        % ToDO -- It will be implemented in the next wheelSimAnalyzer
        % Version
        % disp(['OpenVibe Data for ', experiment, ' - ', participant']); % Debug statement
    end
end

 % Function ANALYZEQUESTIONNAIREDATA Processes and saves questionnaire data for a given participant.
    %
    % INPUTS:
    %   data               - A structure containing questionnaire data for multiple participants and experiments.
    %                        It should include fields for each experiment and participant, with questionnaire data details.
    %   experiment         - A string specifying the experiment identifier within the data structure.
    %   participant        - A string specifying the participant identifier within the experiment.
    %   processedTablesDir - A string specifying the directory path where processed questionnaire data will be saved.
    %
    % OUTPUTS:
    %   Saves a .mat file in the specified directory containing:
    %     - questionnaireFeatures: Struct with participant ID, experiment ID, and the loaded questionnaire data.
    %
    % FUNCTIONALITY:
    % 1. Retrieves the questionnaire data for the specified participant and experiment from the data structure.
    % 2. Checks for the presence of a specific questionnaire data file within the retrieved data.
    % 3. Loads the questionnaire data from the file, setting all variables as 'char'.
    % 4. Creates a structure to hold the questionnaire features, including participant ID, experiment ID, and data.
    % 5. Saves the questionnaire data and features into a .mat file in the specified directory.
    % 6. Displays debug messages indicating the processing steps and paths of the saved files.
function analyzeQuestionnaireData(data, experiment, participant, processedTablesDir)
    % Display message indicating the start of questionnaire data processing
    disp(['Processing questionnaire data for ', experiment, ' - ', participant]); % Debug statement
    
     % Retrieve participant data if it exists in the data structure
    if isfield(data, makeValidFieldName(experiment)) && ...
       isfield(data.(makeValidFieldName(experiment)), makeValidFieldName(participant)) && ...
       isfield(data.(makeValidFieldName(experiment)).(makeValidFieldName(participant)), 'questionnaire_data')
   
        questionnaireData = data.(makeValidFieldName(experiment)).(makeValidFieldName(participant)).questionnaire_data;
        
         % Define the specific file name pattern for the questionnaire data
        targetFileName = sprintf('questionnaire-data-%s.csv', participant);
        targetFileNameField = makeValidFieldName(targetFileName);
        
        % Check if the specific file exists in the questionnaire data structure
        if isfield(questionnaireData, targetFileNameField)
            filePath = questionnaireData.(targetFileNameField);
            disp(['Processing questionnaire file: ', filePath]); % Debug statement
            
            % Load the questionnaire data from the file
            opts = detectImportOptions(filePath);
            varTypes = repmat({'char'}, 1, width(opts.VariableNames)); % Set all variables as 'char'
            opts.VariableTypes = varTypes;
            questionnaireTable = readtable(filePath, opts);
            
            % Display the loaded questionnaire table for verification
            disp('Loaded questionnaire table:');
            disp(questionnaireTable);
            
            % Create a structure to hold the questionnaire features
            questionnaireFeatures = struct();
            questionnaireFeatures.participantID = participant;
            questionnaireFeatures.experimentID = experiment;
            questionnaireFeatures.data = questionnaireTable;
            
            % Save the questionnaire data and experiment information to a .mat file
            savePath = fullfile(processedTablesDir, sprintf('%s_%s_questionnaire_data.mat', experiment, participant));
            save(savePath, 'questionnaireFeatures');
            
            disp(['Saved questionnaire data to: ', savePath]); % Debug statement
        else
            % If the specific questionnaire file is not found in the data structure
            disp(['Specific questionnaire file not found: ', targetFileName]); % Debug statement
        end
    else
        % If questionnaire data for the specified experiment or participant is not found
        disp(['Questionnaire data not found for ', experiment, ' - ', participant]); % Debug statement
    end
end

 % Function ANALYZESYSTEMDATA Processes and saves system data for a given participant based on the experiment type.
    %
    % INPUTS:
    %   systemData         - A structure containing system data for multiple participants and experiments.
    %                        It should include fields for each experiment and participant, with system data details.
    %   experiment         - A string specifying the experiment identifier within the system data structure.
    %   participant        - A string specifying the participant identifier within the experiment.
    %   processedTablesDir - A string specifying the directory path where processed system data will be saved.
    %
    % OUTPUTS:
    %   Saves a .mat file in the specified directory containing:
    %     - systemDataFeatures: Struct with participant ID, experiment ID, number of collisions, number of command changes,
    %                           total time, and the loaded system data table.
    %
    % FUNCTIONALITY:
    % 1. Retrieves the system data for the specified participant and experiment from the system data structure.
    % 2. Based on the experiment type, handles either a .txt or .xlsx file:
    %    - For 'experiment1': Reads metrics from a .txt file, extracts number of collisions, command changes, and total time.
    %    - For 'experiment2': Reads metrics from a .xlsx file, extracts number of collisions, command changes, and total time.
    % 3. Creates a structure to hold the system data features, including participant ID, experiment ID, and extracted metrics.
    % 4. Saves the processed system data and features into a .mat file in the specified directory.
    % 5. Displays debug messages indicating the processing steps, file paths, and results.
function analyzeSystemData(systemData, experiment, participant, processedTablesDir)
    % Display message indicating the start of system data processing
    disp(['Processing system data for ', experiment, ' - ', participant]); % Debug statement
    
    % Retrieve participant data if it exists in the system data structure
    if isfield(systemData, makeValidFieldName(experiment)) && ...
       isfield(systemData.(makeValidFieldName(experiment)), makeValidFieldName(participant)) && ...
       isfield(systemData.(makeValidFieldName(experiment)).(makeValidFieldName(participant)), 'Unity')
   
        participantData = systemData.(makeValidFieldName(experiment)).(makeValidFieldName(participant)).Unity;
        
        % Define file paths based on experiment type
        if strcmp(experiment, 'experiment1')
            % Handle .txt file
            txtFilePattern = '_PerformanceReport_txt';
            txtFilePath = getFilePath(participantData, txtFilePattern);
            if ~isempty(txtFilePath)
                disp(['Processing .txt file: ', txtFilePath]); % Debug statement
                if isfile(txtFilePath)
                    % Read the table, treating the first row as data
                    systemDataTable = readtable(txtFilePath, 'Delimiter', ' ', 'ReadVariableNames', false);
                else
                    disp(['File not found: ', txtFilePath]); % Debug statement
                    return;
                end
            else
                disp(['Performance report .txt file not found for ', experiment, ' - ', participant']); % Debug statement
                return;
            end
            
            % Extract the number of collisions and commands from the last three rows
            numCollisions = str2double(systemDataTable{end-1, 4}{1});
            numCommandChanges = str2double(systemDataTable{end, 4}{1});
            
            % Extract total time from the string at (end-2, 3)
            totalTimeStr = systemDataTable{end-2, 3}{1};
            totalTimeParts = regexp(totalTimeStr, '(\d+):(\d+)', 'tokens');
            totalTimeParts = totalTimeParts{1};
            totalMinutes = str2double(totalTimeParts{1});
            totalSeconds = str2double(totalTimeParts{2});
            totalTime = totalMinutes * 60 + totalSeconds;
            
            % Store extracted metrics in a structure
            systemDataFeatures = struct();
            systemDataFeatures.participantID = participant;
            systemDataFeatures.experimentID = experiment;
            systemDataFeatures.numCollisions = numCollisions;
            systemDataFeatures.numCommandChanges = numCommandChanges;
            systemDataFeatures.totalTime = totalTime;
            systemDataFeatures.data = systemDataTable;
            
            % Save the processed system data and features in a .mat file
            savePath = fullfile(processedTablesDir, sprintf('%s_%s_system_data.mat', experiment, participant));
            save(savePath, 'systemDataFeatures');
            

            
            disp(['Saved system data to: ', savePath]); % Debug statement

        elseif strcmp(experiment, 'experiment2')
            % Handle .xlsx file
            xlsxFileName = 'PerformanceReport_xlsx';
            xlsxFilePath = getFilePath(participantData, xlsxFileName);
            if ~isempty(xlsxFilePath)
                disp(['Processing .xlsx file: ', xlsxFilePath]); % Debug statement
                systemDataTable = readtable(xlsxFilePath, 'Sheet', 1, 'ReadVariableNames', true);
            else
                disp(['Performance report .xlsx file not found for ', experiment, ' - ', participant']); % Debug statement
                return;
            end
            
            % Process the system data table 
            % Extract metrics from the systemDataTable
            if ismember('event', systemDataTable.Properties.VariableNames) && ismember('time0', systemDataTable.Properties.VariableNames)
                % Convert the event column to a string array 
                if iscell(systemDataTable.event)
                    events = string(systemDataTable.event);
                elseif ischar(systemDataTable.event)
                    events = string({systemDataTable.event});
                else
                    events = string(systemDataTable.event);
                end
                
                % Extract metrics: Number of collisions and command changes
                collisionKeywords = {'Collision', 'Crash', 'Impact'}; % Replace with actual keywords for collisions
                numCollisions = sum(contains(events, collisionKeywords, 'IgnoreCase', true));
                
                % Change of Commands (Count how many times the event changes from one type to another)
                eventCategories = categorical(events);
                eventCodes = double(eventCategories);
                numCommandChanges = sum(diff(eventCodes) ~= 0); % Counts the number of changes in event types
                
                % Time Calculation
                totalTime = max(systemDataTable.time0) - min(systemDataTable.time0); % Total duration of the experiment
                
                % Store extracted metrics in a structure
                systemDataFeatures = struct();
                systemDataFeatures.participantID = participant;
                systemDataFeatures.experimentID = experiment;
                systemDataFeatures.numCollisions = numCollisions;
                systemDataFeatures.numCommandChanges = numCommandChanges;
                systemDataFeatures.totalTime = totalTime;
                systemDataFeatures.data = systemDataTable;
                
                % Save the processed system data and features in a .mat file
                savePath = fullfile(processedTablesDir, sprintf('%s_%s_system_data.mat', experiment, participant));
                save(savePath, 'systemDataFeatures');
                
                disp(['Saved system data to: ', savePath]); % Debug statement
            else
                disp('Required columns not found in data table'); % Debug statement
            end
        else
            % Handle unknown experiment types
            disp(['Unknown experiment type: ', experiment]); % Debug statement
            return;
        end
    else
        % If system data for the specified experiment or participant is not found
        disp(['System data not found for ', experiment, ' - ', participant]); % Debug statement
    end
end

%% 3.1 Data Analyze all participants in Experiment 1
% Display a message indicating the start of analysis for Experiment 1
disp('Starting analysis for Experiment 1...');

% Loop through all participants in Experiment 1
for i = 1:24
    % Construct participant identifier based on the index
    participant = ['monitor-', num2str(i)];
    disp(['Analyzing participant: ', participant]); % Debug statement
    
    % Analyze physiological data for the current participant
    analyzePhysiologicalData(physiologicalData, 'experiment1', participant, processedTablesDir);
    
    % Analyze questionnaire data for the current participant
    analyzeQuestionnaireData(questionnaireData, 'experiment1', participant, processedTablesDir);
    
    % Analyze system data for the current participant
    analyzeSystemData(systemData, 'experiment1', participant, processedTablesDir);
end

%% 3.2 Analyze all participants in Experiment 2
% Display a message indicating the start of analysis for Experiment 2
disp('Starting analysis for Experiment 2...');

% Loop through each VR group in Experiment 2
for g = 1:numel(vrGroupsID)
    % Loop through each participant in the current VR group
    for i = 1:vrCounts(g)
        % Construct participant identifier based on VR group and index
        participant = sprintf('%s-%d', vrGroupsID{g}, i);
        disp(['Analyzing participant: ', participant]); % Debug statement
        
        % Analyze physiological data for the current participant
        analyzePhysiologicalData(physiologicalData, 'experiment2', participant, processedTablesDir);
        
        % Analyze questionnaire data for the current participant
        analyzeQuestionnaireData(questionnaireData, 'experiment2', participant, processedTablesDir);
        
        % Analyze system data for the current participant
        analyzeSystemData(systemData, 'experiment2', participant, processedTablesDir);
    end
end



%% 4. Compile all the features into tables in .mat and .xlsx

% Function ADDTOFEATURETABLES - Aggregates data from multiple .mat files for 
% physiological features, questionnaire data, and system data, and 
% compiles them into comprehensive tables.
%
% Syntax: 
%   [allTestFeatures, allBaselineFeatures, allDifferenceFeatures, 
%    allQuestionnaireData, allSystemData] = addToFeatureTables(
%        processedTablesDir, experiment, allTestFeatures, 
%        allBaselineFeatures, allDifferenceFeatures, 
%        allQuestionnaireData, allSystemData)
%
% Inputs:
%   processedTablesDir (string) - Directory where processed .mat files are stored.
%   experiment (string) - Identifier for the specific experiment (e.g., 'experiment1', 'experiment2').
%   allTestFeatures (table) - Accumulated table of test physiological features.
%   allBaselineFeatures (table) - Accumulated table of baseline physiological features.
%   allDifferenceFeatures (table) - Accumulated table of difference physiological features.
%   allQuestionnaireData (table) - Accumulated table of questionnaire data.
%   allSystemData (table) - Accumulated table of system data.
%
% Outputs:
%   allTestFeatures (table) - Updated table of test physiological features including new data.
%   allBaselineFeatures (table) - Updated table of baseline physiological features including new data.
%   allDifferenceFeatures (table) - Updated table of difference physiological features including new data.
%   allQuestionnaireData (table) - Updated table of questionnaire data including new data.
%   allSystemData (table) - Updated table of system data including new data.
%
% Operation:
%   - Lists feature files for the specified experiment and loads physiological feature data.
%   - Extracts participant IDs and flattens feature structures into tables.
%   - Appends new data to the aggregated tables for test features, baseline features, and difference features.
%   - Processes and transposes questionnaire data, appending it to the aggregated questionnaire table.
%   - Loads system data, extracts relevant fields, and appends it to the aggregated system data table.

function [allTestFeatures, allBaselineFeatures, allDifferenceFeatures, allQuestionnaireData, allSystemData] = addToFeatureTables(processedTablesDir, experiment, allTestFeatures, allBaselineFeatures, allDifferenceFeatures, allQuestionnaireData, allSystemData)
    % List all feature files for the given experiment
    featureFiles = dir(fullfile(processedTablesDir, sprintf('%s_*_PhysiologicalFeatures.mat', experiment)));
    questionnaireFiles = dir(fullfile(processedTablesDir, sprintf('%s_*_questionnaire_data.mat', experiment)));
    systemFiles = dir(fullfile(processedTablesDir, sprintf('%s_*_system_data.mat', experiment)));

    % Iterate over each feature file
    for i = 1:length(featureFiles)
        % Load the feature file
        load(fullfile(processedTablesDir, featureFiles(i).name), 'Test_PhysiologicalFeatures_struct', 'Baseline_PhysiologicalFeatures_struct', 'Difference_PhysiologicalFeatures_struct');
        
        % Extract participant ID from the filename
        participantID = extractBetween(featureFiles(i).name, sprintf('%s_', experiment), '_PhysiologicalFeatures.mat');
        
        % Flatten the structures with participantID and experiment info
        testTable = flattenStruct(Test_PhysiologicalFeatures_struct, participantID, experiment);
        baselineTable = flattenStruct(Baseline_PhysiologicalFeatures_struct, participantID, experiment);
        diffTable = flattenStruct(Difference_PhysiologicalFeatures_struct, participantID, experiment);
        
        % Append to aggregated tables
        allTestFeatures = unique([allTestFeatures; testTable], 'rows');
        allBaselineFeatures = unique([allBaselineFeatures; baselineTable], 'rows');
        allDifferenceFeatures = unique([allDifferenceFeatures; diffTable], 'rows');
    end

    % Iterate over each questionnaire file
    for i = 1:length(questionnaireFiles)
        % Load the questionnaire data
        load(fullfile(processedTablesDir, questionnaireFiles(i).name), 'questionnaireFeatures');
        % Extract participant ID from the filename
        participantID = extractBetween(questionnaireFiles(i).name, sprintf('%s_', experiment), '_questionnaire_data.mat');
        
        % Extract data and transpose it correctly
        questionnaireData = questionnaireFeatures.data;
        headers = questionnaireData{:, 1}; % First column as headers
        values = questionnaireData{:, 2:end}'; % Transpose remaining data

        % Create a new table with headers as columns and values as rows
        transposedTable = array2table(values, 'VariableNames', headers');
        
        % Add participant ID and experiment ID as new columns
        numRows = height(transposedTable);
        transposedTable.participantID = repmat(participantID, numRows, 1);
        transposedTable.experimentID = repmat({experiment}, numRows, 1);
        
        % Append to the aggregated questionnaire table
        allQuestionnaireData = [allQuestionnaireData; transposedTable];
    end

    % Iterate over each system data file
    for i = 1:length(systemFiles)
        % Load the system data
        data = load(fullfile(processedTablesDir, systemFiles(i).name));
        
        % Check if 'systemDataFeatures' struct exists in the file
        if isfield(data, 'systemDataFeatures')
            systemDataFeatures = data.systemDataFeatures;
            
            % Extract necessary fields
            participantID = systemDataFeatures.participantID;
            experimentID = systemDataFeatures.experimentID;
            numCollisions = systemDataFeatures.numCollisions;
            numCommandChanges = systemDataFeatures.numCommandChanges;
            totalTime = systemDataFeatures.totalTime;

            % Create a structure with system data features
            systemDataEntry = struct();
            systemDataEntry.participantID = participantID;
            systemDataEntry.experimentID = experimentID;
            systemDataEntry.numCollisions = numCollisions;
            systemDataEntry.numCommandChanges = numCommandChanges;
            systemDataEntry.totalTime = totalTime;

            % Convert the structure to a table
            systemDataTable = struct2table(systemDataEntry, 'AsArray', true);

            % Append to the aggregated system data table
            allSystemData = [allSystemData; systemDataTable];
        else
            warning('Variable ''systemDataFeatures'' not found in %s', systemFiles(i).name);
        end
    end
end

% Function FLATTENSTRUCT - Converts nested structures into flat tables, adding 
% participant and experiment identifiers to each entry.
%
% Syntax: 
%   flatTable = flattenStruct(s, participantID, experiment)
%
% Inputs:
%   s (struct) - The nested structure to be flattened.
%   participantID (string) - The ID of the participant associated with the data.
%   experiment (string) - The experiment identifier associated with the data.
%
% Outputs:
%   flatTable (table) - Flattened table with nested structure fields expanded, including participant and experiment identifiers.
%
% Operation:
%   - Converts the main structure to a table.
%   - Handles scalar and non-scalar nested structures by expanding them into the main table.
%   - Adds participant and experiment identifiers to nested fields.
%   - Converts cell arrays to tables if necessary and integrates them into the main table.

function flatTable = flattenStruct(s, participantID, experiment)
    % Convert the main structure to a table
    flatTable = struct2table(s, 'AsArray', true);
    vars = flatTable.Properties.VariableNames;

    % Add participantID and experiment to the main structure fields
    flatTable.Participant = repmat(participantID, height(flatTable), 1);
    flatTable.Experiment = repmat(experiment, height(flatTable), 1);

    for i = 1:numel(vars)
        if isstruct(flatTable.(vars{i}))
            nestedStruct = flatTable.(vars{i});
            if isscalar(nestedStruct)
                % Add participantID and experiment to the nested structure
                nestedStruct.Participant = participantID;
                nestedStruct.Experiment = experiment;

                nestedTable = struct2table(nestedStruct, 'AsArray', true);
                nestedVars = nestedTable.Properties.VariableNames;

                for j = 1:numel(nestedVars)
                    flatTable.([vars{i} '_' nestedVars{j}]) = nestedTable.(nestedVars{j});
                end
            else
                % Handle non-scalar nested structs
                for k = 1:numel(nestedStruct)
                    nestedStruct(k).Participant = participantID;
                    nestedStruct(k).Experiment = experiment;

                    nestedTable = struct2table(nestedStruct(k), 'AsArray', true);
                    nestedVars = nestedTable.Properties.VariableNames;

                    for j = 1:numel(nestedVars)
                        flatTable.([vars{i} num2str(k) '_' nestedVars{j}]) = nestedTable.(nestedVars{j});
                    end
                end
            end
            flatTable.(vars{i}) = [];
        elseif iscell(flatTable.(vars{i}))
            % Convert cell array to table
            nestedCell = flatTable.(vars{i});
            for k = 1:numel(nestedCell)
                if isstruct(nestedCell{k})
                    nestedCell{k}.Participant = participantID;
                    nestedCell{k}.Experiment = experiment;

                    nestedTable = struct2table(nestedCell{k}, 'AsArray', true);
                    nestedVars = nestedTable.Properties.VariableNames;

                    for j = 1:numel(nestedVars)
                        flatTable.([vars{i} num2str(k) '_' nestedVars{j}]) = nestedTable.(nestedVars{j});
                    end
                else
                    flatTable.([vars{i} num2str(k)]) = nestedCell{k};
                end
            end
            flatTable.(vars{i}) = [];
        end
    end
end

% Initialize tables to hold features for all participants
allTestFeatures = table();
allBaselineFeatures = table();
allDifferenceFeatures = table();
allQuestionnaireData = table();
allSystemData = table();

% Extract features from processed tables for each experiment
[allTestFeatures, allBaselineFeatures, allDifferenceFeatures, allQuestionnaireData, allSystemData] = addToFeatureTables(processedTablesDir, 'experiment1', allTestFeatures, allBaselineFeatures, allDifferenceFeatures, allQuestionnaireData, allSystemData);
[allTestFeatures, allBaselineFeatures, allDifferenceFeatures, allQuestionnaireData, allSystemData] = addToFeatureTables(processedTablesDir, 'experiment2', allTestFeatures, allBaselineFeatures, allDifferenceFeatures, allQuestionnaireData, allSystemData);

% Remove specific columns from allDifferenceFeatures if not empty
if ~isempty(allDifferenceFeatures)
    % List of columns to remove
    colsToRemove = [4, 5, 11, 12, 13, 14, 20, 21, 22, 23, 35, 36];
    % Remove columns by their indices
    allDifferenceFeaturesFormatted = removevars(allDifferenceFeatures, allDifferenceFeatures.Properties.VariableNames(colsToRemove));
end

% Define target column names
targetColumnNames = {'IBI_meanIBI', 'IBI_sdnn', 'IBI_rmssd', 'IBI_nn50', 'IBI_pnn50', ...
                     'HR_meanHR', 'HR_maxHR', 'HR_minHR', 'HR_hrRange', 'HR_sdHR', ...
                     'EDA_meanSCRAmplitude', 'EDA_scrCount', 'EDA_meanSCL', 'EDA_meanSCRRiseTime', 'EDA_meanSCRRecoveryTime', ...
                     'EDA_F0SC', 'EDA_F1SC', 'EDA_F2SC', 'EDA_F3SC', 'EDA_meanFirstDerivative', 'EDA_meanSecondDerivative', ...
                     'Participant', 'Experiment', 'metrics_type1'};  

% Format the tables with the specified column names
allTestPhysiologicalFeaturesFormatted(:,1:21) = splitvars(allTestFeatures(:,1:3));
allTestPhysiologicalFeaturesFormatted(:,22:24) = allTestFeatures(:,4:6);
allTestPhysiologicalFeaturesFormatted.Properties.VariableNames = targetColumnNames;
allBaselinePhysiologicalFeaturesFormatted(:,1:21) = splitvars(allBaselineFeatures(:,1:3));
allBaselinePhysiologicalFeaturesFormatted(:,22:24) = allBaselineFeatures(:,4:6);
allBaselinePhysiologicalFeaturesFormatted.Properties.VariableNames = targetColumnNames;

% ALIGNCOLUMNS - Aligns the columns of a table to match a target set 
% of column names, ensuring consistency across multiple tables.
% Inputs:
%   table (table) - The table to be aligned.
%   targetColumnNames (cell array of strings) - The target column names that the table should match.
% Outputs:
%   alignedTable (table) - The table with columns aligned to the target column names, with missing columns added as NaNs.
%
% Operation:
%   - Adds missing columns to the table with NaN values.
%   - Reorders columns to match the target set of column names.
function alignedTable = alignColumns(table, targetColumnNames)
    % Add missing columns with NaN values
    for col = setdiff(targetColumnNames, table.Properties.VariableNames)
        table.(col) = nan(height(table), 1);
    end
    % Reorder columns to match the target
    alignedTable = table(:, targetColumnNames);
end

% Align columns of all tables to the target column names
allBaselinePhysiologicalFeaturesFormatted = alignColumns(allBaselinePhysiologicalFeaturesFormatted, targetColumnNames);
allTestPhysiologicalFeaturesFormatted = alignColumns(allTestPhysiologicalFeaturesFormatted, targetColumnNames);
allDifferenceFeaturesFormatted = alignColumns(allDifferenceFeaturesFormatted, targetColumnNames);

% Convert 'metrics_type1' column to string for each table
allTestPhysiologicalFeaturesFormatted.metrics_type1 = string(allTestPhysiologicalFeaturesFormatted.metrics_type1);
allBaselinePhysiologicalFeaturesFormatted.metrics_type1 = string(allBaselinePhysiologicalFeaturesFormatted.metrics_type1);
allDifferenceFeaturesFormatted.metrics_type1 = string(allDifferenceFeaturesFormatted.metrics_type1);

% Sort each table by 'Participant' column
allTestPhysiologicalFeaturesFormatted = sortrows(allTestPhysiologicalFeaturesFormatted, 'Participant');
allBaselinePhysiologicalFeaturesFormatted = sortrows(allBaselinePhysiologicalFeaturesFormatted, 'Participant');
allDifferenceFeaturesFormatted = sortrows(allDifferenceFeaturesFormatted, 'Participant');

% Merge the tables and sort the combined table by 'Participant'
allPhysiologicalFeatures = [allBaselinePhysiologicalFeaturesFormatted; allTestPhysiologicalFeaturesFormatted; allDifferenceFeaturesFormatted];
allPhysiologicalFeatures = sortrows(allPhysiologicalFeatures, 'Participant');

% Rename columns to a common name
allDifferenceFeaturesFormatted.Properties.VariableNames{'Participant'} = 'Participant';
allSystemData.Properties.VariableNames{'participantID'} = 'Participant'; % Adjust if 'ParticipantID' is used
allQuestionnaireData.Properties.VariableNames{'subject_id'} = 'Participant'; % Adjust if 'subject-id' is used

% Merge Physiological (only difference), Questionnaire, and System data
allTables = join(allSystemData, allQuestionnaireData);
allTables = join(allTables, allDifferenceFeaturesFormatted);

% Save the combined tables into .MAT files
save(fullfile(processedTablesDir, 'allData.mat'), 'allTables');
save(fullfile(processedTablesDir, 'allPhysiologicalFeatures.mat'), 'allPhysiologicalFeatures');
save(fullfile(processedTablesDir, 'allQuestionnaire_data.mat'), 'allQuestionnaireData');
save(fullfile(processedTablesDir, 'allSystemData.mat'), 'allSystemData');

% Define the output Excel file path
excelFile = fullfile(processedTablesDir, 'AllData.xlsx');

% Write each table to a separate sheet
% Check if variables are tables or convert them if needed
if istable(allTables)
    writetable(allTables, excelFile, 'Sheet', 'allTables');
end
if istable(allPhysiologicalFeatures)
    writetable(allPhysiologicalFeatures, excelFile, 'Sheet', 'allPhysiologicalFeatures');
end
if istable(allQuestionnaireData)
    writetable(allQuestionnaireData, excelFile, 'Sheet', 'allQuestionnaireData');
end
if istable(allSystemData)
    writetable(allSystemData, excelFile, 'Sheet', 'allSystemData');
end

disp('Analysis complete.');


%% 6. Plotting the Data Analysis
%
% 1. Box Plot
% 2. Histogram
% 3. Violin
% 4. Bar Chart

 % Adding the violin function path to the project
 violinfunctionPath = fullfile(functionsPath, 'violin');
% Add the functions folder to MATLAB's search path
addpath(violinfunctionPath);
%% 6.1 Plotting the descriptive information for Physiolgical Data:

% Extract numerical columns
numericalCols = targetColumnNames(~ismember(targetColumnNames, {'Participant', 'Experiment', 'metrics_type1'}));
% Separate data based on experiment
experiment_1_idx = strcmp(allPhysiologicalFeatures.Experiment, "experiment1");
experiment_2_idx = strcmp(allPhysiologicalFeatures.Experiment, "experiment2");
T_experiment_1 = allPhysiologicalFeatures(experiment_1_idx, :);
T_experiment_2 = allPhysiologicalFeatures(experiment_2_idx, :);

% Initialize results table
resultsTable = table();

% Loop through each numerical column
for i = 1:numel(numericalCols)
    metric = numericalCols{i};
    
    % Convert metric to string
    metricStr = string(metric);  % Convert to string
    metricStrFormatted = strrep(metricStr, '_', ' ');  % Replace underscores with spaces
    
    
    % Check if metric column exists in both tables
    if ismember(metricStr, T_experiment_1.Properties.VariableNames) && ismember(metricStr, T_experiment_2.Properties.VariableNames)
        
        % Combine data from both experiments
        combinedData = [T_experiment_1.(metricStr); T_experiment_2.(metricStr)];
        combinedExperiment = [repmat("experiment1", height(T_experiment_1), 1); repmat("experiment2", height(T_experiment_2), 1)];
        combinedMetricsType = [T_experiment_1.metrics_type1; T_experiment_2.metrics_type1];
        
        % Create a table to facilitate plotting
        plotData = table(combinedData, combinedExperiment, combinedMetricsType, 'VariableNames', {'Value', 'Experiment', 'MetricsType'});
        
        % Remove NaN values
        plotData = plotData(~isnan(plotData.Value), :);
        
        % Create a new figure for each metric
        figure;
        
        % Box Plot
        subplot(2,2,1); % Box Plot in the first subplot
        boxplot(plotData.Value, {plotData.Experiment, plotData.MetricsType});
        title(upper(sprintf('Box Plot - %s', metricStrFormatted)), 'FontWeight', 'bold', 'FontSize', 14);  % Uppercase title with bold text and increased font size
        ylabel('Value', 'FontWeight', 'bold', 'FontSize', 12);
        xlabel('Experiment and Metrics Type', 'FontWeight', 'bold', 'FontSize', 12);
        set(gca, 'FontWeight', 'bold', 'FontSize', 12);  % Increase font size for axis tick labels
        
        
        % Histogram
        subplot(2,2,2); % Histogram in the second subplot
     histogram(T_experiment_1.(metricStr), 'FaceColor', 'b', 'EdgeColor', 'k', 'FaceAlpha', 0.5); hold on;
        histogram(T_experiment_2.(metricStr), 'FaceColor', 'r', 'EdgeColor', 'k', 'FaceAlpha', 0.5);
        title(upper(sprintf('Histogram - %s', metricStrFormatted)), 'FontWeight', 'bold', 'FontSize', 14);  % Uppercase title with bold text and increased font size
        ylabel('Frequency', 'FontWeight', 'bold', 'FontSize', 12);
        xlabel(metricStrFormatted, 'FontWeight', 'bold', 'FontSize', 12);
        legend('Experiment 1', 'Experiment 2', 'FontWeight', 'bold', 'FontSize', 10);
          set(gca, 'FontWeight', 'bold', 'FontSize', 12); % Increase font size for axis tick labels
        
        
        % Bar Chart
        subplot(2,2,3); % Bar Chart in the third subplot
        
        % Compute mean values for bar chart
        means = varfun(@mean, plotData, 'InputVariables', 'Value', 'GroupingVariables', {'Experiment', 'MetricsType'});
        
        % Get unique metrics types and experiments
        metricsTypes = unique(means.MetricsType);
        experiments = unique(means.Experiment);
        
        % Prepare bar data
        barData = zeros(numel(experiments), numel(metricsTypes));
        for j = 1:numel(experiments)
            for k = 1:numel(metricsTypes)
                idx = means.Experiment == experiments(j) & means.MetricsType == metricsTypes(k);
                if any(idx)
                    barData(j, k) = means.mean_Value(idx);
                end
            end
        end
        
        % Plot bar chart
        b = bar(abs(barData), 'grouped');
        set(gca, 'XTickLabel', experiments, 'FontSize', 12,'FontWeight', 'bold');  % Increase font size for x-tick labels
        title(upper(sprintf('Bar Chart - %s', metricStrFormatted)), 'FontWeight', 'bold', 'FontSize', 14);  % Uppercase title with bold text and increased font size
        ylabel('Mean Value', 'FontWeight', 'bold', 'FontSize', 12);
        xlabel('Metrics Type', 'FontWeight', 'bold', 'FontSize', 12);
        legend(metricsTypes, 'Location', 'Best', 'FontWeight', 'bold', 'FontSize', 10);
        
        
        % Violin Plot
        subplot(2,2,4); % Violin Plot in the fourth subplot
        
        % Prepare data for violin plot
        dataForViolin = {T_experiment_1.(metricStr), T_experiment_2.(metricStr)};
        
        % Ensure the 'violin' function is available. If not, use another method or function.
        if exist('violin', 'file') == 2
            violin(dataForViolin, 'xlabel', {'Experiment 1', 'Experiment 2'}, 'facecolor', [0.5 0.5 1; 1 0.5 0.5], 'edgecolor', 'none');
        else
            error('The violin function is not available. Please add it to your MATLAB path.');
        end
        title(upper(sprintf('Violin Plot - %s', metricStrFormatted)), 'FontWeight', 'bold', 'FontSize', 14);  % Uppercase title with bold text and increased font size
        ylabel('Value', 'FontWeight', 'bold', 'FontSize', 12);
        set(gca, 'FontSize', 12, 'FontWeight', 'bold');  % Increase font size for axis tick labels
        
        % Compute descriptive statistics manually
        expList = unique(plotData.Experiment);
        typeList = unique(plotData.MetricsType);
        
        % Initialize arrays for statistics
        meanValues = NaN(numel(expList) * numel(typeList), 1);
        medianValues = NaN(numel(expList) * numel(typeList), 1);
        stdDevs = NaN(numel(expList) * numel(typeList), 1);
        counts = NaN(numel(expList) * numel(typeList), 1);
        metrics = cell(numel(expList) * numel(typeList), 1);
        experimentsStat = cell(numel(expList) * numel(typeList), 1);
        metricsTypeStat = cell(numel(expList) * numel(typeList), 1);
        
        % Calculate statistics for each combination of experiment and metrics type
        index = 1;
        for expIdx = 1:numel(expList)
            for typeIdx = 1:numel(typeList)
                expName = expList{expIdx};
                metricsName = typeList{typeIdx};
                
                subset = plotData(plotData.Experiment == expName & plotData.MetricsType == metricsName, :);
                
                meanValues(index) = mean(subset.Value, 'omitnan');
                medianValues(index) = median(subset.Value, 'omitnan');
                stdDevs(index) = std(subset.Value, 'omitnan');
                counts(index) = sum(~isnan(subset.Value));
                metrics{index} = metricStr;
                experimentsStat{index} = expName;
                metricsTypeStat{index} = metricsName;
                
                index = index + 1;
            end
        end
        
        % Create table with additional descriptive statistics
        metricResults = table( ...
            metrics, ...
            experimentsStat, ...
            metricsTypeStat, ...
            meanValues, ...
            medianValues, ...
            stdDevs, ...
            counts, ...
            'VariableNames', {'Metric', 'Experiment', 'MetricsType', 'MeanValue', 'MedianValue', 'StdDev', 'Count'});
            % Adjust layout manually to avoid overlap
         set(gcf, 'Position', [100, 100, 1800, 1200]); % Increase figure size for better spacing
        % Append to results table
        resultsTable = [resultsTable; metricResults];

         % Save the figure
        saveas(gcf, fullfile(processedTablesDir, sprintf('Descriptive_Plots_%s.png', metricStrFormatted)));
        
        
    else
        warning('Metric %s is not present in one of the tables.', metricStr);
    end
end

% Save the Descriptive StatsTable in the processed-tables folder
statsPath = fullfile(processedTablesDir, 'descriptiveStats.xlsx');
% Save results table to the specified directory
writetable(resultsTable, statsPath);

%% 6.2 Plotting Questionnaire and Performance Data:
% Load the data into MATLAB (assuming you have the data in a CSV file or MATLAB table)
data = allTables;

% Convert relevant columns to numeric types if they are not already
data.valence = str2double(data.valence);
data.arousal = str2double(data.arousal);
data.dominance = str2double(data.dominance);
data.immersion_total = str2double(data.immersion_total);
data.usability_total = str2double(data.usability_total);
data.nasa_weighted = str2double(data.nasa_weighted);

% Ensure experimentID is a string type (if it’s not numeric)
if iscell(data.experimentID)
    data.experimentID = string(data.experimentID);
end

% Extract unique experiment IDs
experimentIDs = unique(data.experimentID);

% Define colors for different experiments
colors = lines(length(experimentIDs)); % Generate distinct colors

% Metric groups and their titles
metricGroups = {
    {'numCollisions', 'numCommandChanges', 'totalTime'}, ...
    {'valence', 'arousal', 'dominance'}, ...
    {'immersion_total', 'usability_total', 'nasa_weighted'}
};
titlesGroups = {
    {'Number of Collisions', 'Number of Command Changes', 'Total Time (seconds)'}, ...
    {'Valence', 'Arousal', 'Dominance'}, ...
    {'Immersion ', 'Usability', 'Cognitive Task Load'}
};
figureNames = {'Performance Metrics', 'Emotional Metrics', 'Other Metrics'};

% Define plot types
plotTypes = {'histogram', 'bar', 'line'};

% Loop through each group of metrics
for g = 1:length(metricGroups)
    metrics = metricGroups{g};
    titles = titlesGroups{g};
    
    % Create a figure for the current group
    figure('Name', figureNames{g}, 'NumberTitle', 'off');
    
    % Calculate the number of subplots needed
    numMetrics = length(metrics);
    numTypes = length(plotTypes);
    numSubplots = numMetrics * numTypes;
    
    % Determine the layout for subplots (e.g., 3x3 grid for 9 subplots)
    numRows = ceil(numSubplots / numTypes);
    numCols = numTypes;
    
    % Initialize subplot index
    plotIndex = 1;
    
    % Loop through each metric to create subplots
    for j = 1:length(metrics)
        % Create subplots for each plot type
        for p = 1:length(plotTypes)
            subplot(numRows, numCols, plotIndex);
            hold on;
            
            % Loop through each experiment and plot data
            for i = 1:length(experimentIDs)
                expID = experimentIDs(i);
                
                % Filter data for the current experiment
                expData = data(data.experimentID == expID, :);
                
                % Get the metric data
                metricData = expData.(metrics{j});
                validData = metricData(~isnan(metricData)); % Remove NaNs
                
                switch plotTypes{p}
                    case 'histogram'
                        histogram(validData, 'FaceColor', colors(i,:), 'DisplayName', [ char(expID)], 'FaceAlpha', 0.5);
                        ylabel('Frequency');
                    case 'bar'
                        % Compute means for bar chart
                        meanValue = mean(validData, 'omitnan');
                        bar(i, meanValue, 'FaceColor', colors(i,:), 'DisplayName', [char(expID)]);
                        ylabel('Mean Value');
                        % Set x-ticks for clarity
                        set(gca, 'XTick', 1:length(experimentIDs), 'XTickLabel', experimentIDs);
                    case 'line'
                        % Plot line plot
                        plot(validData, 'Color', colors(i,:), 'DisplayName', [char(expID)], 'LineWidth', 1.5);
                        ylabel('Value');
                        xlabel('Observation Index');
                end
            end
            
            if strcmp(plotTypes{p}, 'line')
                % Add legend for line plot
                legend('show', 'Location', 'best');
                title(titles{j});
            else
                title(titles{j});
                legend('show', 'Location', 'best');
            end
            
            xlabel('Observation Index');
            
            hold off;
            
            plotIndex = plotIndex + 1;
        end
    end
    
    % Adjust layout manually to avoid overlap
    set(gcf, 'Position', [100, 100, 1800, 1200]); % Increase figure size for better spacing
    
    % Manually adjust positions of subplots
    % for k = 1:numSubplots
    %     subplot(numRows, numCols, k);
    %     pos = get(gca, 'Position');
    %     % Adjust subplot positions for better spacing
    %     pos(1) = pos(1) + 0.05;
    %     pos(2) = pos(2) + 0.05;
    %     pos(3) = pos(3) - 0.1;
    %     pos(4) = pos(4) - 0.1;
    %     set(gca, 'Position', pos);
    % end
     

    %Save the figure as an image file
    saveas(gcf, [processedTablesDir,figureNames{g}, '_comprehensive_plots.png']);
end
