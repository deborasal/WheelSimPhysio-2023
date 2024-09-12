function [HR_timetable] = readingHR(HR_filename,user_ID)

HR_raw_file=csvread(HR_filename);
HR_values=HR_raw_file(3:end,1);
HR_Fs=HR_raw_file(2,1);% Fs in Hertz;
HR_dt=seconds(1/HR_Fs); % dt in seconds
HR_start_time=datetime(HR_raw_file(1,1),'ConvertFrom', 'posixtime', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS'); % Converting the start time in Unix epoch to datetime
HR_start_time=HR_start_time +hours(1);

HR_rows=length(HR_raw_file(1:end))-2; % Number of HR values
HR_time(:,1)= HR_start_time + (0:HR_rows-1)*HR_dt; % HR time values
HR_duration(:,1)= seconds(0:HR_dt:(HR_rows-1)*HR_dt); % Duration of the test
HR_ID(1:HR_rows,1)=user_ID;
HR_variables={'Sampe_ID','Duration_seconds','HR_values'};

HR_timetable=timetable(HR_ID,HR_duration,HR_values,'RowTimes',HR_time,'VariableNames',HR_variables);
end