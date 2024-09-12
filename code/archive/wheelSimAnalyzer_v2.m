%% WheelSimAnalyzer
% This MATLAB Live Script analyzes and visualizes data from two different experiments:
% - Experiment 1: Monitor-based experiment
% - Experiment 2: VR-based experiment
%
% Author: Debora P.S.
% Date: 22 Jul 2024
% Version: 1.0
% MATLAB Version: 2024.a

clc;
clear;
close all;

%% 1. Setup and Directory Selection

% Define the root directory for your experiments
rootDir = uigetdir('', 'Select Root Directory');

% Verify directory selection
if rootDir == 0
    error('No directory selected.');
end

% Display the selected root directory
disp(['Selected directory: ', rootDir]);

% Define subdirectories for experiments
experiment1Dir = fullfile(rootDir, 'experiment-1-monitor');
experiment2Dir = fullfile(rootDir, 'experiment-2-vr');

% Define the processed-tables directory
processedTablesDir = fullfile(rootDir, 'processed-tables');
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

% Function to recursively process files in a directory and save to structure
function data = processDirectory(directoryPath, data, experiment, participantId, dataType, dataTypeField)
    items = dir(fullfile(directoryPath, '*'));
    items = items(~[items.isdir]);

    experimentField = makeValidFieldName(experiment);
    participantField = makeValidFieldName(participantId);

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
    
    if ~isfield(data.(experimentField).(participantField), dataTypeField)
        data.(experimentField).(participantField).(dataTypeField) = struct();
    end
    
    for k = 1:numel(items)
        filePath = fullfile(directoryPath, items(k).name);
        disp(['Found file: ', filePath]);

        fileFieldName = makeValidFieldName(items(k).name);
        
        [~, ~, ext] = fileparts(items(k).name);
        switch ext
            case '.csv'
                % Save file path to structure instead of reading the data
                data.(experimentField).(participantField).(dataTypeField).(fileFieldName) = filePath;
                disp(['Saved file path for CSV file: ', items(k).name]);
            case '.xdf'
                disp(['Processing XDF file: ', items(k).name]);
                data.(experimentField).(participantField).(dataTypeField).(fileFieldName) = filePath;
            case '.txt'
                disp(['Processing .txt file: ', items(k).name]);
                data.(experimentField).(participantField).(dataTypeField).(fileFieldName) = filePath;
            case '.xlsx'
               disp(['Processing .xlsx file: ', items(k).name]);
               data.(experimentField).(participantField).(dataTypeField).(fileFieldName) = filePath;
        end
    end

    subdirs = dir(fullfile(directoryPath, '*'));
    subdirs = subdirs([subdirs.isdir] & ~ismember({subdirs.name}, {'.', '..'}));

    for k = 1:numel(subdirs)
        subdirPath = fullfile(directoryPath, subdirs(k).name);
        disp(['Entering directory: ', subdirPath]);
        data = processDirectory(subdirPath, data, experiment, participantId, dataType, subdirs(k).name);
    end
end

% Function to process physiological data for each participant
function physiologicalData = processPhysiologicalData(participantFolder, physiologicalData, experiment, participantId)
    subfolders = {'e4', 'LSL', 'OpenFace', 'OpenVibe'};
    
    for k = 1:numel(subfolders)
        subfolderPath = fullfile(participantFolder, 'physiological-data', subfolders{k});
        
        if isfolder(subfolderPath)
            disp(['Processing folder: ', subfolderPath]);
            physiologicalData = processDirectory(subfolderPath, physiologicalData, experiment, participantId, 'physiological-data', subfolders{k});
        end
    end
end

% Function to process questionnaire data for each participant
function questionnaireData = processQuestionnaireData(participantFolder, questionnaireData, experiment, participantId)
     questionnaireFolderPath = fullfile(participantFolder, 'questionnaire-data');
    if isfolder(questionnaireFolderPath)
        disp(['Processing questionnaire folder: ', questionnaireFolderPath]);
        questionnaireData = processDirectory(questionnaireFolderPath, questionnaireData, experiment, participantId, 'questionnaire-data','');
    end
    
end

% Function to process system data for each participant
function systemData = processSystemData(participantFolder, systemData, experiment, participantId)
    subfolders = {'Unity'};
    
    for k = 1:numel(subfolders)
        subfolderPath = fullfile(participantFolder, 'system-data', subfolders{k});
        
        if isfolder(subfolderPath)
            disp(['Processing folder: ', subfolderPath]);
            systemData = processDirectory(subfolderPath, systemData, experiment, participantId, 'system-data', subfolders{k});
        end
    end
end



%% Example processing for Experiment 1

% Initialize data structures
physiologicalData = struct();
questionnaireData = struct();
systemData = struct();

for i = 1:24
    participantFolder = fullfile(experiment1Dir, ['monitor-', num2str(i)]);
    participantId = ['monitor-', num2str(i)];
    
    if isfolder(participantFolder)
        disp(['Processing participant: ', participantFolder]);
        
        % Process physiological data
        physiologicalData = processPhysiologicalData(participantFolder, physiologicalData, 'experiment1', participantId);
        
        % Process questionnaire data
        questionnaireData = processQuestionnaireData(participantFolder, questionnaireData, 'experiment1', participantId);

        % Process system data
        systemData = processSystemData(participantFolder, systemData, 'experiment1', participantId);
    end
end

%% Process each participant in Experiment 2

vrGroups = {'vr-high-jerk', 'vr-low-jerk'};
vrGroupsID = {'vr-highjerk', 'vr-lowjerk'};
vrCounts = [18, 16];

for g = 1:numel(vrGroups)
    groupFolder = fullfile(experiment2Dir, vrGroups{g});
    
    disp(['Checking group folder: ', groupFolder]);
    
    if isfolder(groupFolder)
        disp(['Processing group folder: ', groupFolder]);
        
        for i = 1:vrCounts(g)
            participantId = sprintf('%s-%d', vrGroupsID{g}, i);
            participantFolder = fullfile(groupFolder, participantId);
            
            disp(['Constructed participant folder path: ', participantFolder]);
            
            if isfolder(participantFolder)
                disp(['Processing participant: ', participantFolder]);
                
                % Process physiological data
                physiologicalData = processPhysiologicalData(participantFolder, physiologicalData, 'experiment2', participantId);
                
                % Process questionnaire data
                questionnaireData = processQuestionnaireData(participantFolder, questionnaireData, 'experiment2', participantId);
                
                % Process system data
                systemData = processSystemData(participantFolder, systemData, 'experiment2', participantId);
            else
                disp(['Participant folder not found: ', participantFolder]);
            end
        end
    else
        disp(['Group folder not found: ', groupFolder]);
    end
end

%% 3. Physiological Data Analysis

% % Define the path to your functions
scriptPath = mfilename('fullpath');
projectRoot = fileparts(fileparts(fileparts(scriptPath))); % Navigate up to the project root
% Construct the path to the functions folder
functionsPath = fullfile(projectRoot, 'scripts', 'WheelSimAnalyzer', 'functions-versions');
% Add the path to MATLAB's search path
addpath(functionsPath);

% Helper function to get the file path matching a pattern
function filePath = getFilePath(participantData, filePattern)
    fileNames = fieldnames(participantData);
    filePath = '';
    for i = 1:numel(fileNames)
        if contains(fileNames{i}, filePattern)
            filePath = participantData.(fileNames{i});
            break;
        end
    end
end


% Function to calculate differences between two feature structures
function feature_diffs = calculateFeatureDifferences(test_features, baseline_features)
    % Extract field names from one of the structures
    fields = fieldnames(test_features);
    
    % Initialize structure to store differences
    feature_diffs = struct();
    
    % Iterate over each field and calculate the difference
    for i = 1:numel(fields)
        field = fields{i};
        if isfield(test_features, field) && isfield(baseline_features, field)
            % Compute the difference, handling NaN values
            test_value = test_features.(field);
            baseline_value = baseline_features.(field);
            if strcmp(field, 'participantID') || strcmp(field, 'experimentID')
                % For participantID and experimentID, keep the values unchanged
                feature_diffs.(field) = test_value;

            % Calculate difference, treating NaN values appropriately
            elseif isnumeric(test_value) && isnumeric(baseline_value)
                % Subtract values and handle NaNs
                feature_diffs.(field) = test_value - baseline_value;
            else
                % If non-numeric or missing, set difference as NaN
                feature_diffs.(field) = NaN;
            end
        else
            % Field missing in either structure
            feature_diffs.(field) = NaN;
        end
    end
end

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
                EDA_Test_Features = extractSCRmetrics(EDA_test_timetable);

                [IBI_Baseline_Features, HR_Baseline_Features] = extractingIBIFeatures(IBI_baseline_timetable);
                EDA_Baseline_Features = extractSCRmetrics(EDA_baseline_timetable);

                IBI_Test_Features_struct = struct('participantID', participant, 'experimentID', experiment, 'meanIBI', IBI_Test_Features(1), 'sdnn', IBI_Test_Features(2), 'rmssd', IBI_Test_Features(3), 'nn50', IBI_Test_Features(4), 'pnn50', IBI_Test_Features(5));
                HR_Test_Features_struct = struct('participantID', participant, 'experimentID', experiment, 'meanHR', HR_Test_Features(1), 'maxHR', HR_Test_Features(2), 'minHR', HR_Test_Features(3), 'hrRange', HR_Test_Features(4), 'sdHR', HR_Test_Features(5));
                EDA_Test_Features_struct = struct('participantID', participant, 'experimentID', experiment, 'meanSCRAmplitude', EDA_Test_Features(1), 'scrCount', EDA_Test_Features(2), 'meanSCL', EDA_Test_Features(3), 'meanSCRRiseTime', EDA_Test_Features(4), 'meanSCRRecoveryTime', EDA_Test_Features(5));

                IBI_Baseline_Features_struct = struct('participantID', participant, 'experimentID', experiment, 'meanIBI', IBI_Baseline_Features(1), 'sdnn', IBI_Baseline_Features(2), 'rmssd', IBI_Baseline_Features(3), 'nn50', IBI_Baseline_Features(4), 'pnn50', IBI_Baseline_Features(5));
                HR_Baseline_Features_struct = struct('participantID', participant, 'experimentID', experiment, 'meanHR', HR_Baseline_Features(1), 'maxHR', HR_Baseline_Features(2), 'minHR', HR_Baseline_Features(3), 'hrRange', HR_Baseline_Features(4), 'sdHR', HR_Baseline_Features(5));
                EDA_Baseline_Features_struct = struct('participantID', participant, 'experimentID', experiment, 'meanSCRAmplitude', EDA_Baseline_Features(1), 'scrCount', EDA_Baseline_Features(2), 'meanSCL', EDA_Baseline_Features(3), 'meanSCRRiseTime', EDA_Baseline_Features(4), 'meanSCRRecoveryTime', EDA_Baseline_Features(5));

                % Calculate differences between test and baseline features
               IBI_Feature_Diffs = calculateFeatureDifferences(IBI_Test_Features_struct, IBI_Baseline_Features_struct);
               HR_Feature_Diffs = calculateFeatureDifferences(HR_Test_Features_struct, HR_Baseline_Features_struct);
               EDA_Feature_Diffs = calculateFeatureDifferences(EDA_Test_Features_struct, EDA_Baseline_Features_struct);
               
                % Prepare structures with labels
                Test_Features_struct = struct('metrics_type', 'test', 'IBI', IBI_Test_Features, 'HR', HR_Test_Features, 'EDA', EDA_Test_Features);
                Baseline_Features_struct = struct('metrics_type', 'baseline', 'IBI', IBI_Baseline_Features, 'HR', HR_Baseline_Features, 'EDA', EDA_Baseline_Features);
                Difference_Features_struct = struct('metrics_type', 'difference', 'IBI', IBI_Feature_Diffs, 'HR', HR_Feature_Diffs, 'EDA', EDA_Feature_Diffs);

               
               % Save features and synchronized tables for test and
                % baseline periods in separate files

                % save(fullfile(processedTablesDir, sprintf('%s_%s_test_features.mat', experiment, participant)), 'IBI_Test_Features_struct', 'HR_Test_Features_struct', 'EDA_Test_Features_struct');
                % save(fullfile(processedTablesDir, sprintf('%s_%s_test_synchronized.mat', experiment, participant)), 'synchronizedTestTable');
                % 
                % save(fullfile(processedTablesDir, sprintf('%s_%s_baseline_features.mat', experiment, participant)), 'IBI_Baseline_Features_struct', 'HR_Baseline_Features_struct', 'EDA_Baseline_Features_struct');
                % save(fullfile(processedTablesDir, sprintf('%s_%s_baseline_synchronized.mat', experiment, participant)), 'synchronizedBaselineTable');
                % 
                % Save features from baseline, test and differences between
                % the periods into a single file
                % save(fullfile(processedTablesDir, sprintf('%s_%s_features.mat', experiment, participant)), 'IBI_Test_Features_struct', 'HR_Test_Features_struct', 'EDA_Test_Features_struct', 'IBI_Baseline_Features_struct', 'HR_Baseline_Features_struct', 'EDA_Baseline_Features_struct', 'IBI_Feature_Diffs', 'HR_Feature_Diffs', 'EDA_Feature_Diffs');
                % save(fullfile(processedTablesDir, sprintf('%s_%s_synchronized.mat', experiment, participant)), 'synchronizedTestTable', 'synchronizedBaselineTable');
               
                % Save features and synchronized tables
                 % Save features and synchronized tables
                save(fullfile(processedTablesDir, sprintf('%s_%s_features.mat', experiment, participant)), ...
                     'Test_Features_struct', 'Baseline_Features_struct', 'Difference_Features_struct', ...
                     'synchronizedTestTable', 'synchronizedBaselineTable');


            else
                disp('Tags timetable is empty or does not contain required columns.');
            end
        else
            disp(['Tags data not found for ', experiment, ' - ', participant]); % Debug statement
        end

    else
        disp(['Data not found for ', experiment, ' - ', participant]); % Debug statement
    end

    if isfield(physiologicalData, makeValidFieldName(experiment)) && ...
       isfield(physiologicalData.(makeValidFieldName(experiment)), makeValidFieldName(participant)) && ...
       isfield(physiologicalData.(makeValidFieldName(experiment)).(makeValidFieldName(participant)), 'OpenFace')
        % ToDO -- It will be implemented in the next wheelSimAnalyzer
        % Version
        % disp(['OpenFace Data for ', experiment, ' - ', participant]); % Debug statement
    end
    if isfield(physiologicalData, makeValidFieldName(experiment)) && ...
       isfield(physiologicalData.(makeValidFieldName(experiment)), makeValidFieldName(participant)) && ...
       isfield(physiologicalData.(makeValidFieldName(experiment)).(makeValidFieldName(participant)), 'OpenVibe')
        % ToDO -- It will be implemented in the next wheelSimAnalyzer
        % Version
        % disp(['OpenVibe Data for ', experiment, ' - ', participant]); % Debug statement
    end
end

function analyzeQuestionnaireData(data, experiment, participant, processedTablesDir)
    disp(['Processing questionnaire data for ', experiment, ' - ', participant]); % Debug statement
    
    % Retrieve participant data
    if isfield(data, makeValidFieldName(experiment)) && ...
       isfield(data.(makeValidFieldName(experiment)), makeValidFieldName(participant)) && ...
       isfield(data.(makeValidFieldName(experiment)).(makeValidFieldName(participant)), 'questionnaire_data')
   
        questionnaireData = data.(makeValidFieldName(experiment)).(makeValidFieldName(participant)).questionnaire_data;
        
        % Define the specific file name pattern
        targetFileName = sprintf('questionnaire-data-%s.csv', participant);
        targetFileNameField = makeValidFieldName(targetFileName);
        
        % Check if the specific file exists in the data structure
        if isfield(questionnaireData, targetFileNameField)
            filePath = questionnaireData.(targetFileNameField);
            disp(['Processing questionnaire file: ', filePath]); % Debug statement
            
                % Load the questionnaire data
            opts = detectImportOptions(filePath);
            varTypes = repmat({'char'}, 1, width(opts.VariableNames)); % Set all variables as 'char'
            opts.VariableTypes = varTypes;
            questionnaireTable = readtable(filePath, opts);
            
            % Display the table to check for nonnumeric values
            disp('Loaded questionnaire table:');
            disp(questionnaireTable);
            
            
            
            % Create a structure to hold the questionnaire features
            questionnaireFeatures = struct();
            questionnaireFeatures.participantID = participant;
            questionnaireFeatures.experimentID = experiment;
            questionnaireFeatures.data = questionnaireTable;
            
            % Save the questionnaire data and experiment information in a .mat file
            savePath = fullfile(processedTablesDir, sprintf('%s_%s_questionnaire_data.mat', experiment, participant));
            save(savePath, 'questionnaireFeatures');
            
            disp(['Saved questionnaire data to: ', savePath]); % Debug statement
        else
            disp(['Specific questionnaire file not found: ', targetFileName]); % Debug statement
        end
    else
        disp(['Questionnaire data not found for ', experiment, ' - ', participant]); % Debug statement
    end
end

function analyzeSystemData(systemData, experiment, participant, processedTablesDir)
    disp(['Processing system data for ', experiment, ' - ', participant]); % Debug statement
    
    % Retrieve participant data
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
            
            % Store extracted metrics
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
            
            % Process the system data table as needed
            % Extract metrics from the systemDataTable
            if ismember('event', systemDataTable.Properties.VariableNames) && ismember('time0', systemDataTable.Properties.VariableNames)
                % Convert the event column to a string array if it's not already
                if iscell(systemDataTable.event)
                    events = string(systemDataTable.event);
                elseif ischar(systemDataTable.event)
                    events = string({systemDataTable.event});
                else
                    events = string(systemDataTable.event);
                end
                
                %Number of Collisions (Assuming 'Collision' is mentioned in the event column)
                collisionKeywords = {'Collision', 'Crash', 'Impact'}; % Replace with actual keywords for collisions
                numCollisions = sum(contains(events, collisionKeywords, 'IgnoreCase', true));
                
                % Change of Commands (Count how many times the event changes from one type to another)
                eventCategories = categorical(events);
                eventCodes = double(eventCategories);
                numCommandChanges = sum(diff(eventCodes) ~= 0); % Counts the number of changes in event types
                
                % Time Calculation
                totalTime = max(systemDataTable.time0) - min(systemDataTable.time0); % Total duration of the experiment
                
                % Store extracted metrics
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
            disp(['Unknown experiment type: ', experiment]); % Debug statement
            return;
        end
    else
        disp(['System data not found for ', experiment, ' - ', participant]); % Debug statement
    end
end

%% Analyze all participants in Experiment 1
disp('Starting analysis for Experiment 1...');
for i = 1:24
    participant = ['monitor-', num2str(i)];
    disp(['Analyzing participant: ', participant]); % Debug statement
    analyzePhysiologicalData(physiologicalData, 'experiment1', participant, processedTablesDir);
    % analyzeQuestionnaireData(questionnaireData, 'experiment1', participant, processedTablesDir);
    analyzeSystemData(systemData, 'experiment1', participant, processedTablesDir);
end

%% Analyze all participants in Experiment 2
disp('Starting analysis for Experiment 2...');
for g = 1:numel(vrGroupsID)
    for i = 1:vrCounts(g)
        participant = sprintf('%s-%d', vrGroupsID{g}, i);
        disp(['Analyzing participant: ', participant]); % Debug statement
        % analyzePhysiologicalData(physiologicalData, 'experiment2', participant, processedTablesDir);
        % analyzeQuestionnaireData(questionnaireData, 'experiment2', participant, processedTablesDir);
        analyzeSystemData(systemData, 'experiment2', participant, processedTablesDir);
    end
end

%%
% % Function to extract features and add to tables
% function [allTestFeatures, allBaselineFeatures, allDifferenceFeatures, allQuestionnaireData] = addToFeatureTables(processedTablesDir, experiment, allTestFeatures, allBaselineFeatures, allDifferenceFeatures, allQuestionnaireData)
%     % List all feature files for the given experiment
%     featureFiles = dir(fullfile(processedTablesDir, sprintf('%s_*_features.mat', experiment)));
%     questionnaireFiles = dir(fullfile(processedTablesDir, sprintf('%s_*_questionnaire_data.mat', experiment)));
% 
%     % Iterate over each feature file
%     for i = 1:length(featureFiles)
%         % Load the feature file
%         load(fullfile(processedTablesDir, featureFiles(i).name), 'Test_Features_struct', 'Baseline_Features_struct', 'Difference_Features_struct');
% 
%         % Extract participant ID from the filename
%         participantID = extractBetween(featureFiles(i).name, sprintf('%s_', experiment), '_features.mat');
% 
%         % Flatten the structures with participantID and experiment info
%         testTable = flattenStruct(Test_Features_struct, participantID, experiment);
%         baselineTable = flattenStruct(Baseline_Features_struct, participantID, experiment);
%         diffTable = flattenStruct(Difference_Features_struct, participantID, experiment);
% 
%         % Append to aggregated tables
%         allTestFeatures = unique([allTestFeatures; testTable], 'rows');
%         allBaselineFeatures = unique([allBaselineFeatures; baselineTable], 'rows');
%         allDifferenceFeatures = unique([allDifferenceFeatures; diffTable], 'rows');
%     end
% 
%     % Iterate over each questionnaire file
%     for i = 1:length(questionnaireFiles)
%         % Load the questionnaire data
%         load(fullfile(processedTablesDir, questionnaireFiles(i).name), 'questionnaireFeatures');
%        % Extract participant ID from the filename
%         participantID = extractBetween(questionnaireFiles(i).name, sprintf('%s_', experiment), '_questionnaire_data.mat');
% 
%         % Extract data and transpose it correctly
%         questionnaireData = questionnaireFeatures.data;
%         headers = questionnaireData{:, 1}; % First column as headers
%         values = questionnaireData{:, 2:end}'; % Transpose remaining data
% 
%         % Create a new table with headers as columns and values as rows
%         transposedTable = array2table(values, 'VariableNames', headers');
% 
%         % Add participant ID and experiment ID as new columns
%         numRows = height(transposedTable);
%         transposedTable.participantID = repmat(participantID, numRows, 1);
%         transposedTable.experimentID = repmat({experiment}, numRows, 1);
% 
%         % Append to the aggregated questionnaire table
%         allQuestionnaireData = [allQuestionnaireData; transposedTable];
%     end
% end
% 
% 
% 
% function flatTable = flattenStruct(s, participantID, experiment)
%     % Convert the main structure to a table
%     flatTable = struct2table(s, 'AsArray', true);
%     vars = flatTable.Properties.VariableNames;
% 
%     % Add participantID and experiment to the main structure fields
%     flatTable.Participant = repmat(participantID, height(flatTable), 1);
%     flatTable.Experiment = repmat(experiment, height(flatTable), 1);
% 
%     for i = 1:numel(vars)
%         if isstruct(flatTable.(vars{i}))
%             nestedStruct = flatTable.(vars{i});
%             if isscalar(nestedStruct)
%                 % Add participantID and experiment to the nested structure
%                 nestedStruct.Participant = participantID;
%                 nestedStruct.Experiment = experiment;
% 
%                 nestedTable = struct2table(nestedStruct, 'AsArray', true);
%                 nestedVars = nestedTable.Properties.VariableNames;
% 
%                 for j = 1:numel(nestedVars)
%                     flatTable.([vars{i} '_' nestedVars{j}]) = nestedTable.(nestedVars{j});
%                 end
%             else
%                 % Handle non-scalar nested structs
%                 for k = 1:numel(nestedStruct)
%                     nestedStruct(k).Participant = participantID;
%                     nestedStruct(k).Experiment = experiment;
% 
%                     nestedTable = struct2table(nestedStruct(k), 'AsArray', true);
%                     nestedVars = nestedTable.Properties.VariableNames;
% 
%                     for j = 1:numel(nestedVars)
%                         flatTable.([vars{i} num2str(k) '_' nestedVars{j}]) = nestedTable.(nestedVars{j});
%                     end
%                 end
%             end
%             flatTable.(vars{i}) = [];
%         elseif iscell(flatTable.(vars{i}))
%             % Convert cell array to table
%             nestedCell = flatTable.(vars{i});
%             for k = 1:numel(nestedCell)
%                 if isstruct(nestedCell{k})
%                     nestedCell{k}.Participant = participantID;
%                     nestedCell{k}.Experiment = experiment;
% 
%                     nestedTable = struct2table(nestedCell{k}, 'AsArray', true);
%                     nestedVars = nestedTable.Properties.VariableNames;
% 
%                     for j = 1:numel(nestedVars)
%                         flatTable.([vars{i} num2str(k) '_' nestedVars{j}]) = nestedTable.(nestedVars{j});
%                     end
%                 else
%                     flatTable.([vars{i} num2str(k)]) = nestedCell{k};
%                 end
%             end
%             flatTable.(vars{i}) = [];
%         end
%     end
% end
% 
% % Initialize tables to hold features for all participants
% allTestFeatures = table();
% allBaselineFeatures = table();
% allDifferenceFeatures = table();
% allQuestionnaireData = table();
% 
% % Function to extract features and add to tables
% [allTestFeatures, allBaselineFeatures, allDifferenceFeatures, allQuestionnaireData] = addToFeatureTables(processedTablesDir, 'experiment1', allTestFeatures, allBaselineFeatures, allDifferenceFeatures, allQuestionnaireData);
% [allTestFeatures, allBaselineFeatures, allDifferenceFeatures, allQuestionnaireData] = addToFeatureTables(processedTablesDir, 'experiment2', allTestFeatures, allBaselineFeatures, allDifferenceFeatures, allQuestionnaireData);
% if ~isempty(allDifferenceFeatures)
%     % List of columns to remove
%     colsToRemove = [4, 5, 11, 12, 13, 14, 20, 21, 22, 23, 29, 30];
%     % Remove columns by their indices
%     allDifferenceFeatures = removevars(allDifferenceFeatures, allDifferenceFeatures.Properties.VariableNames(colsToRemove));
% end
% 
% % Save aggregated tables
% save(fullfile(processedTablesDir, 'allTestFeatures.mat'), 'allTestFeatures');
% save(fullfile(processedTablesDir, 'allBaselineFeatures.mat'), 'allBaselineFeatures');
% save(fullfile(processedTablesDir, 'allDifferenceFeatures.mat'), 'allDifferenceFeatures');
% save(fullfile(processedTablesDir, 'allQuestionnaire_data.mat'), 'allQuestionnaireData');
% disp('Analysis complete.');


%%
% Function to extract features and add to tables
function [allTestFeatures, allBaselineFeatures, allDifferenceFeatures, allQuestionnaireData, allSystemData] = addToFeatureTables(processedTablesDir, experiment, allTestFeatures, allBaselineFeatures, allDifferenceFeatures, allQuestionnaireData, allSystemData)
    % List all feature files for the given experiment
    featureFiles = dir(fullfile(processedTablesDir, sprintf('%s_*_features.mat', experiment)));
    questionnaireFiles = dir(fullfile(processedTablesDir, sprintf('%s_*_questionnaire_data.mat', experiment)));
    systemFiles = dir(fullfile(processedTablesDir, sprintf('%s_*_system_data.mat', experiment)));

    % Iterate over each feature file
    for i = 1:length(featureFiles)
        % Load the feature file
        load(fullfile(processedTablesDir, featureFiles(i).name), 'Test_Features_struct', 'Baseline_Features_struct', 'Difference_Features_struct');
        
        % Extract participant ID from the filename
        participantID = extractBetween(featureFiles(i).name, sprintf('%s_', experiment), '_features.mat');
        
        % Flatten the structures with participantID and experiment info
        testTable = flattenStruct(Test_Features_struct, participantID, experiment);
        baselineTable = flattenStruct(Baseline_Features_struct, participantID, experiment);
        diffTable = flattenStruct(Difference_Features_struct, participantID, experiment);
        
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

% Function to extract features and add to tables
[allTestFeatures, allBaselineFeatures, allDifferenceFeatures, allQuestionnaireData, allSystemData] = addToFeatureTables(processedTablesDir, 'experiment1', allTestFeatures, allBaselineFeatures, allDifferenceFeatures, allQuestionnaireData, allSystemData);
[allTestFeatures, allBaselineFeatures, allDifferenceFeatures, allQuestionnaireData, allSystemData] = addToFeatureTables(processedTablesDir, 'experiment2', allTestFeatures, allBaselineFeatures, allDifferenceFeatures, allQuestionnaireData, allSystemData);

if ~isempty(allDifferenceFeatures)
    % List of columns to remove
    colsToRemove = [4, 5, 11, 12, 13, 14, 20, 21, 22, 23, 29, 30];
    % Remove columns by their indices
    allDifferenceFeatures = removevars(allDifferenceFeatures, allDifferenceFeatures.Properties.VariableNames(colsToRemove));
end

% Save aggregated tables
save(fullfile(processedTablesDir, 'allTestFeatures.mat'), 'allTestFeatures');
save(fullfile(processedTablesDir, 'allBaselineFeatures.mat'), 'allBaselineFeatures');
save(fullfile(processedTablesDir, 'allDifferenceFeatures.mat'), 'allDifferenceFeatures');
save(fullfile(processedTablesDir, 'allQuestionnaire_data.mat'), 'allQuestionnaireData');
save(fullfile(processedTablesDir, 'allSystemData.mat'), 'allSystemData');
disp('Analysis complete.');
