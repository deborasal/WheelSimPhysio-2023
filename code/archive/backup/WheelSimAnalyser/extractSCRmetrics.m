function EDA_features = extractSCRmetrics(EDA_timetable)

    samplingRate = 4;  % Assuming the sampling rate is 4 Hz

    % eda = timetable2table(EDA_timetable(:, 'EDA_values'));
    % edaSignal = table2array(eda(:, 1));

    % Extract the EDA signal from the timetable
    if ismember('EDA_values', EDA_timetable.Properties.VariableNames)
        edaSignal = EDA_timetable.EDA_values;
    else
        error('EDA_values column not found in the timetable.');
    end

    % Check if edaSignal is empty
    if isempty(edaSignal)
        error('EDA signal is empty. Ensure EDA_timetable contains valid data.');
    end

    % Preprocess the EDA signal (e.g., filtering, normalization)
    filteredEDA = lowpass(edaSignal, 2, samplingRate); % Example low-pass filter

    % Calculate Mean Skin Conductance Level (SCL)
    meanSCL = mean(filteredEDA);
    stdSCL = std(filteredEDA);
    threshold = meanSCL + 2 * stdSCL;

    % Identify SCRs 
    [peaks, locs] = findpeaks(filteredEDA, 'Threshold', 0.05); % Example peak detection
    peaks_time = EDA_timetable.Time(locs);

    % Calculate SCR metrics
    scrAmplitude = peaks; % Amplitude of each SCR
    scrFrequency = length(peaks) / (length(filteredEDA) / samplingRate); % SCR frequency
    scrCount = length(scrAmplitude);

    % Handle empty peaks case
    if isempty(peaks)
        scrAmplitude = 0;
        scrCount = 0;
        scrFrequency = 0;
    end

    % Calculate rise time and recovery time (simplified approach)
    % Initialize arrays
    scrRiseTime = []; 
    scrRecoveryTime = [];

    for i = 1:length(locs)
        % Rise time (time from start of SCR to peak)
        startTime = find(filteredEDA(1:locs(i)) < (peaks(i) - 0.5 * scrAmplitude(i)), 1, 'last');
        if ~isempty(startTime)
            riseTime = (locs(i) - startTime) / samplingRate;
            scrRiseTime = [scrRiseTime, riseTime];
        end

        % Recovery time (time from peak to half-recovery)
        recoveryEnd = find(filteredEDA(locs(i):end) < (peaks(i) - 0.5 * scrAmplitude(i)), 1, 'first');
        if ~isempty(recoveryEnd)
            recoveryTime = recoveryEnd / samplingRate;
            scrRecoveryTime = [scrRecoveryTime, recoveryTime];
        end
    end

    % Compile EDA features
    EDA_features = [mean(scrAmplitude), scrCount, meanSCL, mean(scrRiseTime), mean(scrRecoveryTime)];

    % Handle case where no SCRs are detected
    if scrCount == 0
        EDA_features = [0, 0, meanSCL, NaN, NaN];
    end

end

