function [EDA_timetable] = readingEDA(EDA_filename,user_ID)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
EDA_raw_file=csvread(EDA_filename);
EDA_values=EDA_raw_file(3:end,1);
EDA_Fs=EDA_raw_file(2,1);% Fs in Hertz;
EDA_dt=seconds(1/EDA_Fs); % dt in seconds
EDA_start_time=datetime(EDA_raw_file(1,1),'ConvertFrom', 'posixtime', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS'); % Converting the start time in Unix epoch to datetime
EDA_start_time=EDA_start_time +hours(1);

EDA_rows=length(EDA_raw_file(1:end))-2; % Number of EDA values
% EDA_time(:,1)= EDA_start_time + (0:EDA_rows-1)*EDA_dt; % EDA time values
% EDA_duration(:,1)= seconds(0:EDA_dt:(EDA_rows-1)*EDA_dt); % Duration of the test
% EDA_ID(1:EDA_rows,1)=user_ID;
EDA_time = EDA_start_time + (0:EDA_rows-1)' * EDA_dt; % EDA time values 
EDA_duration = seconds(0:EDA_dt:(EDA_rows-1)*EDA_dt)'; % Duration of the test
EDA_ID = repmat({user_ID}, EDA_rows, 1); % Replicate user_ID to match the number of rows 


EDA_variables={'Sample_ID','Duration_seconds','EDA_values'};

EDA_timetable=timetable(EDA_ID,EDA_duration,EDA_values,'RowTimes',EDA_time,'VariableNames',EDA_variables);
end