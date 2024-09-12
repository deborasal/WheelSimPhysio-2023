%% WheelSimAnalyzer
% This MATLAB Live Script analyzes and visualizes data from two different experiments:
% - Experiment 1: Monitor-based experiment
% - Experiment 2: VR-based experiment
%
% The script performs the following tasks:
% - Loads and processes data from specified directories
% - Executes statistical analyses (e.g., t-tests)
% - Generates various types of plots
% - Saves results to a specified file
%
% Author: Debora P.S.
% Date: 22 Jul 2024
% Version: 1.0
% MATLAB Version: 2024.a

%% 1. Setup and Directory Selection

% Define the root directory for your experiments
% Change this to your root directory path
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

% Example function to list files in a specified directory
function files = listFilesInDir(directory)
    files = dir(fullfile(directory, '*'));
    files = files(~[files.isdir]); % Exclude directories
end

%% 2. Processing Physiological Data

% Initialize the physiologicalData structure
physiologicalData = struct();

% Function to create a valid field name
function validFieldName = makeValidFieldName(name)
    % Replace invalid characters with underscores
    validFieldName = matlab.lang.makeValidName(name);
end

% Function to recursively process files in a directory and save to structure
function physiologicalData = processDirectory(directoryPath, physiologicalData, experiment, participantId, dataType)
    % List all items in the directory
    items = dir(fullfile(directoryPath, '*'));
    items = items(~[items.isdir]); % Exclude directories

    % Create valid field names for experiment, participant, and dataType
    experimentField = makeValidFieldName(experiment);
    participantField = makeValidFieldName(participantId);
    dataTypeField = makeValidFieldName(dataType);

    % Initialize subfields for the dataType if not already present
    if ~isfield(physiologicalData, experimentField)
        physiologicalData.(experimentField) = struct();
    end
    if ~isfield(physiologicalData.(experimentField), participantField)
        physiologicalData.(experimentField).(participantField) = struct();
    end
    if ~isfield(physiologicalData.(experimentField).(participantField), dataTypeField)
        physiologicalData.(experimentField).(participantField).(dataTypeField) = struct();
    end
    
    % Process files in the directory
    for k = 1:numel(items)
        filePath = fullfile(directoryPath, items(k).name);
        disp(['Found file: ', filePath]);

        % Create a valid field name for the file
        fileFieldName = makeValidFieldName(items(k).name);
        
        % Determine the type of data based on file extension
        [~, ~, ext] = fileparts(items(k).name);
        switch ext
            case '.csv'
                % Read CSV files into table
                data = readtable(filePath);
                % Save to structure
                physiologicalData.(experimentField).(participantField).(dataTypeField).(fileFieldName) = data;
                disp(['Read data from CSV file: ', items(k).name]);
            case '.xdf'
                % Placeholder for processing XDF files
                disp(['Processing XDF file: ', items(k).name]);
                % Save to structure (assuming you process the file and store relevant data)
                % physiologicalData.(experimentField).(participantField).(dataTypeField).(fileFieldName) = processedData;
        end
    end

    % Recursively process subdirectories
    subdirs = dir(fullfile(directoryPath, '*'));
    subdirs = subdirs([subdirs.isdir] & ~ismember({subdirs.name}, {'.', '..'})); % Exclude '.' and '..'

    for k = 1:numel(subdirs)
        subdirPath = fullfile(directoryPath, subdirs(k).name);
        disp(['Entering directory: ', subdirPath]);
        physiologicalData = processDirectory(subdirPath, physiologicalData, experiment, participantId, dataType); % Recursively process the subdirectory
    end
end

% Function to process physiological data for each participant
function physiologicalData = processPhysiologicalData(participantFolder, physiologicalData, experiment)
    % Define subfolders to look for within 'physiological-data'
    subfolders = {'e4', 'LSL', 'OpenFace', 'OpenVibe'};
    
    for k = 1:numel(subfolders)
        subfolderPath = fullfile(participantFolder, 'physiological-data', subfolders{k});
        
        if isfolder(subfolderPath)
            disp(['Processing folder: ', subfolderPath]);
            physiologicalData = processDirectory(subfolderPath, physiologicalData, experiment, participantFolder, subfolders{k}); % Process files and subdirectories
        end
    end
end

% Example processing for Experiment 1
for i = 1:24
    participantFolder = fullfile(experiment1Dir, ['monitor-', num2str(i)]);
    if isfolder(participantFolder)
        disp(['Processing participant: ', participantFolder]);
        % List files in each data folder (physiological, questionnaire, system)
        %%physiologicalData = listFilesInDir(fullfile(participantFolder, 'physiological-data'));
        % processPhysiologicalData(participantFolder);
        physiologicalData = processPhysiologicalData(participantFolder, physiologicalData, 'experiment1');
        questionnaireData = listFilesInDir(fullfile(participantFolder, 'questionnaire-data'));
        systemData = listFilesInDir(fullfile(participantFolder, 'system-data'));
        % Process the files as needed
        % E4 metrics
        % OpenFace
    end
end

% Process each participant in Experiment 2
vrGroups = {'vr-high-jerk', 'vr-low-jerk'};
vrGroupsID={'vr-highjerk', 'vr-lowjerk'};
vrCounts = [18, 16];
for g = 1:numel(vrGroups)
    groupFolder = fullfile(experiment2Dir, vrGroups{g});
    
    % Print debug information
    disp(['Checking group folder: ', groupFolder]);
    
    if isfolder(groupFolder)
        disp(['Processing group folder: ', groupFolder]);
        for i = 1:vrCounts(g)
            % Construct participant ID without additional hyphens
            participantId = sprintf('%s-%d', vrGroupsID{g}, i); % Format like 'vr-highjerk-1'
            participantFolder = fullfile(groupFolder, participantId);
            
            % Debugging: Print the constructed path
            disp(['Constructed participant folder path: ', participantFolder]);
            
            if isfolder(participantFolder)
                disp(['Processing participant: ', participantFolder]);
                physiologicalData = processPhysiologicalData(participantFolder, physiologicalData, 'experiment2');
            else
                disp(['Participant folder not found: ', participantFolder]);
            end
        end
    else
        disp(['Group folder not found: ', groupFolder]);
    end
end

%% 3. Statistical Analysis

% Example function to perform a t-test
function performTTest(data1, data2, alpha)
    [h, p] = ttest2(data1, data2, 'Alpha', alpha);
    disp(['t-test results: h = ', num2str(h), ', p = ', num2str(p)]);
end

% Example data for statistical analysis
data1 = randn(30, 1);
data2 = randn(30, 1);
alpha = 0.05;

% Perform t-test
performTTest(data1, data2, alpha);

%% 4. Data Visualization

% Example function to plot data
function plotData(x, y, plotType, lineWidth)
    switch plotType
        case 'Line'
            plot(x, y, 'LineWidth', lineWidth);
        case 'Scatter'
            scatter(x, y, 'LineWidth', lineWidth);
        case 'Histogram'
            histogram(y);
        case 'Bar'
            bar(y);
    end
    xlabel('X-axis');
    ylabel('Y-axis');
    title(['Plot Type: ', plotType]);
end

% Example data for plotting
x = linspace(0, 10, 100);
y = sin(x);
plotType = 'Line';
lineWidth = 2;

% Generate the plot
figure;
plotData(x, y, plotType, lineWidth);

%% 5. Save Results

% Example function to save results to a file
function saveResults(fileName, results)
    fid = fopen(fileName, 'wt');
    fprintf(fid, '%s\n', results);
    fclose(fid);
end

% Define file name for saving results
resultFileName = fullfile(rootDir, 'results.txt');
results = 'Sample results data';

% Save the results
saveResults(resultFileName, results);
disp(['Results saved to: ', resultFileName]);

