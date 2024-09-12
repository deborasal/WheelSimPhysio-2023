function [BVP_timetable] = readingBVP(BVP_filename,user_ID)
% Functions that reads Blood Volume data and returns as timetable:

BVP_raw_file=csvread(BVP_filename);
BVP_values=BVP_raw_file(3:end,1);
BVP_Fs=BVP_raw_file(2,1);% Fs in Hertz;
BVP_dt=seconds(1/BVP_Fs); % dt in seconds
BVP_start_time=datetime(BVP_raw_file(1,1),'ConvertFrom', 'posixtime', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS'); % Converting the start time in Unix epoch to datetime
BVP_start_time=BVP_start_time +hours(1);

BVP_rows=length(BVP_raw_file(1:end))-2; % Number of BVP values
BVP_time(:,1)= BVP_start_time + (0:BVP_rows-1)*BVP_dt; % BVP time values
BVP_duration(:,1)= seconds(0:BVP_dt:(BVP_rows-1)*BVP_dt); % Duration of the test
% BVP_ID(1:BVP_rows,1)=user_ID;
BVP_ID = repmat({user_ID}, BVP_rows, 1); % Replicate user_ID to match the number of rows
BVP_time = BVP_start_time + (0:BVP_rows-1)' * BVP_dt; % BVP time values
BVP_duration = seconds(0:BVP_dt:(BVP_rows-1)*BVP_dt)'; % Duration of the test

BVP_variables={'Sampe_ID','Duration_seconds','BVP_values'};

BVP_timetable=timetable(BVP_ID,BVP_duration,BVP_values,'RowTimes',BVP_time,'VariableNames',BVP_variables);

end