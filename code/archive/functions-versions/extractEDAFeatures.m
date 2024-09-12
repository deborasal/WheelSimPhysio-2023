function EDA_features = extractEDAFeatures(EDA_timetable)

    samplingRate = 4;  % Assuming the sampling rate is 4 Hz

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

    % Step 1: Preprocess the EDA signal (Band-pass filter at 0.05-0.4 Hz)
    filteredEDA = bandpass(edaSignal, [0.05 0.4], samplingRate);

    % Step 2: Fourier Transform for spectral analysis
    EDA_fft = fft(filteredEDA);
    f = (0:length(EDA_fft)-1)*samplingRate/length(EDA_fft);
    
    % Only consider frequencies within 0-0.4 Hz
    validFreqs = f(f <= 0.4);
    EDA_fft = EDA_fft(f <= 0.4);

    % Frequency band analysis
    F0SC = bandpower(filteredEDA, samplingRate, [0.05 0.1]);
    F1SC = bandpower(filteredEDA, samplingRate, [0.1 0.2]);
    F2SC = bandpower(filteredEDA, samplingRate, [0.2 0.3]);
    F3SC = bandpower(filteredEDA, samplingRate, [0.3 0.4]);

    % Step 3: Derivatives of the EDA signal
    firstDerivative = diff(filteredEDA);
    secondDerivative = diff(firstDerivative);

    % Step 4: Mean Skin Conductance Level (SCL)
    meanSCL = mean(filteredEDA);
    stdSCL = std(filteredEDA);
    threshold = meanSCL + 2 * stdSCL;

    % Step 5: Identify SCRs using peak detection
    [peaks, locs] = findpeaks(filteredEDA, 'MinPeakHeight', 0.05);
    peaks_time = EDA_timetable.Time(locs);

    % Calculate SCR metrics
    scrAmplitude = peaks;
    scrFrequency = length(peaks) / (length(filteredEDA) / samplingRate);
    scrCount = length(scrAmplitude);

    % Handle empty peaks case
    if isempty(peaks)
        scrAmplitude = 0;
        scrCount = 0;
        scrFrequency = 0;
    end

    % Step 6: Calculate rise time and recovery time
    scrRiseTime = [];
    scrRecoveryTime = [];

    for i = 1:length(locs)
        startTime = find(filteredEDA(1:locs(i)) < (peaks(i) - 0.5 * scrAmplitude(i)), 1, 'last');
        if ~isempty(startTime)
            riseTime = (locs(i) - startTime) / samplingRate;
            scrRiseTime = [scrRiseTime, riseTime];
        end

        recoveryEnd = find(filteredEDA(locs(i):end) < (peaks(i) - 0.5 * scrAmplitude(i)), 1, 'first');
        if ~isempty(recoveryEnd)
            recoveryTime = recoveryEnd / samplingRate;
            scrRecoveryTime = [scrRecoveryTime, recoveryTime];
        end
    end

    % Compile EDA features
    EDA_features = [mean(scrAmplitude), scrCount, meanSCL, mean(scrRiseTime), mean(scrRecoveryTime), ...
                    F0SC, F1SC, F2SC, F3SC, mean(firstDerivative), mean(secondDerivative)];

    % Handle case where no SCRs are detected
    if scrCount == 0
        EDA_features = [0, 0, meanSCL, NaN, NaN, F0SC, F1SC, F2SC, F3SC, mean(firstDerivative), mean(secondDerivative)];
    end

    % Frequency domain analysis validation
    % figure;
    % plot(validFreqs, abs(EDA_fft));
    % title('Frequency Domain Analysis of EDA Signal');
    % xlabel('Frequency (Hz)');
    % ylabel('Magnitude');
    % grid on;

    % Ensure the spectral analysis shows peaks in the 0-0.4 Hz range
    % This confirms the presence of true EDA events

end
