function [IBI_timetable] = readingIBI(IBI_filename,user_ID)
%This functions reads the inter-beat-interval and return as timetable
IBI_raw_file=readtable(IBI_filename);
IBI_values=table2array(IBI_raw_file(2:end,2));
IBI_dt=table2array(IBI_raw_file(2:end,1)); % dt in seconds
IBI_start_time=datetime(table2array(IBI_raw_file(1,1)),'ConvertFrom', 'posixtime', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS'); % Converting the start time in Unix epoch to datetime
IBI_start_time=IBI_start_time +hours(1);

[IBI_rows, ~]=size(IBI_raw_file); % Number of BVP values

IBI_time= NaT(IBI_rows-1,1); % Initialize IBI_time as a column vector of NaT
HR_values=zeros(IBI_rows-1,1); % Initialize HR_values as a column vector of zeros

IBI_current_time=IBI_start_time;

for i=1:IBI_rows -1

  IBI_current_time= IBI_start_time+ seconds(IBI_dt(i,1));
  IBI_time(i,1)= IBI_current_time; 
  HR_values(i,1)=60/IBI_values(i,1); % Calculating HR in BPM

end

% IBI time values
% IBI_ID(1:IBI_rows-1,1)=user_ID;
IBI_ID = repmat({user_ID}, IBI_rows-1, 1);

IBI_variables={'Sample_ID','Time_sec','IBI_values','HR_values'};
IBI_timetable=timetable(IBI_ID,IBI_dt,IBI_values,HR_values,'RowTimes',IBI_time,'VariableNames',IBI_variables);

% Convert IBI_time to desired format
IBI_timetable.Time = datetime(IBI_timetable.Time, 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');
end