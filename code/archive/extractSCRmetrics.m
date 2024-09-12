function   [EDA_features] = extractSCRmetrics(EDA_timetable)

  samplingRate=4; 
  eda=timetable2table(EDA_timetable(:,3));
  edaSignal=table2array(eda(:,2));

% Determining all the peaks and valleys with the threshold 0.05 as valid
    
    % Preprocess the EDA signal (e.g., filtering, normalization)
    % 


    filteredEDA = lowpass(edaSignal, 2, samplingRate); % Example low-pass filter
    meanSCL =0;
    % Calculate Mean Skin Conductance Level (SCL)
     meanSCL = mean(filteredEDA);
     stdSCL = std(filteredEDA);  
     threshold= meanSCL +2* stdSCL;

    % Identify SCRs 
    [peaks, locs] = findpeaks(filteredEDA, 'Threshold', 0.05); % Example peak detection0 0
    peaks_time=eda.Time(locs);

    % Calculate SCR metrics
    scrAmplitude = peaks; % Amplitude of each SCR
    scrFrequency = length(peaks) / (length(filteredEDA) / samplingRate); % SCR frequency
    scrCount=length(scrAmplitude);

     if isempty(peaks)
             scrAmplitude =0;
             scrCount =0;
     end

    % Calculate rise time and recovery time (this is a simplistic approach; adjust as needed)
%     scrRiseTime = []; % Initialize rise time array
%     scrRecoveryTime = []; % Initialize recovery time array
%     for i = 1:length(locs)
%         % Rise time (time from start of SCR to peak)
%         startTime = find(filteredEDA(1:locs(i)) < (peaks(i) - 0.5 * scrAmplitude(i)), 1, 'last');
%         if ~isempty(startTime)
%             riseTime = (locs(i) - startTime) / samplingRate;
%             scrRiseTime = [scrRiseTime, riseTime];
%         end
% 
%         % Recovery time (time from peak to half-recovery)
%         recoveryEnd = find(filteredEDA(locs(i):end) < (peaks(i) - 0.5 * scrAmplitude(i)), 1, 'first');
%         if ~isempty(recoveryEnd)
%             recoveryTime = (recoveryEnd) / samplingRate;
%             scrRecoveryTime = [scrRecoveryTime, recoveryTime];
%         end
%     end

     % EDA_Features=[scrAmplitude, scrFrequency, scrRiseTime, scrRecoveryTime];
    EDA_features= [mean(scrAmplitude(:,1)), scrCount(:,1), meanSCL];

end
